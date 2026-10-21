import 'package:cloud_firestore/cloud_firestore.dart';

/// Réglages uniques de l'application (document unique `settings/app`).
class AppSetting {
  final int reminderLeadMonths;
  final String currency;
  final bool onboardingDone;

  const AppSetting({
    this.reminderLeadMonths = 1,
    this.currency = 'TND',
    this.onboardingDone = false,
  });

  factory AppSetting.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const AppSetting();
    return AppSetting(
      reminderLeadMonths: (map['reminderLeadMonths'] as num?)?.toInt() ?? 1,
      currency: map['currency'] as String? ?? 'TND',
      onboardingDone: map['onboardingDone'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
        'reminderLeadMonths': reminderLeadMonths,
        'currency': currency,
        'onboardingDone': onboardingDone,
      };

  AppSetting copyWith({
    int? reminderLeadMonths,
    String? currency,
    bool? onboardingDone,
  }) =>
      AppSetting(
        reminderLeadMonths: reminderLeadMonths ?? this.reminderLeadMonths,
        currency: currency ?? this.currency,
        onboardingDone: onboardingDone ?? this.onboardingDone,
      );
}

/// Contrat de location d'un local commercial.
class Contract {
  final String id;
  final String tenantName;
  final String unitNumber;
  final DateTime startDate;
  final DateTime endDate;
  final double monthlyAmount;
  final String? stegMeter;
  final String? sonedeMeter;
  final String notes;
  final DateTime createdAt;
  final bool archived;

  const Contract({
    required this.id,
    required this.tenantName,
    required this.unitNumber,
    required this.startDate,
    required this.endDate,
    required this.monthlyAmount,
    this.stegMeter,
    this.sonedeMeter,
    this.notes = '',
    required this.createdAt,
    this.archived = false,
  });

  factory Contract.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return Contract(
      id: doc.id,
      tenantName: d['tenantName'] as String? ?? '',
      unitNumber: d['unitNumber'] as String? ?? '',
      startDate: (d['startDate'] as Timestamp).toDate(),
      endDate: (d['endDate'] as Timestamp).toDate(),
      monthlyAmount: (d['monthlyAmount'] as num?)?.toDouble() ?? 0,
      stegMeter: d['stegMeter'] as String?,
      sonedeMeter: d['sonedeMeter'] as String?,
      notes: d['notes'] as String? ?? '',
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      archived: d['archived'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
        'tenantName': tenantName,
        'unitNumber': unitNumber,
        'startDate': Timestamp.fromDate(startDate),
        'endDate': Timestamp.fromDate(endDate),
        'monthlyAmount': monthlyAmount,
        'stegMeter': stegMeter,
        'sonedeMeter': sonedeMeter,
        'notes': notes,
        'createdAt': Timestamp.fromDate(createdAt),
        'archived': archived,
      };
}

/// Paiement d'un loyer pour un mois donné. La présence d'un document pour
/// un (contractId, month) donné signifie que ce mois a été payé.
class Payment {
  final String id;
  final String contractId;
  final DateTime month;
  final double amount;
  final DateTime paidDate;
  final String notes;
  final DateTime createdAt;

  const Payment({
    required this.id,
    required this.contractId,
    required this.month,
    required this.amount,
    required this.paidDate,
    this.notes = '',
    required this.createdAt,
  });

  factory Payment.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return Payment(
      id: doc.id,
      contractId: d['contractId'] as String? ?? '',
      month: (d['month'] as Timestamp).toDate(),
      amount: (d['amount'] as num?)?.toDouble() ?? 0,
      paidDate: (d['paidDate'] as Timestamp).toDate(),
      notes: d['notes'] as String? ?? '',
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'contractId': contractId,
        'month': Timestamp.fromDate(month),
        'amount': amount,
        'paidDate': Timestamp.fromDate(paidDate),
        'notes': notes,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}

/// Pièce jointe (photo) liée à un contrat : contrat signé, CIN du
/// locataire, état des lieux, etc.
///
/// Stockée directement dans Firestore sous forme d'image compressée encodée
/// en base64 (et non sur Firebase Storage, qui exige le forfait payant
/// Blaze) — reste 100% gratuit, au prix d'une taille limitée par image
/// (~1 Mo maximum par document Firestore).
class Attachment {
  final String id;
  final String contractId;
  final String category;
  final String data;
  final DateTime createdAt;

  const Attachment({
    required this.id,
    required this.contractId,
    required this.category,
    required this.data,
    required this.createdAt,
  });

  factory Attachment.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return Attachment(
      id: doc.id,
      contractId: d['contractId'] as String? ?? '',
      category: d['category'] as String? ?? 'autre',
      data: d['data'] as String? ?? '',
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'contractId': contractId,
        'category': category,
        'data': data,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}

/// Facture de compteur (STEG ou SONEDE) réglée pour un mois donné. La
/// présence d'un document pour un (contractId, type, month) donné signifie
/// que cette facture a été payée.
class UtilityBill {
  final String id;
  final String contractId;
  /// 'steg' (électricité) ou 'sonede' (eau).
  final String type;
  final DateTime month;
  final double? amount;
  final DateTime paidDate;
  final DateTime createdAt;

  const UtilityBill({
    required this.id,
    required this.contractId,
    required this.type,
    required this.month,
    this.amount,
    required this.paidDate,
    required this.createdAt,
  });

  factory UtilityBill.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return UtilityBill(
      id: doc.id,
      contractId: d['contractId'] as String? ?? '',
      type: d['type'] as String? ?? 'steg',
      month: (d['month'] as Timestamp).toDate(),
      amount: (d['amount'] as num?)?.toDouble(),
      paidDate: (d['paidDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'contractId': contractId,
        'type': type,
        'month': Timestamp.fromDate(month),
        'amount': amount,
        'paidDate': Timestamp.fromDate(paidDate),
        'createdAt': Timestamp.fromDate(createdAt),
      };
}
