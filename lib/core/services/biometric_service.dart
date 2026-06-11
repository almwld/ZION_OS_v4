import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;

class BiometricService {
  static final BiometricService _instance = BiometricService._internal();
  factory BiometricService() => _instance;
  BiometricService._internal();

  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _isAvailable = false;
  List<BiometricType> _availableBiometrics = [];

  Future<void> init() async {
    await checkBiometrics();
  }

  Future<bool> checkBiometrics() async {
    try {
      _isAvailable = await _localAuth.isDeviceSupported();
      if (_isAvailable) {
        _availableBiometrics = await _localAuth.getAvailableBiometrics();
      }
      return _isAvailable;
    } catch (e) {
      _isAvailable = false;
      return false;
    }
  }

  Future<bool> authenticate() async {
    if (!_isAvailable) return false;

    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Verify your identity to unlock Zion OS',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      return authenticated;
    } catch (e) {
      return false;
    }
  }

  bool get isBiometricAvailable => _isAvailable;
  bool get hasFingerprint => _availableBiometrics.contains(BiometricType.fingerprint);
  bool get hasFace => _availableBiometrics.contains(BiometricType.face);
  bool get hasIris => _availableBiometrics.contains(BiometricType.iris);
  String get biometricType {
    if (hasFingerprint) return 'Fingerprint';
    if (hasFace) return 'Face ID';
    if (hasIris) return 'Iris';
    return 'Biometric';
  }
}
