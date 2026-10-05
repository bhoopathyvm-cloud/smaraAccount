import 'package:flutter/services.dart';

/// Thrown by [SmaraAppleCrypto.aesGcmOpen] when the tag does not verify.
class AppleCryptoAuthenticationException implements Exception {
  const AppleCryptoAuthenticationException();

  @override
  String toString() =>
      'AppleCryptoAuthenticationException: AES-GCM authentication failed';
}

/// Output of [SmaraAppleCrypto.aesGcmSeal].
class AppleAesGcmSealed {
  const AppleAesGcmSealed({
    required this.nonce,
    required this.cipherText,
    required this.tag,
  });

  final Uint8List nonce;
  final Uint8List cipherText;
  final Uint8List tag;
}

/// An Ed25519 seed and the public key CryptoKit derives from it.
class AppleEd25519KeyPair {
  const AppleEd25519KeyPair({required this.seed, required this.publicKey});

  final Uint8List seed;
  final Uint8List publicKey;
}

/// CryptoKit / CommonCrypto primitives over the `smara_apple_crypto/crypto`
/// method channel. Every method runs the operation in the operating system
/// and returns raw bytes.
class SmaraAppleCrypto {
  // ignore: prefer_initializing_formals
  const SmaraAppleCrypto({MethodChannel? channel}) : _channel = channel;

  static const SmaraAppleCrypto instance = SmaraAppleCrypto();

  static const MethodChannel defaultChannel = MethodChannel(
    'smara_apple_crypto/crypto',
  );

  final MethodChannel? _channel;

  MethodChannel get _ch => _channel ?? defaultChannel;

  Future<AppleAesGcmSealed> aesGcmSeal({
    required Uint8List key,
    required Uint8List plainText,
    Uint8List? nonce,
    Uint8List? aad,
  }) async {
    final result = await _invokeMap('aesGcmSeal', {
      'key': key,
      'plainText': plainText,
      'nonce': ?nonce,
      if (aad != null && aad.isNotEmpty) 'aad': aad,
    });
    return AppleAesGcmSealed(
      nonce: result['nonce'] as Uint8List,
      cipherText: result['cipherText'] as Uint8List,
      tag: result['tag'] as Uint8List,
    );
  }

  Future<Uint8List> aesGcmOpen({
    required Uint8List key,
    required Uint8List nonce,
    required Uint8List cipherText,
    required Uint8List tag,
    Uint8List? aad,
  }) async {
    try {
      return await _invokeBytes('aesGcmOpen', {
        'key': key,
        'nonce': nonce,
        'cipherText': cipherText,
        'tag': tag,
        if (aad != null && aad.isNotEmpty) 'aad': aad,
      });
    } on PlatformException catch (e) {
      if (e.code == 'authentication_failed') {
        throw const AppleCryptoAuthenticationException();
      }
      rethrow;
    }
  }

  Future<Uint8List> pbkdf2HmacSha256({
    required Uint8List password,
    required Uint8List salt,
    required int iterations,
    required int keyLength,
  }) {
    return _invokeBytes('pbkdf2HmacSha256', {
      'password': password,
      'salt': salt,
      'iterations': iterations,
      'keyLength': keyLength,
    });
  }

  Future<AppleEd25519KeyPair> ed25519Generate() async {
    final result = await _invokeMap('ed25519Generate', const {});
    return AppleEd25519KeyPair(
      seed: result['seed'] as Uint8List,
      publicKey: result['publicKey'] as Uint8List,
    );
  }

  Future<Uint8List> ed25519PublicKey({required Uint8List seed}) =>
      _invokeBytes('ed25519PublicKey', {'seed': seed});

  Future<Uint8List> ed25519Sign({
    required Uint8List seed,
    required Uint8List message,
  }) => _invokeBytes('ed25519Sign', {'seed': seed, 'message': message});

  Future<bool> ed25519Verify({
    required Uint8List publicKey,
    required Uint8List message,
    required Uint8List signature,
  }) async {
    final ok = await _ch.invokeMethod<bool>('ed25519Verify', {
      'publicKey': publicKey,
      'message': message,
      'signature': signature,
    });
    return ok ?? false;
  }

  Future<Uint8List> hmacSha256({
    required Uint8List key,
    required Uint8List message,
  }) => _invokeBytes('hmacSha256', {'key': key, 'message': message});

  Future<Uint8List> sha256(Uint8List data) =>
      _invokeBytes('sha256', {'data': data});

  Future<List<Uint8List>> sha256Many(List<Uint8List> inputs) async {
    final result = await _ch.invokeListMethod<Object?>('sha256Many', {
      'inputs': inputs,
    });
    if (result == null) {
      throw PlatformException(
        code: 'no_result',
        message: 'sha256Many returned nothing',
      );
    }
    return [for (final item in result) item! as Uint8List];
  }

  Future<Uint8List> _invokeBytes(
    String method,
    Map<String, Object?> args,
  ) async {
    final result = await _ch.invokeMethod<Uint8List>(method, args);
    if (result == null) {
      throw PlatformException(
        code: 'no_result',
        message: '$method returned nothing',
      );
    }
    return result;
  }

  Future<Map<Object?, Object?>> _invokeMap(
    String method,
    Map<String, Object?> args,
  ) async {
    final result = await _ch.invokeMapMethod<Object?, Object?>(method, args);
    if (result == null) {
      throw PlatformException(
        code: 'no_result',
        message: '$method returned nothing',
      );
    }
    return result;
  }
}
