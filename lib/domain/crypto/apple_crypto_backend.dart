import 'dart:typed_data';

import 'package:smara_apple_crypto/smara_apple_crypto.dart';

import 'crypto_backend.dart';

/// [CryptoBackend] for iOS and macOS: every operation is carried out by
/// Apple's frameworks (CryptoKit `AES.GCM`, `Curve25519.Signing`,
/// `HMAC<SHA256>`, `SHA256`; CommonCrypto `CCKeyDerivationPBKDF`) through the
/// in-repo `smara_apple_crypto` plugin (design D2). Nothing here touches a
/// Dart crypto library, so the App Store builds' `ITSAppUsesNonExemptEncryption
/// = false` declaration stays true.
class AppleCryptoBackend extends CryptoBackend {
  const AppleCryptoBackend({SmaraAppleCrypto? plugin}) : _plugin = plugin;

  final SmaraAppleCrypto? _plugin;

  SmaraAppleCrypto get _os => _plugin ?? SmaraAppleCrypto.instance;

  @override
  String get name => 'apple';

  @override
  Future<AesGcmBox> aesGcmEncrypt({
    required List<int> key,
    required List<int> plainText,
    List<int>? nonce,
    List<int> aad = const [],
  }) async {
    final sealed = await _os.aesGcmSeal(
      key: Uint8List.fromList(key),
      plainText: Uint8List.fromList(plainText),
      nonce: nonce == null ? null : Uint8List.fromList(nonce),
      aad: Uint8List.fromList(aad),
    );
    return AesGcmBox(
      nonce: sealed.nonce,
      cipherText: sealed.cipherText,
      mac: sealed.tag,
    );
  }

  @override
  Future<Uint8List> aesGcmDecrypt({
    required List<int> key,
    required AesGcmBox box,
    List<int> aad = const [],
  }) async {
    try {
      return await _os.aesGcmOpen(
        key: Uint8List.fromList(key),
        nonce: box.nonce,
        cipherText: box.cipherText,
        tag: box.mac,
        aad: Uint8List.fromList(aad),
      );
    } on AppleCryptoAuthenticationException {
      throw const CryptoAuthenticationException();
    }
  }

  @override
  Future<Uint8List> pbkdf2HmacSha256({
    required List<int> password,
    required List<int> salt,
    required int iterations,
    int keyLength = 32,
  }) {
    return _os.pbkdf2HmacSha256(
      password: Uint8List.fromList(password),
      salt: Uint8List.fromList(salt),
      iterations: iterations,
      keyLength: keyLength,
    );
  }

  @override
  Future<KeyMaterial> ed25519Generate() async {
    final pair = await _os.ed25519Generate();
    return KeyMaterial(privateKeySeed: pair.seed, publicKey: pair.publicKey);
  }

  @override
  Future<KeyMaterial> ed25519FromSeed(List<int> seed) async {
    final seedBytes = Uint8List.fromList(seed);
    final publicKey = await _os.ed25519PublicKey(seed: seedBytes);
    return KeyMaterial(privateKeySeed: seedBytes, publicKey: publicKey);
  }

  @override
  Future<Uint8List> ed25519Sign({
    required List<int> seed,
    required List<int> message,
  }) {
    return _os.ed25519Sign(
      seed: Uint8List.fromList(seed),
      message: Uint8List.fromList(message),
    );
  }

  @override
  Future<bool> ed25519Verify({
    required List<int> publicKey,
    required List<int> message,
    required List<int> signature,
  }) {
    if (signature.length != 64 || publicKey.length != 32) {
      return Future.value(false);
    }
    return _os.ed25519Verify(
      publicKey: Uint8List.fromList(publicKey),
      message: Uint8List.fromList(message),
      signature: Uint8List.fromList(signature),
    );
  }

  @override
  Future<Uint8List> hmacSha256({
    required List<int> key,
    required List<int> message,
  }) {
    return _os.hmacSha256(
      key: Uint8List.fromList(key),
      message: Uint8List.fromList(message),
    );
  }

  @override
  Future<Uint8List> sha256(List<int> data) =>
      _os.sha256(Uint8List.fromList(data));

  @override
  Future<List<Uint8List>> sha256Many(List<List<int>> inputs) {
    if (inputs.isEmpty) return Future.value(const []);
    return _os.sha256Many([for (final i in inputs) Uint8List.fromList(i)]);
  }
}
