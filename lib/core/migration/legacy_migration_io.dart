import 'dart:convert';
import 'dart:io';

import '../data/firestore_service.dart';
import '../data/models.dart';
import '../database/app_database.dart' as legacy;

/// Lit l'ancienne base locale Drift (mobile) et importe tout dans Firestore
/// + Firebase Storage. Exécuté une seule fois, à la demande (bouton dans
/// Réglages), lors du passage de l'app au stockage cloud partagé.
class LegacyMigrationService {
  Future<bool> hasLocalData() async {
    final db = legacy.AppDatabase();
    try {
      final contracts = await db.getAllContracts();
      return contracts.isNotEmpty;
    } finally {
      await db.close();
    }
  }

  /// Retourne le nombre d'éléments importés.
  Future<int> migrateTo(FirestoreService cloudService) async {
    final db = legacy.AppDatabase();
    var count = 0;
    try {
      final settings = await db.getSettings();
      await cloudService.updateSettings(
        reminderLeadMonths: settings.reminderLeadMonths,
        currency: settings.currency,
        onboardingDone: true,
      );

      for (final c in await db.getAllContracts()) {
        await cloudService.importContract(Contract(
          id: c.id,
          tenantName: c.tenantName,
          unitNumber: c.unitNumber,
          startDate: c.startDate,
          endDate: c.endDate,
          monthlyAmount: c.monthlyAmount,
          stegMeter: c.stegMeter,
          sonedeMeter: c.sonedeMeter,
          notes: c.notes,
          createdAt: c.createdAt,
          archived: c.archived,
        ));
        count++;
      }

      for (final p in await db.getAllPayments()) {
        await cloudService.importPayment(Payment(
          id: p.id,
          contractId: p.contractId,
          month: p.month,
          amount: p.amount,
          paidDate: p.paidDate,
          notes: p.notes,
          createdAt: p.createdAt,
        ));
        count++;
      }

      for (final a in await db.getAllAttachments()) {
        try {
          final file = File(a.filePath);
          if (!await file.exists()) continue;
          final data = base64Encode(await file.readAsBytes());
          await cloudService.importAttachment(Attachment(
            id: a.id,
            contractId: a.contractId,
            category: a.category,
            data: data,
            createdAt: a.createdAt,
          ));
          count++;
        } catch (_) {
          // Image trop volumineuse pour un document Firestore (>1 Mo) —
          // on l'ignore plutôt que d'interrompre toute la migration.
        }
      }
    } finally {
      await db.close();
    }
    return count;
  }
}
