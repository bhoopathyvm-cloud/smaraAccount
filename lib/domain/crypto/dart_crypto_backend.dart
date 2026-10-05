import 'dart:isolate';
import 'dart:math';

import 'package:crypto/crypto.dart' as dart_crypto;
import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';

import 'crypto_backend.dart';

/// [CryptoBackend] for Android, Windows and Linux: `package:cryptography`'s
/// pure-Dart AES-GCM, PBKDF2, Ed25519, HMAC and SHA-256 (plus
/// `package:crypto` for the one synchronous SHA-256 the Dart TLS socket's
/// certificate callback needs).
///
/// This is the only file under `lib/` that may import a Dart crypto
/// library (a unit test enforces it). In debug builds every operation
/// throws [DartCryptoOnApplePlatformError] when reached on iOS or macOS, so
/// an Apple build can never silently fall back to app-provided encryption
/// (design D6).
class DartCryptoBackend extends CryptoBackend {
  const DartCryptoBackend();

  @override
  String get name => 'dart';

  static final _aesGcm = AesGcm.with256bits();
  static final _ed25519 = Ed25519();
  static final _hmac = Hmac.sha256();
  static final _sha256 = Sha256();

  /// Fails loudly on Apple platforms in debug and test builds. Compiled out
  /// of release builds, where the startup selection alone decides.
  static void guardPlatform() {
    assert(() {
      if (!kIsWeb && isApplePlatform(defaultTargetPlatform)) {
        throw DartCryptoOnApplePlatformError(defaultTargetPlatform);
      }
      return true;
    }());
  }

  /// Synchronous SHA-256 hex digest for the Dart TLS socket's certificate
  /// callback, which cannot await. Not used on Apple platforms, where the
  /// Network-framework socket reports the fingerprint computed by CryptoKit.
  static String sha256HexSync(List<int> data) {
    guardPlatform();
    return dart_crypto.sha256.convert(data).toString();
  }

  @override
  Future<AesGcmBox> aesGcmEncrypt({
    required List<int> key,
    required List<int> plainText,
    List<int>? nonce,
    List<int> aad = const [],
  }) async {
    guardPlatform();
    final box = await _aesGcm.encrypt(
      plainText,
      secretKey: SecretKey(key),
      nonce: nonce ?? _randomNonce(),
      aad: aad,
    );
    return AesGcmBox(
      nonce: Uint8List.fromList(box.nonce),
      cipherText: Uint8List.fromList(box.cipherText),
      mac: Uint8List.fromList(box.mac.bytes),
    );
  }

  @override
  Future<Uint8List> aesGcmDecrypt({
    required List<int> key,
    required AesGcmBox box,
    List<int> aad = const [],
  }) async {
    guardPlatform();
    try {
      final plain = await _aesGcm.decrypt(
        SecretBox(box.cipherText, nonce: box.nonce, mac: Mac(box.mac)),
        secretKey: SecretKey(key),
        aad: aad,
      );
      return Uint8List.fromList(plain);
    } on SecretBoxAuthenticationError {
      throw const CryptoAuthenticationException();
    }
  }

  @override
  Future<Uint8List> pbkdf2HmacSha256({
    required List<int> password,
    required List<int> salt,
    required int iterations,
    int keyLength = 32,
  }) async {
    guardPlatform();
    // Run PBKDF2 off the platform/UI isolate: a long synchronous derive on
    // the isolate that services flutter_secure_storage's method channel has
    // been observed to interact badly with Keychain reads after a
    // same-process relaunch (acceptance-app-lock-unlock).
    final passwordCopy = Uint8List.fromList(password);
    final saltCopy = Uint8List.fromList(salt);
    return Isolate.run(() async {
      final key = await Pbkdf2.hmacSha256(
        iterations: iterations,
        bits: keyLength * 8,
      ).deriveKey(secretKey: SecretKey(passwordCopy), nonce: saltCopy);
      return Uint8List.fromList(await key.extractBytes());
    });
  }

  @override
  Future<KeyMaterial> ed25519Generate() async {
    guardPlatform();
    return _toKeyMaterial(await _ed25519.newKeyPair());
  }

  @override
  Future<KeyMaterial> ed25519FromSeed(List<int> seed) async {
    guardPlatform();
    return _toKeyMaterial(await _ed25519.newKeyPairFromSeed(seed));
  }

  @override
  Future<Uint8List> ed25519Sign({
    required List<int> seed,
    required List<int> message,
  }) async {
    guardPlatform();
    final keyPair = await _ed25519.newKeyPairFromSeed(seed);
    final signature = await _ed25519.sign(message, keyPair: keyPair);
    return Uint8List.fromList(signature.bytes);
  }

  @override
  Future<bool> ed25519Verify({
    required List<int> publicKey,
    required List<int> message,
    required List<int> signature,
  }) async {
    guardPlatform();
    if (signature.length != 64 || publicKey.length != 32) {
      return false;
    }
    return _ed25519.verify(
      message,
      signature: Signature(
        signature,
        publicKey: SimplePublicKey(publicKey, type: KeyPairType.ed25519),
      ),
    );
  }

  @override
  Future<Uint8List> hmacSha256({
    required List<int> key,
    required List<int> message,
  }) async {
    guardPlatform();
    final mac = await _hmac.calculateMac(message, secretKey: SecretKey(key));
    return Uint8List.fromList(mac.bytes);
  }

  @override
  Future<Uint8List> sha256(List<int> data) async {
    guardPlatform();
    final hash = await _sha256.hash(data);
    return Uint8List.fromList(hash.bytes);
  }

  @override
  Future<List<Uint8List>> sha256Many(List<List<int>> inputs) async {
    guardPlatform();
    final out = <Uint8List>[];
    for (final input in inputs) {
      out.add(await sha256(input));
    }
    return out;
  }

  static Future<KeyMaterial> _toKeyMaterial(SimpleKeyPair keyPair) async {
    final privateKeyBytes = await keyPair.extractPrivateKeyBytes();
    final publicKey = await keyPair.extractPublicKey();
    return KeyMaterial(
      privateKeySeed: Uint8List.fromList(privateKeyBytes),
      publicKey: Uint8List.fromList(publicKey.bytes),
    );
  }

  static Uint8List _randomNonce() {
    final random = Random.secure();
    return Uint8List.fromList(
      List<int>.generate(12, (_) => random.nextInt(256)),
    );
  }
}
