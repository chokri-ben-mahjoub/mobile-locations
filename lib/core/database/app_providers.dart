import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/firestore_service.dart';
import '../data/models.dart';

export '../data/models.dart';

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

/// Flux des réglages de l'app (délai de rappel, devise, onboarding).
final appSettingsProvider = StreamProvider<AppSetting>((ref) {
  final service = ref.watch(firestoreServiceProvider);
  return service.watchSettings();
});

final reminderLeadMonthsProvider = Provider<int>((ref) {
  return ref.watch(appSettingsProvider).valueOrNull?.reminderLeadMonths ?? 1;
});

final currencyProvider = Provider<String>((ref) {
  return ref.watch(appSettingsProvider).valueOrNull?.currency ?? 'TND';
});

/// Flux des contrats de location (triés par date de fin croissante).
final contractsProvider = StreamProvider<List<Contract>>((ref) {
  final service = ref.watch(firestoreServiceProvider);
  return service.watchContracts();
});

/// Flux des locaux en attente (ancien locataire sorti).
final vacantContractsProvider = StreamProvider<List<Contract>>((ref) {
  final service = ref.watch(firestoreServiceProvider);
  return service.watchVacantContracts();
});

/// Tous les paiements enregistrés (alimente les analyses du portefeuille).
final allPaymentsProvider = StreamProvider<List<Payment>>((ref) {
  final service = ref.watch(firestoreServiceProvider);
  return service.watchAllPayments();
});

/// Toutes les factures STEG/SONEDE réglées, tous contrats confondus
/// (alimente la vue globale des locataires).
final allUtilityBillsProvider = StreamProvider<List<UtilityBill>>((ref) {
  final service = ref.watch(firestoreServiceProvider);
  return service.watchAllUtilityBills();
});

/// Historique des paiements d'un contrat donné.
final paymentsForContractProvider =
    StreamProvider.family<List<Payment>, String>((ref, contractId) {
  final service = ref.watch(firestoreServiceProvider);
  return service.watchPaymentsForContract(contractId);
});

/// Historique complet des contrats (actifs + en attente) d'un local donné.
final contractsForUnitProvider =
    StreamProvider.family<List<Contract>, String>((ref, unitNumber) {
  final service = ref.watch(firestoreServiceProvider);
  return service.watchContractsForUnit(unitNumber);
});

/// Pièces jointes d'un contrat donné.
final attachmentsForContractProvider =
    StreamProvider.family<List<Attachment>, String>((ref, contractId) {
  final service = ref.watch(firestoreServiceProvider);
  return service.watchAttachmentsForContract(contractId);
});

/// Historique des factures STEG/SONEDE d'un contrat donné.
/// Clé : (contractId, type) avec type = 'steg' ou 'sonede'.
final utilityBillsProvider =
    StreamProvider.family<List<UtilityBill>, (String, String)>((ref, key) {
  final service = ref.watch(firestoreServiceProvider);
  return service.watchUtilityBills(key.$1, key.$2);
});
