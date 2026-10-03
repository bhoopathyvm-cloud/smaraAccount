import 'dart:convert';
import 'dart:typed_data';

import 'package:basic_utils/basic_utils.dart';

import '../crypto/secure_key_storage.dart';
import '../peer_sync/tls_sync_transport.dart';
import 'device_certificate_store.dart';

/// Generates and persists a real device TLS identity (self-signed X.509)
/// in [SecureKeyStorage] for [TlsSyncTransport] (linked-devices task 12.4).
class PersistingDeviceCertificateStore implements DeviceCertificateStore {
  PersistingDeviceCertificateStore({required SecureKeyStorage secureStorage})
    : _storage = secureStorage;

  final SecureKeyStorage _storage;
  final Map<String, DeviceCertificate> _cache = {};

  // v2: basic_utils keyUsage encoding is rejected by BoringSSL
  // (CANNOT_PARSE_LEAF_CERT); regenerate identities that used v1 material.
  static String _pemKey(String deviceId) =>
      'smara.device.tls.v2.certPem:$deviceId';
  static String _keyKey(String deviceId) =>
      'smara.device.tls.v2.keyPem:$deviceId';
  static String _derKey(String deviceId) =>
      'smara.device.tls.v2.derB64:$deviceId';
  static String _fpKey(String deviceId) => 'smara.device.tls.v2.fp:$deviceId';

  @override
  Future<DeviceCertificate> localCertificate({required String deviceId}) async {
    final cached = _cache[deviceId];
    if (cached != null) return cached;

    final existingPem = await _storage.read(_pemKey(deviceId));
    final existingKey = await _storage.read(_keyKey(deviceId));
    final existingDerB64 = await _storage.read(_derKey(deviceId));
    final existingFp = await _storage.read(_fpKey(deviceId));
    if (existingPem != null &&
        existingKey != null &&
        existingDerB64 != null &&
        existingFp != null) {
      final cert = DeviceCertificate(
        derBytes: base64Decode(existingDerB64),
        fingerprint: existingFp,
        certificatePem: existingPem,
        privateKeyPem: existingKey,
      );
      _cache[deviceId] = cert;
      return cert;
    }

    final generated = _generateSelfSigned(deviceId);
    await _storage.write(_pemKey(deviceId), generated.certificatePem!);
    await _storage.write(_keyKey(deviceId), generated.privateKeyPem!);
    await _storage.write(_derKey(deviceId), base64Encode(generated.derBytes));
    await _storage.write(_fpKey(deviceId), generated.fingerprint);
    _cache[deviceId] = generated;
    return generated;
  }

  /// Creates a self-signed RSA certificate for [deviceId].
  static DeviceCertificate _generateSelfSigned(String deviceId) {
    final pair = CryptoUtils.generateRSAKeyPair();
    final privateKey = pair.privateKey as RSAPrivateKey;
    final publicKey = pair.publicKey as RSAPublicKey;
    final dn = {
      'CN':
          'smara-device-${deviceId.length > 12 ? deviceId.substring(0, 12) : deviceId}',
      'O': 'Smara',
      'OU': 'Linked devices',
    };
    final csr = X509Utils.generateRsaCsrPem(dn, privateKey, publicKey);
    // Do not pass [keyUsage]: basic_utils encodes KeyUsage as a malformed
    // BIT STRING (e.g. 03 03 01 A0 01) that BoringSSL rejects with
    // CANNOT_PARSE_LEAF_CERT. ExtendedKeyUsage + basicConstraints are fine.
    final certPem = X509Utils.generateSelfSignedCertificate(
      privateKey,
      csr,
      3650,
      extKeyUsage: [ExtendedKeyUsage.CLIENT_AUTH, ExtendedKeyUsage.SERVER_AUTH],
      cA: false,
    );
    final keyPem = CryptoUtils.encodeRSAPrivateKeyToPem(privateKey);
    final der = _pemToDer(certPem);
    final fingerprint = TlsSyncTransport.fingerprintOfDer(der);
    return DeviceCertificate(
      derBytes: der,
      fingerprint: fingerprint,
      certificatePem: certPem,
      privateKeyPem: keyPem,
    );
  }

  static Uint8List _pemToDer(String pem) {
    final lines = pem
        .replaceAll('\r', '')
        .split('\n')
        .where((l) => l.isNotEmpty && !l.startsWith('-----'))
        .join();
    return Uint8List.fromList(base64Decode(lines));
  }
}
