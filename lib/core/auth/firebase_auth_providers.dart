import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:locations_app/l10n/app_localizations.dart';

/// Flux de l'utilisateur Firebase connecté (null si déconnecté).
final firebaseAuthStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

/// true une fois qu'un utilisateur Firebase est connecté. Tant que l'état
/// n'a pas encore été résolu, considéré comme non connecté (affiche l'écran
/// de connexion plutôt que de bloquer indéfiniment).
final firebaseSignedInProvider = Provider<bool>((ref) {
  return ref.watch(firebaseAuthStateProvider).valueOrNull != null;
});

class CloudAuthController {
  /// Retourne le code d'erreur Firebase brut (null si succès) — c'est à
  /// l'appelant (qui a accès à `AppLocalizations`) de le traduire pour
  /// l'affichage, voir `CloudLoginErrorCode.message`.
  Future<String?> signIn(String email, String password) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return e.code;
    }
  }

  Future<void> signOut() => FirebaseAuth.instance.signOut();
}

extension CloudLoginErrorCode on String {
  /// Traduit un code d'erreur Firebase Auth (voir [CloudAuthController.signIn])
  /// en message localisé.
  String toLoginErrorMessage(AppLocalizations l10n) {
    switch (this) {
      case 'invalid-email':
        return l10n.invalidEmail;
      case 'user-not-found':
      case 'invalid-credential':
      case 'wrong-password':
        return l10n.wrongCredentials;
      case 'user-disabled':
        return l10n.accountDisabled;
      case 'too-many-requests':
        return l10n.tooManyAttempts;
      case 'network-request-failed':
        return l10n.noInternet;
      default:
        return l10n.signInFailedCode(this);
    }
  }
}

final cloudAuthControllerProvider = Provider<CloudAuthController>((ref) {
  return CloudAuthController();
});
