import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';

import '../crypto/secure_key_storage.dart';

/// Stores and verifies the app-lock PIN (app-lock), never the PIN itself -
/// only a salted PBKDF2 hash, same OS-protected secure storage already
/// trusted for the signing private key. A PIN is a much weaker secret than
/// the signing key, but the storage mechanism and salted-hash discipline
/// are the same for consistency with this app's one existing
/// crypto-storage pattern (design.md Decision 1).
class AppLockService {
  AppLockService({SecureKeyStorage? secureStorage})
    : _secureStorage = secureStorage ?? const FlutterSecureKeyStorage();

  final SecureKeyStorage _secureStorage;

  static const _pinRecordStorageKey = 'app_lock_pin_record';
  static const _iterations = 210000;
  static const _saltLength = 16;

  Future<bool> hasPinSet() async {
    return (await _secureStorage.read(_pinRecordStorageKey)) != null;
  }

  Future<void> setPin(String pin) async {
    final random = Random.secure();
    final salt = List<int>.generate(_saltLength, (_) => random.nextInt(256));
    final hash = await _deriveHash(
      pin: pin,
      salt: salt,
      iterations: _iterations,
    );
    await _secureStorage.write(
      _pinRecordStorageKey,
      jsonEncode({
        'iterations': _iterations,
        'salt': base64Encode(salt),
        'hash': base64Encode(hash),
      }),
    );
  }

  /// True if [pin] matches the stored PIN. False (never throws) if no PIN
  /// has been set yet.
  Future<bool> verifyPin(String pin) async {
    final stored = await _secureStorage.read(_pinRecordStorageKey);
    if (stored == null) return false;
    final record = jsonDecode(stored) as Map<String, dynamic>;
    final salt = base64Decode(record['salt'] as String);
    final iterations = record['iterations'] as int;
    final expectedHash = base64Decode(record['hash'] as String);
    final actualHash = await _deriveHash(
      pin: pin,
      salt: salt,
      iterations: iterations,
    );
    return _bytesEqual(actualHash, expectedHash);
  }

  Future<void> clearPin() => _secureStorage.delete(_pinRecordStorageKey);

  Future<List<int>> _deriveHash({
    required String pin,
    required List<int> salt,
    required int iterations,
  }) async {
    final secretKey = await Pbkdf2.hmacSha256(
      iterations: iterations,
      bits: 256,
    ).deriveKeyFromPassword(password: pin, nonce: salt);
    return secretKey.extractBytes();
  }
}

bool _bytesEqual(List<int> a, List<int> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
