import 'dart:convert';
import 'dart:io';

import 'package:smara_accounting/domain/linked_devices/persisting_device_certificate_store.dart';
import 'package:smara_accounting/domain/peer_sync/tls_sync_transport.dart';
import 'package:test/test.dart';

import '../../domain/crypto/in_memory_secure_key_storage.dart';

void main() {
  test(
    'PersistingDeviceCertificateStore issues a self-signed TLS identity',
    () async {
      final storage = InMemorySecureKeyStorage();
      final store = PersistingDeviceCertificateStore(secureStorage: storage);

      final first = await store.localCertificate(deviceId: 'device-a');
      expect(first.certificatePem, isNotNull);
      expect(first.privateKeyPem, isNotNull);
      expect(first.certificatePem!, contains('BEGIN CERTIFICATE'));
      expect(first.privateKeyPem!, contains('BEGIN'));
      expect(first.derBytes, isNotEmpty);
      expect(
        first.fingerprint,
        TlsSyncTransport.fingerprintOfDer(first.derBytes),
      );

      final again = await store.localCertificate(deviceId: 'device-a');
      expect(again.fingerprint, first.fingerprint);
      expect(again.certificatePem, first.certificatePem);

      final other = await store.localCertificate(deviceId: 'device-b');
      expect(other.fingerprint, isNot(first.fingerprint));
    },
  );

  test('private key material stays in SecureKeyStorage only', () async {
    final storage = InMemorySecureKeyStorage();
    final store = PersistingDeviceCertificateStore(secureStorage: storage);
    await store.localCertificate(deviceId: 'device-a');

    expect(
      await storage.read('smara.device.tls.v2.keyPem:device-a'),
      isNotNull,
    );
    expect(
      await storage.read('smara.device.tls.v2.certPem:device-a'),
      isNotNull,
    );
  });

  test('issued certificate completes a SecureSocket handshake', () async {
    final store = PersistingDeviceCertificateStore(
      secureStorage: InMemorySecureKeyStorage(),
    );
    final cert = await store.localCertificate(deviceId: 'handshake-device');
    final ctx = SecurityContext(withTrustedRoots: false)
      ..useCertificateChainBytes(utf8.encode(cert.certificatePem!))
      ..usePrivateKeyBytes(utf8.encode(cert.privateKeyPem!));
    final server = await SecureServerSocket.bind(
      InternetAddress.loopbackIPv4,
      0,
      ctx,
      requestClientCertificate: false,
      requireClientCertificate: false,
    );
    server.listen(
      (socket) async {
        await socket.close();
      },
      onError: (_) {},
      cancelOnError: false,
    );
    addTearDown(server.close);

    final client = await SecureSocket.connect(
      '127.0.0.1',
      server.port,
      onBadCertificate: (_) => true,
      timeout: const Duration(seconds: 5),
    );
    expect(client.peerCertificate, isNotNull);
    await client.close();
  });
}
