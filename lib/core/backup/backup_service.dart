import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../database/app_database.dart';

class InvalidBackupException implements Exception {
  final String message;
  const InvalidBackupException(this.message);

  @override
  String toString() => message;
}

class BackupService {
  final AppDatabase db;
  BackupService(this.db);

  Future<Map<String, dynamic>> _buildExport() async {
    final settings = await db.getSettings();
    final contracts = await db.getAllContracts();
    final payments = await db.getAllPayments();
    return {
      'app': 'LocaTrack',
      'schemaVersion': db.schemaVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'settings': settings.toJson(),
      'contracts': contracts.map((c) => c.toJson()).toList(),
      'payments': payments.map((p) => p.toJson()).toList(),
    };
  }

  Future<File> _exportToTempFile() async {
    final data = await _buildExport();
    final jsonStr = const JsonEncoder.withIndent('  ').convert(data);
    final dir = await getTemporaryDirectory();
    final stamp = DateTime.now().toIso8601String().replaceAll(RegExp(r'[:.]'), '-');
    final file = File('${dir.path}/locatrack_sauvegarde_$stamp.json');
    return file.writeAsString(jsonStr);
  }

  /// Génère le fichier de sauvegarde et ouvre la feuille de partage native
  /// (enregistrer sur Drive, envoyer par email/WhatsApp, etc.).
  Future<void> shareBackup() async {
    final file = await _exportToTempFile();
    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'application/json')],
      text: 'Sauvegarde LocaTrack du ${DateTime.now().day}/'
          '${DateTime.now().month}/${DateTime.now().year}',
    );
  }

  /// Restaure les données depuis un fichier de sauvegarde JSON.
  /// Remplace entièrement les contrats, paiements et réglages existants.
  Future<void> restoreFromFile(File file) async {
    final String content;
    try {
      content = await file.readAsString();
    } catch (_) {
      throw const InvalidBackupException('Impossible de lire ce fichier.');
    }

    final dynamic decoded;
    try {
      decoded = jsonDecode(content);
    } catch (_) {
      throw const InvalidBackupException('Ce fichier n\'est pas une sauvegarde JSON valide.');
    }

    if (decoded is! Map<String, dynamic> ||
        decoded['contracts'] is! List ||
        decoded['payments'] is! List) {
      throw const InvalidBackupException(
        'Ce fichier ne correspond pas à une sauvegarde LocaTrack.',
      );
    }

    final settingsJson = decoded['settings'] as Map<String, dynamic>?;
    final settingsCompanion = settingsJson != null
        ? AppSetting.fromJson(settingsJson).toCompanion(false)
        : const AppSettingsCompanion();

    late final List<ContractsCompanion> contractRows;
    late final List<PaymentsCompanion> paymentRows;
    try {
      contractRows = (decoded['contracts'] as List)
          .map((e) => Contract.fromJson(e as Map<String, dynamic>).toCompanion(false))
          .toList();
      paymentRows = (decoded['payments'] as List)
          .map((e) => Payment.fromJson(e as Map<String, dynamic>).toCompanion(false))
          .toList();
    } catch (_) {
      throw const InvalidBackupException('Le contenu de la sauvegarde est incomplet ou corrompu.');
    }

    await db.restoreAll(
      settings: settingsCompanion,
      contractRows: contractRows,
      paymentRows: paymentRows,
    );
  }
}
