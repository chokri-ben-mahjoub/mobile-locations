import '../data/firestore_service.dart';

/// Implémentation web : il n'existe pas de données locales à migrer.
class LegacyMigrationService {
  Future<bool> hasLocalData() async => false;

  Future<int> migrateTo(FirestoreService cloudService) async => 0;
}
