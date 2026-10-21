import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/attachments/attachment_service.dart';
import '../../../core/data/firestore_service.dart';
import '../../../core/database/app_providers.dart';

export '../../../core/database/app_providers.dart' show contractsProvider;

class ContractsController {
  final FirestoreService service;
  ContractsController(this.service);

  Future<String> create({
    required String tenantName,
    required String unitNumber,
    required DateTime startDate,
    required DateTime endDate,
    required double monthlyAmount,
    String? stegMeter,
    String? sonedeMeter,
    String notes = '',
  }) {
    return service.createContract(
      tenantName: tenantName,
      unitNumber: unitNumber,
      startDate: startDate,
      endDate: endDate,
      monthlyAmount: monthlyAmount,
      stegMeter: stegMeter,
      sonedeMeter: sonedeMeter,
      notes: notes,
    );
  }

  Future<void> update(
    String id, {
    required String tenantName,
    required String unitNumber,
    required DateTime startDate,
    required DateTime endDate,
    required double monthlyAmount,
    String? stegMeter,
    String? sonedeMeter,
    String notes = '',
  }) {
    return service.updateContract(
      id,
      tenantName: tenantName,
      unitNumber: unitNumber,
      startDate: startDate,
      endDate: endDate,
      monthlyAmount: monthlyAmount,
      stegMeter: stegMeter,
      sonedeMeter: sonedeMeter,
      notes: notes,
    );
  }

  /// Le locataire est sorti : clôture le contrat et met le local en attente.
  Future<void> markVacant(String id) => service.setContractVacant(id, true);

  /// Réactive un local précédemment mis en attente.
  Future<void> reactivate(String id) => service.setContractVacant(id, false);

  Future<void> delete(String id) => service.deleteContract(id);
}

final contractsControllerProvider = Provider<ContractsController>((ref) {
  return ContractsController(ref.watch(firestoreServiceProvider));
});

class PaymentsController {
  final FirestoreService service;
  PaymentsController(this.service);

  Future<void> markPaid({
    required String contractId,
    required DateTime month,
    required double amount,
    required DateTime paidDate,
    String notes = '',
  }) {
    return service.markMonthPaid(
      contractId: contractId,
      month: month,
      amount: amount,
      paidDate: paidDate,
      notes: notes,
    );
  }

  Future<void> markUnpaid(String contractId, DateTime month) {
    return service.markMonthUnpaid(contractId, month);
  }
}

final paymentsControllerProvider = Provider<PaymentsController>((ref) {
  return PaymentsController(ref.watch(firestoreServiceProvider));
});

final attachmentServiceProvider = Provider<AttachmentService>((ref) {
  return AttachmentService(ref.watch(firestoreServiceProvider));
});

class UtilityBillsController {
  final FirestoreService service;
  UtilityBillsController(this.service);

  Future<void> markPaid({
    required String contractId,
    required String type,
    required DateTime month,
    double? amount,
    required DateTime paidDate,
  }) {
    return service.markUtilityPaid(
      contractId: contractId,
      type: type,
      month: month,
      amount: amount,
      paidDate: paidDate,
    );
  }

  Future<void> markUnpaid(String contractId, String type, DateTime month) {
    return service.markUtilityUnpaid(contractId, type, month);
  }
}

final utilityBillsControllerProvider = Provider<UtilityBillsController>((ref) {
  return UtilityBillsController(ref.watch(firestoreServiceProvider));
});
