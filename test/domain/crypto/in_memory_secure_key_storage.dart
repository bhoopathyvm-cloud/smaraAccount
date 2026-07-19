import 'package:smara_accounting/domain/crypto/secure_key_storage.dart';

/// Pure-Dart fake for [SecureKeyStorage], used in tests in place of the
/// real platform-channel-backed `flutter_secure_storage` plugin.
class InMemorySecureKeyStorage implements SecureKeyStorage {
  final Map<String, String> _values = {};

  @override
  Future<String?> read(String key) async => _values[key];

  @override
  Future<void> write(String key, String value) async => _values[key] = value;

  @override
  Future<void> delete(String key) async => _values.remove(key);
}
