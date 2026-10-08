import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_database.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

/// Flux des réglages de l'app (délai de rappel, devise, onboarding).
final appSettingsProvider = StreamProvider<AppSetting>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.watchSettings();
});

final reminderLeadMonthsProvider = Provider<int>((ref) {
  return ref.watch(appSettingsProvider).valueOrNull?.reminderLeadMonths ?? 1;
});

final currencyProvider = Provider<String>((ref) {
  return ref.watch(appSettingsProvider).valueOrNull?.currency ?? 'TND';
});

final onboardingDoneProvider = Provider<bool>((ref) {
  return ref.watch(appSettingsProvider).valueOrNull?.onboardingDone ?? false;
});

/// Flux des contrats de location (triés par date de fin croissante).
final contractsProvider = StreamProvider<List<Contract>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.watchContracts();
});

/// Flux des locaux en attente (ancien locataire sorti).
final vacantContractsProvider = StreamProvider<List<Contract>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.watchVacantContracts();
});

/// Historique des paiements d'un contrat donné.
final paymentsForContractProvider =
    StreamProvider.family<List<Payment>, String>((ref, contractId) {
  final db = ref.watch(appDatabaseProvider);
  return db.watchPaymentsForContract(contractId);
});

/// Historique complet des contrats (actifs + en attente) d'un local donné.
final contractsForUnitProvider =
    StreamProvider.family<List<Contract>, String>((ref, unitNumber) {
  final db = ref.watch(appDatabaseProvider);
  return db.watchContractsForUnit(unitNumber);
});

/// Pièces jointes d'un contrat donné.
final attachmentsForContractProvider =
    StreamProvider.family<List<Attachment>, String>((ref, contractId) {
  final db = ref.watch(appDatabaseProvider);
  return db.watchAttachmentsForContract(contractId);
});

class OnboardingController {
  final AppDatabase db;
  OnboardingController(this.db);

  Future<void> complete() {
    return db.updateSettings(const AppSettingsCompanion(onboardingDone: Value(true)));
  }
}

final onboardingControllerProvider = Provider<OnboardingController>((ref) {
  return OnboardingController(ref.watch(appDatabaseProvider));
});
