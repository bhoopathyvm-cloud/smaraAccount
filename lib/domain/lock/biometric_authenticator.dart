import 'package:local_auth/local_auth.dart';

/// Narrow interface over `local_auth` so [LockViewModel] is unit testable
/// with a pure-Dart fake instead of the real platform-channel-backed
/// plugin (same reasoning as `SecureKeyStorage` for `flutter_secure_storage`).
abstract class BiometricAuthenticator {
  Future<bool> isAvailable();
  Future<bool> authenticate({required String reason});
}

/// Production implementation, backed by `local_auth` (design.md Decision
/// 1). Offered where the platform has working biometrics or a device
/// credential fallback (`isDeviceSupported`) - never assumed available,
/// and never throws: a platform exception (missing hardware, no biometric
/// enrolled, iOS Simulator's `otherOperatingSystem` error, etc.) is
/// treated as "not available" / "not authenticated" rather than crashing
/// the lock screen.
class LocalAuthBiometricAuthenticator implements BiometricAuthenticator {
  LocalAuthBiometricAuthenticator([LocalAuthentication? localAuth])
    : _localAuth = localAuth ?? LocalAuthentication();

  final LocalAuthentication _localAuth;

  @override
  Future<bool> isAvailable() async {
    try {
      return await _localAuth.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> authenticate({required String reason}) async {
    try {
      return await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(stickyAuth: true),
      );
    } catch (_) {
      return false;
    }
  }
}
