import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_providers.dart';
import 'notification_service.dart';

/// Reprogramme les rappels de tous les contrats dès que la liste des
/// contrats ou le délai de rappel (Réglages) changent. À observer une fois
/// près de la racine de l'app pour rester actif pendant toute la session.
final notificationSyncProvider = Provider<void>((ref) {
  final contracts = ref.watch(contractsProvider).valueOrNull;
  final leadMonths = ref.watch(reminderLeadMonthsProvider);
  if (contracts != null) {
    notificationService.rescheduleAll(contracts, leadMonths);
  }
});
