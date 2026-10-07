import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/app_providers.dart';
import '../../../core/utils/id_generator.dart';

export '../../../core/database/app_providers.dart' show contractsProvider;

class ContractsController {
  final AppDatabase db;
  ContractsController(this.db);

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
    return db.createContract(ContractsCompanion.insert(
      id: newId(),
      tenantName: tenantName,
      unitNumber: unitNumber,
      startDate: startDate,
      endDate: endDate,
      monthlyAmount: monthlyAmount,
      stegMeter: Value(stegMeter),
      sonedeMeter: Value(sonedeMeter),
      notes: Value(notes),
    ));
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
    return db.updateContract(
      id,
      ContractsCompanion(
        tenantName: Value(tenantName),
        unitNumber: Value(unitNumber),
        startDate: Value(startDate),
        endDate: Value(endDate),
        monthlyAmount: Value(monthlyAmount),
        stegMeter: Value(stegMeter),
        sonedeMeter: Value(sonedeMeter),
        notes: Value(notes),
      ),
    );
  }

  Future<void> delete(String id) => db.deleteContract(id);
}

final contractsControllerProvider = Provider<ContractsController>((ref) {
  return ContractsController(ref.watch(appDatabaseProvider));
});
