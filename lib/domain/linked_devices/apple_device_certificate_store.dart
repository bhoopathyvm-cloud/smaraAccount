import 'dart:convert';
import 'dart:typed_data';

import 'package:smara_apple_crypto/smara_apple_crypto.dart';

import '../crypto/secure_key_storage.dart';
import '../crypto/x509_der.dart';
import '../peer_sync/certificate_pinning.dart';
import '../peer_sync/dart_tls_socket_factory.dart';
import 'device_certificate_store.dart';

/// The operating-system half of an Apple device identity (design D4): the
/// Keychain key pair and the signature over the certificate Dart assembles.
/// Implemented by [AppleKeychainCertificateSigner] in the app; tests
/// substitute a fake that signs in Dart.
abstract class OsCertificateSigner {
  /// Creates the RSA-2048 key under [label] and returns its PKCS#1
  /// `RSAPublicKey` DER.
  Future<Uint8List> createRsaKey({required String label});

  /// RSASSA-PKCS1-v1_5 / SHA-256 over [data] with the key under [label].
  Future<Uint8List> signPkcs1Sha256({
    required String label,
    required Uint8List data,
  });

  /// Stores the certificate next to its key so the OS can present them as
  /// one TLS identity.
  Future<void> storeCertificate({
    required String label,
    required Uint8List der,
  });

  /// True when the key and certificate under [label] are both present.
  Future<bool> hasIdentity({required String label});
}

/// [OsCertificateSigner] over the Security framework through the in-repo
/// `smara_apple_crypto` plugin.
class AppleKeychainCertificateSigner implements OsCertificateSigner {
  const AppleKeychainCertificateSigner({AppleKeychainIdentity? keychain})
    : _keychain = keychain;

  final AppleKeychainIdentity? _keychain;

  AppleKeychainIdentity get _os => _keychain ?? AppleKeychainIdentity.instance;

  @override
  Future<Uint8List> createRsaKey({required String label}) =>
      _os.createRsaKey(label: label);

  @override
  Future<Uint8List> signPkcs1Sha256({
    required String label,
    required Uint8List data,
  }) => _os.signPkcs1Sha256(label: label, data: data);

  @override
  Future<void> storeCertificate({
    required String label,
    required Uint8List der,
  }) => _os.storeCertificate(label: label, der: der);

  @override
  Future<bool> hasIdentity({required String label}) =>
      _os.hasIdentity(label: label);
}

/// Device TLS identity for iOS and macOS (os-provided-encryption task 4.1).
///
/// The key pair is generated and kept in the Keychain by the operating
/// system; Dart builds the X.509 `TBSCertificate`, the OS signs it, and Dart
/// assembles the certificate. Only public material (DER, fingerprint, PEM)
/// is written to [SecureKeyStorage]; the private key never reaches Dart.
/// `basic_utils` is not used here, and there is no migration from a
/// Dart-made identity: nothing has shipped, so an Apple device simply creates
/// its identity through the OS the first time it needs one.
class AppleDeviceCertificateStore implements DeviceCertificateStore {
  AppleDeviceCertificateStore({
    required SecureKeyStorage secureStorage,
    OsCertificateSigner? signer,
    DateTime Function()? now,
  }) : _storage = secureStorage,
       _signer = signer ?? const AppleKeychainCertificateSigner(),
       _now = now ?? DateTime.now;

  final SecureKeyStorage _storage;
  final OsCertificateSigner _signer;
  final DateTime Function() _now;
  final Map<String, DeviceCertificate> _cache = {};
  final Map<String, DeviceCertificate> _peerCache = {};

  /// Certificate validity, matching the Dart identity store's 3650 days.
  static const validity = Duration(days: 3650);

  // v3: OS-made identities (Keychain key, OS-signed certificate). Peer
  // material keeps the v2 keys so a peer pinned by either store is found.
  static String _derKey(String deviceId) =>
      'smara.device.tls.v3.derB64:$deviceId';
  static String _fpKey(String deviceId) => 'smara.device.tls.v3.fp:$deviceId';
  static String _labelKey(String deviceId) =>
      'smara.device.tls.v3.keychainLabel:$deviceId';
  static String _peerPemKey(String fingerprint) =>
      'smara.device.tls.v2.peerPem:$fingerprint';
  static String _peerDerKey(String fingerprint) =>
      'smara.device.tls.v2.peerDerB64:$fingerprint';

  /// Keychain label of the identity for [deviceId].
  static String keychainLabelFor(String deviceId) =>
      'smara-device-tls:$deviceId';

  @override
  Future<DeviceCertificate> localCertificate({required String deviceId}) async {
    final cached = _cache[deviceId];
    if (cached != null) return cached;

    final existingDerB64 = await _storage.read(_derKey(deviceId));
    final existingFp = await _storage.read(_fpKey(deviceId));
    final existingLabel = await _storage.read(_labelKey(deviceId));
    if (existingDerB64 != null &&
        existingFp != null &&
        existingLabel != null &&
        await _signer.hasIdentity(label: existingLabel)) {
      final der = base64Decode(existingDerB64);
      final cert = DeviceCertificate(
        derBytes: der,
        fingerprint: existingFp,
        certificatePem: DartTlsSocketFactory.derToPem(der),
        keychainIdentityLabel: existingLabel,
      );
      _cache[deviceId] = cert;
      _peerCache[existingFp] = cert;
      return cert;
    }

    final generated = await _issue(deviceId);
    await _storage.write(_derKey(deviceId), base64Encode(generated.derBytes));
    await _storage.write(_fpKey(deviceId), generated.fingerprint);
    await _storage.write(_labelKey(deviceId), generated.keychainIdentityLabel!);
    _cache[deviceId] = generated;
    _peerCache[generated.fingerprint] = generated;
    return generated;
  }

  Future<DeviceCertificate> _issue(String deviceId) async {
    final label = keychainLabelFor(deviceId);
    final publicKey = await _signer.createRsaKey(label: label);
    final notBefore = _now().toUtc().subtract(const Duration(minutes: 5));
    final tbs = X509SelfSignedRsa.tbsCertificate(
      commonName:
          'smara-device-${deviceId.length > 12 ? deviceId.substring(0, 12) : deviceId}',
      serialNumber: X509SelfSignedRsa.randomSerial(),
      notBefore: notBefore,
      notAfter: notBefore.add(validity),
      rsaPublicKeyPkcs1Der: publicKey,
    );
    final signature = await _signer.signPkcs1Sha256(label: label, data: tbs);
    final der = X509SelfSignedRsa.certificate(
      tbsDer: tbs,
      signature: signature,
    );
    await _signer.storeCertificate(label: label, der: der);
    final fingerprint = await CertificatePinning.fingerprintOf(der);
    return DeviceCertificate(
      derBytes: der,
      fingerprint: fingerprint,
      certificatePem: DartTlsSocketFactory.derToPem(der),
      keychainIdentityLabel: label,
    );
  }

  @override
  Future<void> rememberPeerCertificate(DeviceCertificate certificate) async {
    final der = certificate.derBytes;
    if (der.isEmpty && certificate.certificatePem == null) return;
    final derBytes = der.isNotEmpty
        ? der
        : pemToDer(certificate.certificatePem!);
    final fp = certificate.fingerprint.isNotEmpty
        ? certificate.fingerprint
        : await CertificatePinning.fingerprintOf(derBytes);
    final pem =
        certificate.certificatePem ?? DartTlsSocketFactory.derToPem(derBytes);
    await _storage.write(_peerPemKey(fp), pem);
    await _storage.write(_peerDerKey(fp), base64Encode(derBytes));
    _peerCache[fp] = DeviceCertificate(
      derBytes: derBytes,
      fingerprint: fp,
      certificatePem: pem,
    );
  }

  @override
  Future<DeviceCertificate?> certificateForFingerprint(
    String fingerprint,
  ) async {
    if (fingerprint.isEmpty) return null;
    final cached = _peerCache[fingerprint];
    if (cached != null) return cached;
    final pem = await _storage.read(_peerPemKey(fingerprint));
    final derB64 = await _storage.read(_peerDerKey(fingerprint));
    if (pem == null || derB64 == null) return null;
    final cert = DeviceCertificate(
      derBytes: base64Decode(derB64),
      fingerprint: fingerprint,
      certificatePem: pem,
    );
    _peerCache[fingerprint] = cert;
    return cert;
  }

  static Uint8List pemToDer(String pem) {
    final lines = pem
        .replaceAll('\r', '')
        .split('\n')
        .where((l) => l.isNotEmpty && !l.startsWith('-----'))
        .join();
    return Uint8List.fromList(base64Decode(lines));
  }
}
