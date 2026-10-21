import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> get isAvailable async {
    if (kIsWeb) return false;
    try {
      final supported = await _auth.isDeviceSupported();
      final canCheck = await _auth.canCheckBiometrics;
      return supported && canCheck;
    } catch (_) {
      return false;
    }
  }

  /// Retourne true si authentifié, false si annulé/échoué.
  Future<bool> authenticate() async {
    if (kIsWeb) return false;
    try {
      return await _auth.authenticate(
        localizedReason: 'Authentifiez-vous pour accéder à LocaTrack',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );
    } on Exception catch (e) {
      if (e.toString().contains(auth_error.notAvailable) ||
          e.toString().contains(auth_error.notEnrolled)) {
        return false;
      }
      return false;
    }
  }
}

final biometricService = BiometricService();
