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
///
/// iOS/macOS: this-device-only, non-synchronizable accessibility so the
/// private key never travels in iCloud, Finder, or Quick Start transfers
/// (ADR 0004 / books-copy-and-continuation).
///
/// macOS: `usesDataProtectionKeychain: false` opts out of
/// `kSecUseDataProtectionKeychain`, which otherwise makes `SecItemAdd`
/// hang indefinitely (never erroring, never returning) unless the app is
/// signed under a real Apple Developer Team ID with a matching
/// `keychain-access-groups` entitlement - not available for local/ad-hoc
/// signed runs. This falls back to the legacy file-based Keychain API,
/// which works under ad-hoc signing (ADR 0001).
class FlutterSecureKeyStorage implements SecureKeyStorage {
  FlutterSecureKeyStorage([FlutterSecureStorage? storage])
    : _storage =
          storage ??
          FlutterSecureStorage(
            iOptions: defaultIosOptions,
            mOptions: defaultMacOsOptions,
          );

  /// Options used for iOS Keychain items. Visible for unit tests.
  static const IOSOptions defaultIosOptions = IOSOptions(
    accessibility: KeychainAccessibility.unlocked_this_device,
    synchronizable: false,
  );

  /// Options used for macOS Keychain items. Visible for unit tests.
  static const MacOsOptions defaultMacOsOptions = MacOsOptions(
    accessibility: KeychainAccessibility.unlocked_this_device,
    synchronizable: false,
    usesDataProtectionKeychain: false,
  );

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}
