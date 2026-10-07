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
