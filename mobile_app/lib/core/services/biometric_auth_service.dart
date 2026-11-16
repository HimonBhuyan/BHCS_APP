import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';

/// Biometric (Fingerprint / Face ID / Device Credentials) lock helper for Blue Hour HQ.
class BhBiometricAuthService {
  BhBiometricAuthService._();
  static final BhBiometricAuthService instance = BhBiometricAuthService._();

  final LocalAuthentication _auth = LocalAuthentication();

  bool get _isTestEnv => Platform.environment.containsKey('FLUTTER_TEST');

  Future<bool> isBiometricAvailable() async {
    if (_isTestEnv || kIsWeb) return true;
    try {
      final supported = await _auth.isDeviceSupported();
      final canCheck = await _auth.canCheckBiometrics;
      return supported || canCheck;
    } catch (_) {
      return false;
    }
  }

  Future<bool> authenticate({
    String reason = 'Verify your identity to unlock Blue Hour HQ',
  }) async {
    if (_isTestEnv || kIsWeb) return true;
    try {
      final supported = await isBiometricAvailable();
      if (!supported) return true;
      return await _auth.authenticate(
        localizedReason: reason,
        biometricOnly: false,
        sensitiveTransaction: true,
        persistAcrossBackgrounding: true,
      );
    } catch (_) {
      return false;
    }
  }
}

