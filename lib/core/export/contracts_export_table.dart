import '../data/models.dart';
import '../utils/format_utils.dart';
import 'export_table.dart';

String contractStatusLabel(Contract c, DateTime now) {
  if (c.archived) return 'En attente';
  if (!c.endDate.isAfter(now)) return 'Expiré';
  return 'Actif';
}

DateTime? _latestPaidDate(Iterable<DateTime> dates) {
  DateTime? latest;
  for (final d in dates) {
    if (latest == null || d.isAfter(latest)) latest = d;
  }
  return latest;
}

/// Construit le tableau générique (utilisé par les 4 formats d'export —
/// CSV, Excel, PDF, image) à partir des contrats. Les noms de locataires
/// arabes sont transmis tels quels : chaque exporteur gère leur rendu pour
/// son propre format.
///
/// [payments] et [utilityBills] (optionnels) ajoutent la date du dernier
/// loyer, de la dernière facture STEG et de la dernière facture SONEDE
/// réglés par le locataire, pour chaque contrat.
ExportTable buildContractsExportTable(
  List<Contract> contracts,
  String currency, {
  List<Payment> payments = const [],
  List<UtilityBill> utilityBills = const [],
}) {
  final now = DateTime.now();
  final sorted = [...contracts]..sort((a, b) => a.endDate.compareTo(b.endDate));

  final paymentsByContract = <String, List<Payment>>{};
  for (final p in payments) {
    paymentsByContract.putIfAbsent(p.contractId, () => []).add(p);
  }
  final utilityBillsByContract = <String, List<UtilityBill>>{};
  for (final b in utilityBills) {
    utilityBillsByContract.putIfAbsent(b.contractId, () => []).add(b);
  }

  return ExportTable(
    name: 'Contrats',
    headers: [
      'N°',
      'Locataire',
      'Local',
      'Date début',
      'Date fin',
      'Durée',
      'Loyer mensuel ($currency)',
      'Compteur STEG',
      'Compteur SONEDE',
      'Statut',
      'Dernier loyer payé le',
      'Dernier STEG payé le',
      'Dernier SONEDE payé le',
    ],
    rows: [
      for (final (i, c) in sorted.indexed)
        [
          i + 1,
          c.tenantName,
          c.unitNumber,
          DateOnly(c.startDate),
          DateOnly(c.endDate),
          FormatUtils.durationLabel(c.startDate, c.endDate),
          c.monthlyAmount,
          c.stegMeter ?? '',
          c.sonedeMeter ?? '',
          contractStatusLabel(c, now),
          _lastPaidCell(paymentsByContract[c.id]?.map((p) => p.paidDate)),
          _lastPaidCell(
            utilityBillsByContract[c.id]?.where((b) => b.type == 'steg').map((b) => b.paidDate),
          ),
          _lastPaidCell(
            utilityBillsByContract[c.id]?.where((b) => b.type == 'sonede').map((b) => b.paidDate),
          ),
        ],
    ],
  );
}

Object _lastPaidCell(Iterable<DateTime>? dates) {
  if (dates == null) return 'Non payé';
  final latest = _latestPaidDate(dates);
  return latest == null ? 'Non payé' : DateOnly(latest);
}
