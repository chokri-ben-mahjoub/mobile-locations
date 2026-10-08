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

/// Paiement d'un loyer pour un mois donné. La présence d'une ligne pour
/// un (contractId, month) donné signifie que ce mois a été payé.
class Payments extends Table {
  /// Id déterministe : "<contractId>-<year>-<month>".
  TextColumn get id => text()();
  TextColumn get contractId => text()();
  /// Premier jour du mois concerné (ex: 2026-03-01).
  DateTimeColumn get month => dateTime()();
  RealColumn get amount => real()();
  DateTimeColumn get paidDate => dateTime()();
  TextColumn get notes => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Pièce jointe (photo) liée à un contrat : contrat signé, CIN du
/// locataire, état des lieux, etc.
class Attachments extends Table {
  TextColumn get id => text()();
  TextColumn get contractId => text()();
  /// 'contrat' | 'cin' | 'etat_lieux' | 'autre'
  TextColumn get category => text()();
  TextColumn get filePath => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
