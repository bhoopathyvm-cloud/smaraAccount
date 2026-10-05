import 'dart:typed_data';

import 'crypto_backend.dart';

export 'crypto_backend.dart' show KeyMaterial;

/// Ed25519 in this project's own vocabulary (byte arrays in, byte arrays
/// out) over the [CryptoBackend] seam, so the rest of the codebase never
/// depends on a crypto library's key-pair types, and Apple builds sign
/// through CryptoKit.
class Ed25519Signing {
  const Ed25519Signing({CryptoBackend? backend}) : _backend = backend;

  final CryptoBackend? _backend;

  CryptoBackend get _crypto => _backend ?? CryptoBackend.instance;

  /// The Ed25519 seed length in bytes. Secure storage and key generation
  /// both use exactly this many bytes as the deterministic private-key
  /// material.
  static const seedLength = 32;

  /// Generates a fresh, random key pair (first-install path - spec:
  /// "Device Signing Identity").
  Future<KeyMaterial> generateKeyPair() => _crypto.ed25519Generate();

  /// Deterministically derives the same key pair from a 32-byte seed every
  /// time it's called with the same seed (e.g. reloading the this-device
  /// key from secure storage after a relaunch).
  Future<KeyMaterial> keyPairFromSeed(List<int> seed) {
    if (seed.length < seedLength) {
      throw ArgumentError(
        'Seed must be at least $seedLength bytes, got ${seed.length}.',
      );
    }
    return _crypto.ed25519FromSeed(seed.sublist(0, seedLength));
  }

  /// Signs [message]. Signatures verify on every platform but are not
  /// byte-identical across backends (CryptoKit hedges them), so callers
  /// must never compare signature bytes - only verify them.
  Future<Uint8List> sign(
    List<int> message, {
    required List<int> privateKeySeed,
  }) {
    return _crypto.ed25519Sign(
      seed: privateKeySeed.sublist(0, seedLength),
      message: message,
    );
  }

  Future<bool> verify(
    List<int> message, {
    required List<int> signature,
    required List<int> publicKey,
  }) {
    return _crypto.ed25519Verify(
      publicKey: publicKey,
      message: message,
      signature: signature,
    );
  }
}
