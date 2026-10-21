import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _pinHashKey = 'auth_pin_hash';
const _biometricEnabledKey = 'auth_biometric_enabled';
const _onboardingDoneKey = 'onboarding_done';

String hashPin(String pin) =>
    sha256.convert(utf8.encode('locatrack::$pin')).toString();

/// Hash du code PIN local (null tant qu'aucun code n'a été créé).
class PinController extends StateNotifier<String?> {
  PinController() : super(null);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getString(_pinHashKey);
  }

  Future<void> setPin(String pin) async {
    final hash = hashPin(pin);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pinHashKey, hash);
    state = hash;
  }

  bool verify(String pin) => state != null && state == hashPin(pin);

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pinHashKey);
    state = null;
  }
}

final pinControllerProvider =
    StateNotifierProvider<PinController, String?>((ref) => PinController());

final pinSetProvider = Provider<bool>((ref) => ref.watch(pinControllerProvider) != null);

/// Préférence utilisateur : autoriser le déverrouillage biométrique.
class BiometricPrefController extends StateNotifier<bool> {
  BiometricPrefController() : super(true);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_biometricEnabledKey) ?? true;
  }

  Future<void> set(bool enabled) async {
    state = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_biometricEnabledKey, enabled);
  }
}

final biometricEnabledProvider =
    StateNotifierProvider<BiometricPrefController, bool>((ref) => BiometricPrefController());

/// Session déverrouillée : repasse à false à chaque redémarrage de l'app.
final sessionAuthenticatedProvider = StateProvider<bool>((ref) => false);

/// Onboarding terminé (écran "Bienvenue" vu et validé) : réglage 100% local
/// (SharedPreferences), pas synchronisé via le cloud. Écrire ce drapeau
/// dans Firestore faisait dépendre la navigation post-onboarding d'un
/// aller-retour réseau — si la connexion était lente/coupée au mauvais
/// moment, l'écran restait bloqué indéfiniment sur le bouton "Commencer".
class OnboardingController extends StateNotifier<bool> {
  OnboardingController() : super(false);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_onboardingDoneKey) ?? false;
  }

  Future<void> complete() async {
    state = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingDoneKey, true);
  }
}

final onboardingControllerProvider =
    StateNotifierProvider<OnboardingController, bool>((ref) => OnboardingController());

final onboardingDoneProvider = Provider<bool>((ref) => ref.watch(onboardingControllerProvider));

/// Garantit que l'état d'authentification local est chargé avant de router.
final authReadyProvider = FutureProvider<void>((ref) async {
  await ref.read(pinControllerProvider.notifier).load();
  await ref.read(biometricEnabledProvider.notifier).load();
  await ref.read(onboardingControllerProvider.notifier).load();
});
