import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Narrow key-value storage abstraction so [SigningKeyService] can be unit
/// tested with a pure-Dart fake instead of the real platform-channel-backed
/// `flutter_secure_storage` plugin.
abstract class SecureKeyStorage {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

/// Production implementation, backed by OS secure storage
/// (Keychain/Keystore/DPAPI).
class FlutterSecureKeyStorage implements SecureKeyStorage {
  const FlutterSecureKeyStorage([this._storage = const FlutterSecureStorage()]);

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}
