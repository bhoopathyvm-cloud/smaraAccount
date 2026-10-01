import 'package:smara_accounting/domain/crypto/secure_key_storage.dart';

/// Pure-Dart fake for [SecureKeyStorage], used in tests in place of the
/// real platform-channel-backed `flutter_secure_storage` plugin.
class InMemorySecureKeyStorage implements SecureKeyStorage {
  final Map<String, String> _values = {};

  /// When non-null, the next [write] throws this error (and clears the
  /// flag). Used to exercise the key-accessibility re-save failure path.
  Object? failNextWriteWith;

  /// When true, [read] returns a different value only after at least one
  /// successful [write] since the flag was set — so an initial read of
  /// the existing key still succeeds, then the re-save read-back fails.
  bool corruptReadBackAfterWrite = false;

  /// When true, [delete] of a key that isn't stored throws, like the
  /// macOS legacy Keychain does (errSecMissingEntitlement, -34018).
  bool throwOnDeleteOfMissingKey = false;

  int writeCount = 0;
  int _writesSinceCorruptFlag = 0;

  @override
  Future<String?> read(String key) async {
    final value = _values[key];
    if (corruptReadBackAfterWrite &&
        _writesSinceCorruptFlag > 0 &&
        value != null) {
      return 'corrupted-$value';
    }
    return value;
  }

  @override
  Future<void> write(String key, String value) async {
    writeCount++;
    final fail = failNextWriteWith;
    if (fail != null) {
      failNextWriteWith = null;
      throw fail;
    }
    _values[key] = value;
    if (corruptReadBackAfterWrite) {
      _writesSinceCorruptFlag++;
    }
  }

  @override
  Future<void> delete(String key) async {
    if (throwOnDeleteOfMissingKey && !_values.containsKey(key)) {
      throw StateError('no keychain item for $key');
    }
    _values.remove(key);
  }
}
