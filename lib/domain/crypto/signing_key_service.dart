import 'dart:convert';
import 'dart:typed_data';

import 'ed25519_signing.dart';
import 'secure_key_storage.dart';

/// Orchestrates the device signing key's lifecycle: generation, this-device-
/// only secure storage, signing, and the one-time accessibility re-save
/// (ADR 0004 / books-copy-and-continuation).
///
/// Never touches Drift - the private key is stored exclusively in OS
/// secure storage (Keychain/Keystore/DPAPI, via [SecureKeyStorage]), never
/// the SQLite database. Callers (the Repository layer) own persisting the
/// resulting *public* key into `signing_identities`.
///
/// The private key never leaves the device: there is no recovery phrase,
/// keystore file, or migration-bundle export.
///
/// When [booksSetId] is set (or [resolveBooksSetId] returns one), the seed
/// is stored under a namespaced key so several books sets on one device
/// stay fully separate (linked-devices design Decision 4).
class SigningKeyService {
  SigningKeyService({
    SecureKeyStorage? secureStorage,
    Ed25519Signing? signer,
    String? booksSetId,
    Future<String?> Function()? resolveBooksSetId,
  }) : _secureStorage = secureStorage ?? FlutterSecureKeyStorage(),
       _signer = signer ?? const Ed25519Signing(),
       _booksSetId = booksSetId,
       _resolveBooksSetId = resolveBooksSetId;

  static const privateKeySeedStorageKey = 'ledger_signing_private_key_seed';

  /// Secure-storage key for a specific books set's private seed.
  static String storageKeyFor(String booksSetId) =>
      '$privateKeySeedStorageKey:$booksSetId';

  /// Moves a pre-multi-set seed to the namespaced key for [booksSetId].
  /// Idempotent when the namespaced key already exists.
  static Future<void> migrateLegacyKeyToBooksSet({
    required SecureKeyStorage secureStorage,
    required String booksSetId,
  }) async {
    final namespaced = storageKeyFor(booksSetId);
    final existing = await secureStorage.read(namespaced);
    final legacy = await secureStorage.read(privateKeySeedStorageKey);
    if (legacy == null) return;
    if (existing == null) {
      await secureStorage.write(namespaced, legacy);
    }
    await secureStorage.delete(privateKeySeedStorageKey);
  }

  final SecureKeyStorage _secureStorage;
  final Ed25519Signing _signer;
  final String? _booksSetId;
  final Future<String?> Function()? _resolveBooksSetId;

  /// The key material currently in secure storage, if any. Null means no
  /// identity has been generated on this device yet, or the device's
  /// secure storage was cleared independently of the database.
  Future<KeyMaterial?> loadStoredKeyMaterial() async {
    final seed = await _readStoredSeed();
    if (seed == null) return null;
    return _signer.keyPairFromSeed(seed);
  }

  /// Generates a brand-new Ed25519 key pair and stores the private seed
  /// this-device-only. Returns the key material so callers can persist the
  /// public half as a signing identity.
  Future<GeneratedIdentity> generateNewIdentity() async {
    final keyMaterial = await _signer.generateKeyPair();
    await _storeSeed(keyMaterial.privateKeySeed);
    return GeneratedIdentity(keyMaterial: keyMaterial);
  }

  /// Deletes any private key still in secure storage. Used after a Books
  /// Copy restore so an orphaned previous-device key cannot linger and
  /// falsely match (or mismatch) the restored books, and when removing a
  /// books set from the device.
  Future<void> deleteStoredKey() async {
    final key = await _storageKey();
    await _secureStorage.delete(key);
  }

  /// One-time re-save of the private key under this-device-only Keychain
  /// options (design Decision 7). Read → write → read-back → compare;
  /// only then call [markMigrated]. On any failure the old item is kept
  /// and migration is retried on the next launch.
  Future<bool> migrateKeyAccessibilityIfNeeded({
    required bool alreadyMigrated,
    required Future<void> Function() markMigrated,
  }) async {
    if (alreadyMigrated) return false;
    final seed = await _readStoredSeed();
    if (seed == null) {
      await markMigrated();
      return false;
    }
    final encoded = base64Encode(seed);
    final key = await _storageKey();
    try {
      await _secureStorage.write(key, encoded);
      final readBack = await _secureStorage.read(key);
      if (readBack != encoded) {
        return false;
      }
      await markMigrated();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Signs [message] with the currently stored private key. Throws
  /// [StateError] if no key is currently stored.
  Future<Uint8List> sign(List<int> message) async {
    final seed = await _readStoredSeed();
    if (seed == null) {
      throw StateError(
        'No signing identity is currently stored on this device.',
      );
    }
    return _signer.sign(message, privateKeySeed: seed);
  }

  Future<bool> verify(
    List<int> message, {
    required List<int> signature,
    required List<int> publicKey,
  }) {
    return _signer.verify(message, signature: signature, publicKey: publicKey);
  }

  Future<String> _storageKey() async {
    if (_booksSetId != null) return storageKeyFor(_booksSetId!);
    if (_resolveBooksSetId != null) {
      final id = await _resolveBooksSetId!();
      if (id != null) return storageKeyFor(id);
    }
    return privateKeySeedStorageKey;
  }

  Future<List<int>?> _readStoredSeed() async {
    final key = await _storageKey();
    var encoded = await _secureStorage.read(key);
    // Pre-multi-set installs may still hold the legacy key until
    // [migrateLegacyKeyToBooksSet] runs.
    if (encoded == null && key != privateKeySeedStorageKey) {
      encoded = await _secureStorage.read(privateKeySeedStorageKey);
    }
    if (encoded == null) return null;
    return base64Decode(encoded);
  }

  Future<void> _storeSeed(List<int> seed) async {
    final key = await _storageKey();
    await _secureStorage.write(key, base64Encode(seed));
  }
}

/// A freshly generated identity: the key material stored this-device-only.
class GeneratedIdentity {
  const GeneratedIdentity({required this.keyMaterial});

  final KeyMaterial keyMaterial;
}
