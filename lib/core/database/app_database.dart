import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../utils/id_generator.dart';
import 'tables.dart';

export 'tables.dart';

part 'app_database.g.dart';

/// Données importées depuis Locations.xlsx (fichier de suivi des contrats
/// de location de locaux commerciaux), insérées une fois à la création de
/// la base. L'utilisateur peut ensuite les modifier/supprimer librement.
final List<ContractsCompanion> _seedContracts = [
  _seed('شهاب الزايدي', 'A1-1', '2025-06-01', '2026-06-01', 420,
      steg: '731907470', sonede: '7353578'),
  _seed('علاء الدين الطرابلسي', 'A1-4', '2025-08-01', '2026-08-01', 400,
      steg: '731907450', sonede: '7353558'),
  _seed('عبدالرحمن بن صالح (الجمعية)', 'A0-2', '2025-10-01', '2026-10-01', 330,
      steg: '731907440'),
  _seed('شكري سحنون (مغازة 4)', 'MG4', '2026-05-05', '2027-05-05', 320,
      steg: '731907530'),
  _seed('عيسى الزايدي', 'A0-1', '2025-10-07', '2026-04-07', 330,
      steg: '731907430', sonede: '7353598'),
  _seed('زبير خلف الله', 'A1-3', '2025-09-09', '2026-03-09', 420,
      steg: '731907460', sonede: '7353562'),
  _seed('أسامة الجمل', 'A2-4', '2025-08-10', '2026-08-10', 420,
      steg: '731907490', sonede: '7353580'),
  _seed('محمد الشرودي -خياطة (مغازة 2)', 'MG2', '2026-01-14', '2027-01-14', 300,
      steg: '731907390'),
  _seed('عمار المشيرقي', 'A2-3', '2026-06-02', '2026-12-02', 420,
      steg: '731907500', sonede: '7353582'),
  _seed('علي اليوسفي', 'A1-2', '2026-06-24', '2027-06-24', 420,
      steg: '731907480', sonede: '7353576'),
  _seed('إبراهيم الشايب', 'A2-2', '2026-05-07', '2027-05-07', 420,
      steg: '731907520', sonede: '7353590'),
  _seed('أسامة العوادني', 'A2-1', '2026-05-11', '2027-05-11', 420,
      steg: '731907510', sonede: '7353586'),
];

ContractsCompanion _seed(
  String tenantName,
  String unitNumber,
  String startDate,
  String endDate,
  double monthlyAmount, {
  String? steg,
  String? sonede,
}) {
  return ContractsCompanion.insert(
    id: newId(),
    tenantName: tenantName,
    unitNumber: unitNumber,
    startDate: DateTime.parse(startDate),
    endDate: DateTime.parse(endDate),
    monthlyAmount: monthlyAmount,
    stegMeter: Value(steg),
    sonedeMeter: Value(sonede),
  );
}

@DriftDatabase(tables: [AppSettings, Contracts, Payments, Attachments])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await into(appSettings).insert(const AppSettingsCompanion());
          for (final contract in _seedContracts) {
            await into(contracts).insert(contract);
          }
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(payments);
          }
          if (from < 3) {
            await m.createTable(attachments);
          }
        },
      );

  // ---------- Réglages ----------
  Future<AppSetting> getSettings() async {
    final rows = await select(appSettings).get();
    if (rows.isEmpty) {
      await into(appSettings).insert(const AppSettingsCompanion());
      return (await select(appSettings).get()).first;
    }
    return rows.first;
  }

  Stream<AppSetting> watchSettings() {
    return (select(appSettings)..where((t) => t.id.equals(1))).watchSingle();
  }

  Future<void> updateSettings(AppSettingsCompanion companion) async {
    await (update(appSettings)..where((t) => t.id.equals(1))).write(companion);
  }

  // ---------- Contrats ----------
  Stream<List<Contract>> watchContracts() {
    return (select(contracts)
          ..where((t) => t.archived.equals(false))
          ..orderBy([(t) => OrderingTerm.asc(t.endDate)]))
        .watch();
  }

  /// Locaux mis en attente (ancien locataire sorti, contrat clôturé).
  Stream<List<Contract>> watchVacantContracts() {
    return (select(contracts)
          ..where((t) => t.archived.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.unitNumber)]))
        .watch();
  }

  Future<Contract?> getContractById(String id) {
    return (select(contracts)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<String> createContract(ContractsCompanion companion) async {
    await into(contracts).insert(companion);
    return companion.id.value;
  }

  Future<void> updateContract(String id, ContractsCompanion companion) {
    return (update(contracts)..where((t) => t.id.equals(id))).write(companion);
  }

  /// Marque le contrat comme clôturé : le locataire est sorti, le local
  /// passe en attente (vacant) jusqu'à un nouveau contrat.
  Future<void> setContractVacant(String id, bool vacant) {
    return (update(contracts)..where((t) => t.id.equals(id)))
        .write(ContractsCompanion(archived: Value(vacant)));
  }

  Future<void> deleteContract(String id) {
    return (delete(contracts)..where((t) => t.id.equals(id))).go();
  }

  // ---------- Paiements ----------
  static DateTime monthKey(DateTime d) => DateTime(d.year, d.month, 1);

  static String paymentId(String contractId, DateTime month) =>
      '$contractId-${month.year}-${month.month.toString().padLeft(2, '0')}';

  Stream<List<Payment>> watchPaymentsForContract(String contractId) {
    return (select(payments)
          ..where((t) => t.contractId.equals(contractId))
          ..orderBy([(t) => OrderingTerm.desc(t.month)]))
        .watch();
  }

  /// Enregistre (ou met à jour) le paiement d'un mois donné pour un contrat.
  Future<void> markMonthPaid({
    required String contractId,
    required DateTime month,
    required double amount,
    required DateTime paidDate,
    String notes = '',
  }) {
    final key = monthKey(month);
    return into(payments).insertOnConflictUpdate(
      PaymentsCompanion.insert(
        id: paymentId(contractId, key),
        contractId: contractId,
        month: key,
        amount: amount,
        paidDate: paidDate,
        notes: Value(notes),
      ),
    );
  }

  Future<void> markMonthUnpaid(String contractId, DateTime month) {
    return (delete(payments)
          ..where((t) => t.id.equals(paymentId(contractId, monthKey(month)))))
        .go();
  }

  /// Tous les contrats (actifs et en attente) qui ont occupé ce local,
  /// du plus récent au plus ancien — pour l'historique d'un local.
  Stream<List<Contract>> watchContractsForUnit(String unitNumber) {
    return (select(contracts)
          ..where((t) => t.unitNumber.equals(unitNumber))
          ..orderBy([(t) => OrderingTerm.desc(t.startDate)]))
        .watch();
  }

  // ---------- Pièces jointes ----------
  Stream<List<Attachment>> watchAttachmentsForContract(String contractId) {
    return (select(attachments)
          ..where((t) => t.contractId.equals(contractId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }

  Future<void> addAttachment({
    required String contractId,
    required String category,
    required String filePath,
  }) {
    return into(attachments).insert(
      AttachmentsCompanion.insert(
        id: newId(),
        contractId: contractId,
        category: category,
        filePath: filePath,
      ),
    );
  }

  Future<Attachment?> getAttachment(String id) {
    return (select(attachments)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<void> deleteAttachment(String id) {
    return (delete(attachments)..where((t) => t.id.equals(id))).go();
  }

  // ---------- Sauvegarde / restauration ----------
  Stream<List<Payment>> watchAllPayments() => select(payments).watch();

  Future<List<Contract>> getAllContracts() => select(contracts).get();

  Future<List<Payment>> getAllPayments() => select(payments).get();

  Future<List<Attachment>> getAllAttachments() => select(attachments).get();

  /// Remplace toutes les données existantes par celles d'une sauvegarde.
  Future<void> restoreAll({
    required AppSettingsCompanion settings,
    required List<ContractsCompanion> contractRows,
    required List<PaymentsCompanion> paymentRows,
  }) {
    return transaction(() async {
      await delete(payments).go();
      await delete(contracts).go();
      await updateSettings(settings);
      for (final row in contractRows) {
        await into(contracts).insertOnConflictUpdate(row);
      }
      for (final row in paymentRows) {
        await into(payments).insertOnConflictUpdate(row);
      }
    });
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'locatrack.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
