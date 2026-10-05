import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:basic_utils/basic_utils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smara_accounting/domain/crypto/x509_der.dart';
import 'package:smara_accounting/domain/linked_devices/apple_device_certificate_store.dart';
import 'package:smara_accounting/domain/linked_devices/device_certificate_store.dart';
import 'package:smara_accounting/domain/peer_sync/certificate_pinning.dart';
import 'package:smara_accounting/domain/peer_sync/dart_tls_socket_factory.dart';
import 'package:smara_accounting/domain/peer_sync/sync_transport.dart';
import 'package:smara_accounting/domain/peer_sync/tls_sync_transport.dart';

import '../crypto/in_memory_secure_key_storage.dart';

/// Stands in for the Security framework: an RSA key kept out of the store's
/// reach, PKCS1-v1_5/SHA-256 signatures, and a certificate slot. Only the
/// test (never the store) can see the private key, which it uses to drive a
/// Dart TLS socket so a BoringSSL peer parses and pins the OS-style
/// certificate.
class _FakeOsSigner implements OsCertificateSigner {
  final Map<String, RSAPrivateKey> _keys = {};
  final Map<String, Uint8List> _certificates = {};
  int createCalls = 0;

  @override
  Future<Uint8List> createRsaKey({required String label}) async {
    createCalls++;
    final pair = CryptoUtils.generateRSAKeyPair();
    final privateKey = pair.privateKey as RSAPrivateKey;
    final publicKey = pair.publicKey as RSAPublicKey;
    _keys[label] = privateKey;
    _certificates.remove(label);
    return X509SelfSignedRsa.rsaPublicKeyPkcs1(
      modulus: publicKey.modulus!,
      exponent: publicKey.exponent!,
    );
  }

  @override
  Future<Uint8List> signPkcs1Sha256({
    required String label,
    required Uint8List data,
  }) async {
    return CryptoUtils.rsaSign(_keys[label]!, data);
  }

  @override
  Future<void> storeCertificate({
    required String label,
    required Uint8List der,
  }) async {
    _certificates[label] = der;
  }

  @override
  Future<bool> hasIdentity({required String label}) async =>
      _keys.containsKey(label) && _certificates.containsKey(label);

  String privateKeyPem(String label) =>
      CryptoUtils.encodeRSAPrivateKeyToPem(_keys[label]!);
}

DeviceCertificate _loadPeer(String id) {
  final dir = Directory('test/fixtures/tls');
  final der = File('${dir.path}/$id-cert.der').readAsBytesSync();
  final pem = File('${dir.path}/$id-cert.pem').readAsStringSync();
  final key = File('${dir.path}/$id-key.pem').readAsStringSync();
  return DeviceCertificate(
    derBytes: der,
    fingerprint: TlsSyncTransport.fingerprintOfDer(der),
    certificatePem: pem,
    privateKeyPem: key,
  );
}

void main() {
  test('issues an OS-signed certificate that parses as X.509 v3', () async {
    final signer = _FakeOsSigner();
    final storage = InMemorySecureKeyStorage();
    final store = AppleDeviceCertificateStore(
      secureStorage: storage,
      signer: signer,
      now: () => DateTime.utc(2026, 10, 5, 12),
    );

    final cert = await store.localCertificate(deviceId: 'device-a-0123456789');

    expect(cert.keychainIdentityLabel, isNotNull);
    expect(cert.privateKeyPem, isNull);
    expect(cert.derBytes, isNotEmpty);
    expect(cert.certificatePem, contains('BEGIN CERTIFICATE'));
    expect(
      cert.fingerprint,
      await CertificatePinning.fingerprintOf(cert.derBytes),
    );
    expect(cert.fingerprint, TlsSyncTransport.fingerprintOfDer(cert.derBytes));

    final parsed = X509Utils.x509CertificateFromPem(cert.certificatePem!);
    expect(parsed.tbsCertificate!.version, 3);
    expect(
      parsed.tbsCertificate!.subject['2.5.4.3'],
      'smara-device-device-a-012',
    );
    expect(
      parsed.tbsCertificate!.issuer['2.5.4.3'],
      'smara-device-device-a-012',
    );
    expect(parsed.tbsCertificate!.subject['2.5.4.10'], 'Smara');
    expect(parsed.tbsCertificate!.validity.notBefore.year, 2026);
    expect(parsed.tbsCertificate!.validity.notAfter.year, 2036);
    expect(
      parsed.tbsCertificate!.extensions!.extKeyUsage,
      containsAll([ExtendedKeyUsage.SERVER_AUTH, ExtendedKeyUsage.CLIENT_AUTH]),
    );
    expect(parsed.tbsCertificate!.extensions!.cA, isNot(isTrue));
    expect(parsed.signatureAlgorithm, '1.2.840.113549.1.1.11');
    expect(
      parsed.tbsCertificate!.subjectPublicKeyInfo.algorithm,
      '1.2.840.113549.1.1.1',
    );
  });

  test(
    'reuses the Keychain identity and keeps no private key in storage',
    () async {
      final signer = _FakeOsSigner();
      final storage = InMemorySecureKeyStorage();
      final store = AppleDeviceCertificateStore(
        secureStorage: storage,
        signer: signer,
      );
      final first = await store.localCertificate(deviceId: 'device-a');
      final again = await AppleDeviceCertificateStore(
        secureStorage: storage,
        signer: signer,
      ).localCertificate(deviceId: 'device-a');
      expect(again.fingerprint, first.fingerprint);
      expect(again.derBytes, equals(first.derBytes));
      expect(signer.createCalls, 1);

      final other = await store.localCertificate(deviceId: 'device-b');
      expect(other.fingerprint, isNot(first.fingerprint));
      expect(signer.createCalls, 2);

      for (final entry in storage.snapshot.entries) {
        expect(entry.key, isNot(contains('keyPem')));
        expect(entry.value, isNot(contains('PRIVATE KEY')));
      }
    },
  );

  test('re-issues when the Keychain lost the identity', () async {
    final signer = _FakeOsSigner();
    final storage = InMemorySecureKeyStorage();
    final first = await AppleDeviceCertificateStore(
      secureStorage: storage,
      signer: signer,
    ).localCertificate(deviceId: 'device-a');
    final freshSigner = _FakeOsSigner();
    final second = await AppleDeviceCertificateStore(
      secureStorage: storage,
      signer: freshSigner,
    ).localCertificate(deviceId: 'device-a');
    expect(second.fingerprint, isNot(first.fingerprint));
    expect(freshSigner.createCalls, 1);
  });

  test('a Dart (BoringSSL) peer pins and accepts the certificate', () async {
    final signer = _FakeOsSigner();
    final store = AppleDeviceCertificateStore(
      secureStorage: InMemorySecureKeyStorage(),
      signer: signer,
    );
    final issued = await store.localCertificate(deviceId: 'iphone');
    // Drive a Dart socket with the OS-style certificate: the fake signer's
    // key plays the Keychain's part so the handshake can be completed here.
    final iphone = DeviceCertificate(
      derBytes: issued.derBytes,
      fingerprint: issued.fingerprint,
      certificatePem: issued.certificatePem,
      privateKeyPem: signer.privateKeyPem(issued.keychainIdentityLabel!),
    );
    final android = _loadPeer('b');
    final sockets = const DartTlsSocketFactory();
    final androidTransport = TlsSyncTransport(
      bindAddress: InternetAddress.loopbackIPv4,
      sockets: sockets,
    );
    final iphoneTransport = TlsSyncTransport(
      bindAddress: InternetAddress.loopbackIPv4,
      sockets: sockets,
    );
    addTearDown(androidTransport.stopListening);
    addTearDown(iphoneTransport.stopListening);

    final received = Completer<Map<String, dynamic>>();
    late int port;
    await androidTransport.listen(
      local: SyncPeerIdentity(deviceId: 'android', certificate: android),
      pinnedFingerprints: {iphone.fingerprint, android.fingerprint},
      pinnedCertificates: [iphone],
      onBound: (p) => port = p,
      onSession: (connection) async {
        expect(connection.remote.certificate.fingerprint, iphone.fingerprint);
        received.complete(await connection.receive());
        await connection.close();
      },
    );

    final connection = await iphoneTransport.connect(
      local: SyncPeerIdentity(deviceId: 'iphone', certificate: iphone),
      remote: SyncPeerIdentity(
        deviceId: 'android',
        certificate: android,
        host: '127.0.0.1',
        port: port,
      ),
      pinnedFingerprints: {iphone.fingerprint, android.fingerprint},
      pinnedCertificates: [android],
    );
    await connection.send({'type': 'hello', 'from': 'iphone'});
    expect(await received.future, {'type': 'hello', 'from': 'iphone'});
    await connection.close();
  });

  test('an unpinned OS-style certificate is refused by a Dart peer', () async {
    final signer = _FakeOsSigner();
    final issued = await AppleDeviceCertificateStore(
      secureStorage: InMemorySecureKeyStorage(),
      signer: signer,
    ).localCertificate(deviceId: 'stranger');
    final stranger = DeviceCertificate(
      derBytes: issued.derBytes,
      fingerprint: issued.fingerprint,
      certificatePem: issued.certificatePem,
      privateKeyPem: signer.privateKeyPem(issued.keychainIdentityLabel!),
    );
    final android = _loadPeer('b');
    final androidTransport = TlsSyncTransport(
      bindAddress: InternetAddress.loopbackIPv4,
      sockets: const DartTlsSocketFactory(),
    );
    final strangerTransport = TlsSyncTransport(
      bindAddress: InternetAddress.loopbackIPv4,
      sockets: const DartTlsSocketFactory(),
    );
    addTearDown(androidTransport.stopListening);
    addTearDown(strangerTransport.stopListening);

    var sessions = 0;
    late int port;
    await androidTransport.listen(
      local: SyncPeerIdentity(deviceId: 'android', certificate: android),
      pinnedFingerprints: {android.fingerprint},
      onBound: (p) => port = p,
      onSession: (_) async => sessions++,
    );
    // The Android listener never admits the stranger: BoringSSL fails the
    // handshake on the unknown client certificate (or, if the client sees
    // the handshake complete first, the first read fails).
    try {
      final connection = await strangerTransport.connect(
        local: SyncPeerIdentity(deviceId: 'stranger', certificate: stranger),
        remote: SyncPeerIdentity(
          deviceId: 'android',
          certificate: android,
          host: '127.0.0.1',
          port: port,
        ),
        pinnedFingerprints: {stranger.fingerprint, android.fingerprint},
        pinnedCertificates: [android],
      );
      await expectLater(connection.receive(), throwsA(anything));
      await connection.close();
    } catch (_) {
      // Refused during the handshake: also correct.
    }
    await Future<void>.delayed(const Duration(milliseconds: 200));
    expect(sessions, 0);

    // And the stranger itself refuses a listener it has not pinned.
    await expectLater(
      strangerTransport.connect(
        local: SyncPeerIdentity(deviceId: 'stranger', certificate: stranger),
        remote: SyncPeerIdentity(
          deviceId: 'android',
          certificate: const DeviceCertificate(derBytes: [], fingerprint: ''),
          host: '127.0.0.1',
          port: port,
        ),
        pinnedFingerprints: {stranger.fingerprint},
      ),
      throwsA(isA<UnknownCertificateException>()),
    );
  });

  test('peer certificates are remembered by fingerprint', () async {
    final store = AppleDeviceCertificateStore(
      secureStorage: InMemorySecureKeyStorage(),
      signer: _FakeOsSigner(),
    );
    final peer = _loadPeer('a');
    await store.rememberPeerCertificate(
      DeviceCertificate(derBytes: peer.derBytes, fingerprint: ''),
    );
    final found = await store.certificateForFingerprint(peer.fingerprint);
    expect(found, isNotNull);
    expect(found!.derBytes, equals(peer.derBytes));
    expect(found.certificatePem, contains('BEGIN CERTIFICATE'));
    expect(
      base64Decode(
        found.certificatePem!
            .split('\n')
            .where((l) => l.isNotEmpty && !l.startsWith('-----'))
            .join(),
      ),
      equals(peer.derBytes),
    );
  });
}
