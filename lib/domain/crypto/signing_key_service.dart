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
class SigningKeyService {
  SigningKeyService({SecureKeyStorage? secureStorage, Ed25519Signing? signer})
    : _secureStorage = secureStorage ?? FlutterSecureKeyStorage(),
      _signer = signer ?? const Ed25519Signing();

  static const privateKeySeedStorageKey = 'ledger_signing_private_key_seed';

  final SecureKeyStorage _secureStorage;
  final Ed25519Signing _signer;

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
  /// falsely match (or mismatch) the restored books.
  Future<void> deleteStoredKey() {
    return _secureStorage.delete(privateKeySeedStorageKey);
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
    try {
      await _secureStorage.write(privateKeySeedStorageKey, encoded);
      final readBack = await _secureStorage.read(privateKeySeedStorageKey);
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

  Future<List<int>?> _readStoredSeed() async {
    final encoded = await _secureStorage.read(privateKeySeedStorageKey);
    if (encoded == null) return null;
    return base64Decode(encoded);
  }

  Future<void> _storeSeed(List<int> seed) {
    return _secureStorage.write(
      privateKeySeedStorageKey,
      base64Encode(seed),
    );
  }
}

/// A freshly generated identity: the key material stored this-device-only.
class GeneratedIdentity {
  const GeneratedIdentity({required this.keyMaterial});

  final KeyMaterial keyMaterial;
}
