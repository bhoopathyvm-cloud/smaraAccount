import 'package:flutter/foundation.dart';

import 'apple_crypto_backend.dart';
import 'dart_crypto_backend.dart';

/// The one seam through which the app performs cryptography (os-provided-
/// encryption design D1).
///
/// Two implementations exist: [DartCryptoBackend] wraps `package:cryptography`
/// for Android, Windows and Linux; [AppleCryptoBackend] calls CryptoKit and
/// CommonCrypto through the in-repo `smara_apple_crypto` plugin on iOS and
/// macOS, so App Store builds encrypt only through the operating system. No
/// file outside `dart_crypto_backend.dart` imports a Dart crypto library.
///
/// The backend is chosen once at startup ([selectCryptoBackend]) and made
/// available through [instance] for call sites that have no constructor
/// (static helpers and top-level functions) and through the provider tree
/// for services that do.
abstract class CryptoBackend {
  const CryptoBackend();

  static CryptoBackend? _instance;

  /// The process-wide backend. Resolved lazily from the platform the first
  /// time it is read unless [use] was called earlier.
  static CryptoBackend get instance => _instance ??= selectCryptoBackend();

  /// Installs [backend] as the process-wide backend. Called once at startup
  /// and by tests that need a specific backend.
  static void use(CryptoBackend backend) => _instance = backend;

  /// Forgets the installed backend so the next [instance] read selects one
  /// from the platform again. Test teardown helper.
  static void reset() => _instance = null;

  /// Short identifier for diagnostics: `dart` or `apple`.
  String get name;

  /// AES-256-GCM seal. [nonce] is 12 bytes; a fresh random one is generated
  /// when omitted. The returned box carries the 16-byte tag separately so
  /// the Books Copy layout (`nonce`, `cipherText`, `mac`) is unchanged.
  Future<AesGcmBox> aesGcmEncrypt({
    required List<int> key,
    required List<int> plainText,
    List<int>? nonce,
    List<int> aad = const [],
  });

  /// AES-256-GCM open. Throws [CryptoAuthenticationException] when the tag
  /// does not verify (wrong key or tampered data).
  Future<Uint8List> aesGcmDecrypt({
    required List<int> key,
    required AesGcmBox box,
    List<int> aad = const [],
  });

  /// PBKDF2-HMAC-SHA256 of [password] with [salt], [iterations] rounds and
  /// a [keyLength]-byte output.
  Future<Uint8List> pbkdf2HmacSha256({
    required List<int> password,
    required List<int> salt,
    required int iterations,
    int keyLength = 32,
  });

  /// A fresh Ed25519 key pair from the OS random source.
  Future<KeyMaterial> ed25519Generate();

  /// The Ed25519 key pair for a 32-byte RFC 8032 seed.
  Future<KeyMaterial> ed25519FromSeed(List<int> seed);

  /// Ed25519 signature of [message] by the key derived from [seed].
  /// Signatures verify everywhere but are not byte-identical across backends
  /// (CryptoKit hedges them), so never compare signature bytes.
  Future<Uint8List> ed25519Sign({
    required List<int> seed,
    required List<int> message,
  });

  Future<bool> ed25519Verify({
    required List<int> publicKey,
    required List<int> message,
    required List<int> signature,
  });

  Future<Uint8List> hmacSha256({
    required List<int> key,
    required List<int> message,
  });

  Future<Uint8List> sha256(List<int> data);

  /// SHA-256 of each input in one call. Chain verification hashes thousands
  /// of entries, so this keeps platform-channel overhead to one round trip.
  Future<List<Uint8List>> sha256Many(List<List<int>> inputs);
}

/// Output of an AES-GCM seal: nonce, ciphertext and the authentication tag.
class AesGcmBox {
  const AesGcmBox({
    required this.nonce,
    required this.cipherText,
    required this.mac,
  });

  final Uint8List nonce;
  final Uint8List cipherText;
  final Uint8List mac;
}

/// A generated or re-derived Ed25519 key pair. [privateKeySeed] must never
/// be persisted anywhere except OS secure storage (spec: "The private key
/// SHALL NOT be written to the SQLite database under any circumstance").
class KeyMaterial {
  const KeyMaterial({required this.privateKeySeed, required this.publicKey});

  final Uint8List privateKeySeed;
  final Uint8List publicKey;
}

/// Thrown when authenticated decryption fails: a wrong key or passphrase,
/// or a ciphertext that was altered. Both backends throw this same type.
class CryptoAuthenticationException implements Exception {
  const CryptoAuthenticationException([
    this.message = 'Authenticated decryption failed.',
  ]);

  final String message;

  @override
  String toString() => 'CryptoAuthenticationException: $message';
}

/// Thrown when the Dart crypto implementation is reached on a platform that
/// must only encrypt through the operating system (design D6).
class DartCryptoOnApplePlatformError extends StateError {
  DartCryptoOnApplePlatformError(TargetPlatform platform)
    : super(
        'DartCryptoBackend was reached on $platform. Apple builds must '
        'encrypt only through the operating system (AppleCryptoBackend).',
      );
}

/// True for the platforms whose App Store builds declare that they use only
/// the operating system's encryption.
bool isApplePlatform(TargetPlatform platform) =>
    platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;

/// Chooses the backend for [platform] (default: the running platform):
/// [AppleCryptoBackend] on iOS and macOS, [DartCryptoBackend] elsewhere.
CryptoBackend selectCryptoBackend({TargetPlatform? platform}) {
  final target = platform ?? defaultTargetPlatform;
  if (!kIsWeb && isApplePlatform(target)) {
    return const AppleCryptoBackend();
  }
  return const DartCryptoBackend();
}

/// Debug-only startup check (design D6): on iOS and macOS the installed
/// backend must be the operating system's. Throws
/// [DartCryptoOnApplePlatformError] otherwise; a no-op in release builds.
void debugCheckCryptoBackendMatchesPlatform({TargetPlatform? platform}) {
  assert(() {
    final target = platform ?? defaultTargetPlatform;
    if (!kIsWeb &&
        isApplePlatform(target) &&
        CryptoBackend.instance is! AppleCryptoBackend) {
      throw DartCryptoOnApplePlatformError(target);
    }
    return true;
  }());
}
