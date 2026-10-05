import 'package:flutter/services.dart';

/// The device's TLS identity in the Keychain, over the
/// `smara_apple_crypto/identity` method channel (Security framework).
///
/// The private key is created by `SecKeyCreateRandomKey` as a permanent,
/// non-synchronizable, this-device-only Keychain item and never leaves it:
/// Dart only ever receives the public key and signatures.
class AppleKeychainIdentity {
  // ignore: prefer_initializing_formals
  const AppleKeychainIdentity({MethodChannel? channel}) : _channel = channel;

  static const AppleKeychainIdentity instance = AppleKeychainIdentity();

  static const MethodChannel defaultChannel = MethodChannel(
    'smara_apple_crypto/identity',
  );

  final MethodChannel? _channel;

  MethodChannel get _ch => _channel ?? defaultChannel;

  /// Creates an RSA-2048 key pair under [label] (replacing any existing key
  /// with that label) and returns the public key as PKCS#1 `RSAPublicKey`
  /// DER.
  Future<Uint8List> createRsaKey({required String label, int bits = 2048}) =>
      _bytes('createRsaKey', {'label': label, 'bits': bits});

  /// PKCS#1 `RSAPublicKey` DER of the key under [label], or null when no key
  /// exists.
  Future<Uint8List?> publicKey({required String label}) =>
      _ch.invokeMethod<Uint8List>('publicKey', {'label': label});

  /// RSASSA-PKCS1-v1_5 with SHA-256 over [data], computed by the Security
  /// framework with the private key under [label].
  Future<Uint8List> signPkcs1Sha256({
    required String label,
    required Uint8List data,
  }) => _bytes('signPkcs1Sha256', {'label': label, 'data': data});

  /// Stores certificate [der] in the Keychain next to the key under [label]
  /// so the Security framework can pair them into a `SecIdentity` for TLS.
  Future<void> storeCertificate({
    required String label,
    required Uint8List der,
  }) =>
      _ch.invokeMethod<void>('storeCertificate', {'label': label, 'der': der});

  /// True when both the key and a certificate under [label] exist.
  Future<bool> hasIdentity({required String label}) async =>
      (await _ch.invokeMethod<bool>('hasIdentity', {'label': label})) ?? false;

  /// Removes the key and certificate under [label].
  Future<void> deleteIdentity({required String label}) =>
      _ch.invokeMethod<void>('deleteIdentity', {'label': label});

  Future<Uint8List> _bytes(String method, Map<String, Object?> args) async {
    final result = await _ch.invokeMethod<Uint8List>(method, args);
    if (result == null) {
      throw PlatformException(
        code: 'no_result',
        message: '$method returned nothing',
      );
    }
    return result;
  }
}
