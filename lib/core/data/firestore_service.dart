import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/id_generator.dart';
import 'models.dart';

/// Relance un flux Firestore qui échoue avec `permission-denied` juste
/// après la connexion : au tout premier chargement, le SDK peut démarrer
/// l'écoute avant que le jeton d'authentification ne soit pleinement
/// propagé au backend, ce qui renvoie un refus ponctuel même si
/// l'utilisateur est bien connecté. Sans cette relance, l'écran reste
/// bloqué sur "permission denied" indéfiniment au lieu de se corriger
/// de lui-même une fraction de seconde plus tard.
Stream<T> _retryOnAuthRace<T>(Stream<T> Function() open) async* {
  var attempt = 0;
  while (true) {
    try {
      yield* open();
      return;
    } on FirebaseException catch (e) {
      attempt++;
      if (e.code != 'permission-denied' || attempt >= 4) rethrow;
      await Future<void>.delayed(Duration(milliseconds: 400 * attempt));
    }
  }
}

/// Accès aux données partagées (Firestore) : contrats, paiements, pièces
/// jointes et réglages. Remplace l'ancienne base Drift locale — les mêmes
/// données sont désormais visibles depuis le mobile et le web.
class FirestoreService {
  final FirebaseFirestore _db;
  FirestoreService([FirebaseFirestore? db]) : _db = db ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _contracts => _db.collection('contracts');
  CollectionReference<Map<String, dynamic>> get _payments => _db.collection('payments');
  CollectionReference<Map<String, dynamic>> get _attachments => _db.collection('attachments');
  CollectionReference<Map<String, dynamic>> get _utilityBills => _db.collection('utilityBills');
  DocumentReference<Map<String, dynamic>> get _settingsDoc => _db.collection('settings').doc('app');

  // ---------- Réglages ----------
  Stream<AppSetting> watchSettings() {
    return _retryOnAuthRace(
      () => _settingsDoc.snapshots().map((doc) => AppSetting.fromMap(doc.data())),
    );
  }

  Future<void> updateSettings({
    int? reminderLeadMonths,
    String? currency,
    bool? onboardingDone,
  }) {
    return _settingsDoc.set({
      if (reminderLeadMonths != null) 'reminderLeadMonths': reminderLeadMonths,
      if (currency != null) 'currency': currency,
      if (onboardingDone != null) 'onboardingDone': onboardingDone,
    }, SetOptions(merge: true));
  }

  // ---------- Contrats ----------
  Stream<List<Contract>> watchContracts() {
    return _retryOnAuthRace(
      () => _contracts
          .where('archived', isEqualTo: false)
          .orderBy('endDate')
          .snapshots()
          .map((s) => s.docs.map(Contract.fromDoc).toList()),
    );
  }

  Stream<List<Contract>> watchVacantContracts() {
    return _retryOnAuthRace(
      () => _contracts
          .where('archived', isEqualTo: true)
          .orderBy('unitNumber')
          .snapshots()
          .map((s) => s.docs.map(Contract.fromDoc).toList()),
    );
  }

  Stream<List<Contract>> watchContractsForUnit(String unitNumber) {
    return _retryOnAuthRace(
      () => _contracts
          .where('unitNumber', isEqualTo: unitNumber)
          .orderBy('startDate', descending: true)
          .snapshots()
          .map((s) => s.docs.map(Contract.fromDoc).toList()),
    );
  }

  Future<String> createContract({
    required String tenantName,
    required String unitNumber,
    required DateTime startDate,
    required DateTime endDate,
    required double monthlyAmount,
    String? stegMeter,
    String? sonedeMeter,
    String notes = '',
  }) async {
    final id = newId();
    final contract = Contract(
      id: id,
      tenantName: tenantName,
      unitNumber: unitNumber,
      startDate: startDate,
      endDate: endDate,
      monthlyAmount: monthlyAmount,
      stegMeter: stegMeter,
      sonedeMeter: sonedeMeter,
      notes: notes,
      createdAt: DateTime.now(),
    );
    await _contracts.doc(id).set(contract.toMap());
    return id;
  }

  Future<void> updateContract(
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
    return _contracts.doc(id).update({
      'tenantName': tenantName,
      'unitNumber': unitNumber,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'monthlyAmount': monthlyAmount,
      'stegMeter': stegMeter,
      'sonedeMeter': sonedeMeter,
      'notes': notes,
    });
  }

  /// Marque le contrat comme clôturé : le locataire est sorti, le local
  /// passe en attente (vacant) jusqu'à un nouveau contrat.
  Future<void> setContractVacant(String id, bool vacant) {
    return _contracts.doc(id).update({'archived': vacant});
  }

  Future<void> deleteContract(String id) => _contracts.doc(id).delete();

  // ---------- Paiements ----------
  static DateTime monthKey(DateTime d) => DateTime(d.year, d.month, 1);

  static String paymentId(String contractId, DateTime month) =>
      '$contractId-${month.year}-${month.month.toString().padLeft(2, '0')}';

  Stream<List<Payment>> watchAllPayments() {
    return _retryOnAuthRace(
      () => _payments.snapshots().map((s) => s.docs.map(Payment.fromDoc).toList()),
    );
  }

  /// Lecture ponctuelle (hors flux) de tous les paiements — utilisée par
  /// l'export des contrats pour afficher le dernier loyer payé.
  Future<List<Payment>> fetchAllPaymentsOnce() async {
    final snap = await _payments.get();
    return snap.docs.map(Payment.fromDoc).toList();
  }

  /// Lecture ponctuelle de toutes les factures STEG/SONEDE — utilisée par
  /// l'export des contrats pour afficher le dernier règlement par compteur.
  Future<List<UtilityBill>> fetchAllUtilityBillsOnce() async {
    final snap = await _utilityBills.get();
    return snap.docs.map(UtilityBill.fromDoc).toList();
  }

  Stream<List<Payment>> watchPaymentsForContract(String contractId) {
    return _retryOnAuthRace(
      () => _payments
          .where('contractId', isEqualTo: contractId)
          .orderBy('month', descending: true)
          .snapshots()
          .map((s) => s.docs.map(Payment.fromDoc).toList()),
    );
  }

  /// Enregistre (ou met à jour) le paiement d'un mois donné pour un contrat.
  Future<void> markMonthPaid({
    required String contractId,
    required DateTime month,
    required double amount,
    required DateTime paidDate,
    String notes = '',
  }) {
    final key = monthKey(month);
    final payment = Payment(
      id: paymentId(contractId, key),
      contractId: contractId,
      month: key,
      amount: amount,
      paidDate: paidDate,
      notes: notes,
      createdAt: DateTime.now(),
    );
    return _payments.doc(payment.id).set(payment.toMap());
  }

  Future<void> markMonthUnpaid(String contractId, DateTime month) {
    return _payments.doc(paymentId(contractId, monthKey(month))).delete();
  }

  // ---------- Factures STEG / SONEDE ----------
  static String utilityBillId(String contractId, String type, DateTime month) {
    final key = monthKey(month);
    return '$contractId-$type-${key.year}-${key.month.toString().padLeft(2, '0')}';
  }

  /// Toutes les factures STEG/SONEDE réglées, tous contrats confondus —
  /// utilisée par la vue globale des locataires pour afficher le dernier
  /// règlement de chacun sans ouvrir chaque contrat.
  Stream<List<UtilityBill>> watchAllUtilityBills() {
    return _retryOnAuthRace(
      () => _utilityBills.snapshots().map((s) => s.docs.map(UtilityBill.fromDoc).toList()),
    );
  }

  Stream<List<UtilityBill>> watchUtilityBills(String contractId, String type) {
    return _retryOnAuthRace(
      () => _utilityBills
          .where('contractId', isEqualTo: contractId)
          .where('type', isEqualTo: type)
          .orderBy('month', descending: true)
          .snapshots()
          .map((s) => s.docs.map(UtilityBill.fromDoc).toList()),
    );
  }

  Future<void> markUtilityPaid({
    required String contractId,
    required String type,
    required DateTime month,
    double? amount,
    required DateTime paidDate,
  }) {
    final bill = UtilityBill(
      id: utilityBillId(contractId, type, month),
      contractId: contractId,
      type: type,
      month: monthKey(month),
      amount: amount,
      paidDate: paidDate,
      createdAt: DateTime.now(),
    );
    return _utilityBills.doc(bill.id).set(bill.toMap());
  }

  Future<void> markUtilityUnpaid(String contractId, String type, DateTime month) {
    return _utilityBills.doc(utilityBillId(contractId, type, month)).delete();
  }

  // ---------- Pièces jointes ----------
  Stream<List<Attachment>> watchAttachmentsForContract(String contractId) {
    return _retryOnAuthRace(
      () => _attachments
          .where('contractId', isEqualTo: contractId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((s) => s.docs.map(Attachment.fromDoc).toList()),
    );
  }

  Future<String> addAttachment({
    required String contractId,
    required String category,
    required String data,
  }) async {
    final id = newId();
    final attachment = Attachment(
      id: id,
      contractId: contractId,
      category: category,
      data: data,
      createdAt: DateTime.now(),
    );
    await _attachments.doc(id).set(attachment.toMap());
    return id;
  }

  Future<Attachment?> getAttachment(String id) async {
    final doc = await _attachments.doc(id).get();
    if (!doc.exists) return null;
    return Attachment.fromDoc(doc);
  }

  Future<void> deleteAttachment(String id) => _attachments.doc(id).delete();

  // ---------- Import (migration depuis l'ancienne base locale) ----------
  Future<void> importContract(Contract contract) {
    return _contracts.doc(contract.id).set(contract.toMap());
  }

  Future<void> importPayment(Payment payment) {
    return _payments.doc(payment.id).set(payment.toMap());
  }

  Future<void> importAttachment(Attachment attachment) {
    return _attachments.doc(attachment.id).set(attachment.toMap());
  }

  Future<bool> hasAnyContracts() async {
    final snap = await _contracts.limit(1).get();
    return snap.docs.isNotEmpty;
  }
}
