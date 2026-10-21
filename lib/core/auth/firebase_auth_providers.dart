import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  Future<String?> signIn(String email, String password) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
          return 'Adresse e-mail invalide.';
        case 'user-not-found':
        case 'invalid-credential':
        case 'wrong-password':
          return 'E-mail ou mot de passe incorrect.';
        case 'user-disabled':
          return 'Ce compte a été désactivé.';
        case 'too-many-requests':
          return 'Trop de tentatives, réessayez plus tard.';
        case 'network-request-failed':
          return 'Pas de connexion internet.';
        default:
          return 'Connexion impossible (${e.code}).';
      }
    }
  }

  Future<void> signOut() => FirebaseAuth.instance.signOut();
}

final cloudAuthControllerProvider = Provider<CloudAuthController>((ref) {
  return CloudAuthController();
});
