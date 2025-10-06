// ignore_for_file: avoid_print

import 'package:local_auth/local_auth.dart';

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  /// Check if biometrics are available
  Future<bool> canCheckBiometrics() async {
    try {
      return await _auth.canCheckBiometrics;
    } catch (e) {
      print("Biometric check error: $e");
      return false;
    }
  }

  /// Authenticate with fingerprint or face ID
  Future<bool> authenticateUser() async {
    try {
      final isAvailable = await canCheckBiometrics();
      if (!isAvailable) return false;

      final didAuthenticate = await _auth.authenticate(
        localizedReason: 'Confirm your identity to complete checkout',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );
      return didAuthenticate;
    } catch (e) {
      print("Authentication error: $e");
      return false;
    }
  }
}
