import 'package:drift/drift.dart';

/// Réglages uniques de l'application (ligne unique, id = 1).
class AppSettings extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  IntColumn get reminderLeadMonths => integer().withDefault(const Constant(1))();
  TextColumn get currency => text().withDefault(const Constant('TND'))();
  BoolColumn get onboardingDone => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Contrat de location d'un local commercial.
class Contracts extends Table {
  TextColumn get id => text()();
  TextColumn get tenantName => text()();
  TextColumn get unitNumber => text()();
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime()();
  RealColumn get monthlyAmount => real()();
  TextColumn get stegMeter => text().nullable()();
  TextColumn get sonedeMeter => text().nullable()();
  TextColumn get notes => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
