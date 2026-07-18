import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

/// Thin wrapper around `package:cryptography`'s Ed25519 so the rest of the
/// codebase depends on this project's own vocabulary (byte arrays in, byte
/// arrays out) rather than the package's key-pair/key-material types
/// directly.
class Ed25519Signing {
  const Ed25519Signing();

  static final _algorithm = Ed25519();

  /// The Ed25519 seed length in bytes. [RecoveryPhrase.seed] and the
  /// keystore file format both carry exactly this many bytes as the
  /// deterministic private-key material.
  static const seedLength = 32;

  /// Generates a fresh, random key pair (first-install path - spec:
  /// "Device Signing Identity").
  Future<KeyMaterial> generateKeyPair() async {
    final keyPair = await _algorithm.newKeyPair();
    return _toKeyMaterial(keyPair);
  }

  /// Deterministically derives the same key pair from a 32-byte seed every
  /// time it's called with the same seed (recovery-phrase / keystore-file
  /// re-derivation path - spec: "Recoverable Reinstall or Device
  /// Migration").
  Future<KeyMaterial> keyPairFromSeed(List<int> seed) async {
    if (seed.length < seedLength) {
      throw ArgumentError(
        'Seed must be at least $seedLength bytes, got ${seed.length}.',
      );
    }
    final keyPair = await _algorithm.newKeyPairFromSeed(
      seed.sublist(0, seedLength),
    );
    return _toKeyMaterial(keyPair);
  }

  Future<KeyMaterial> _toKeyMaterial(SimpleKeyPair keyPair) async {
    final privateKeyBytes = await keyPair.extractPrivateKeyBytes();
    final publicKey = await keyPair.extractPublicKey();
    return KeyMaterial(
      privateKeySeed: Uint8List.fromList(privateKeyBytes),
      publicKey: Uint8List.fromList(publicKey.bytes),
    );
  }

  Future<Uint8List> sign(
    List<int> message, {
    required List<int> privateKeySeed,
  }) async {
    final keyPair = await _algorithm.newKeyPairFromSeed(privateKeySeed);
    final signature = await _algorithm.sign(message, keyPair: keyPair);
    return Uint8List.fromList(signature.bytes);
  }

  Future<bool> verify(
    List<int> message, {
    required List<int> signature,
    required List<int> publicKey,
  }) {
    return _algorithm.verify(
      message,
      signature: Signature(
        signature,
        publicKey: SimplePublicKey(publicKey, type: KeyPairType.ed25519),
      ),
    );
  }
}

/// A generated or re-derived Ed25519 key pair. [privateKeySeed] must never
/// be persisted anywhere except OS secure storage (spec: "The private key
/// SHALL NOT be written to the SQLite database under any circumstance").
class KeyMaterial {
  const KeyMaterial({required this.privateKeySeed, required this.publicKey});

  final Uint8List privateKeySeed;
  final Uint8List publicKey;
}
