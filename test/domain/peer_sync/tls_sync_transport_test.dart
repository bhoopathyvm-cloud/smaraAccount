import 'dart:async';
import 'dart:io';

import 'package:smara_accounting/domain/linked_devices/device_certificate_store.dart';
import 'package:smara_accounting/domain/peer_sync/certificate_pinning.dart';
import 'package:smara_accounting/domain/peer_sync/sync_payloads.dart';
import 'package:smara_accounting/domain/peer_sync/sync_transport.dart';
import 'package:smara_accounting/domain/peer_sync/tls_sync_transport.dart';
import 'package:test/test.dart';

DeviceCertificate _loadPeer(String id) {
  final dir = Directory('test/fixtures/tls');
  final der = File('${dir.path}/$id-cert.der').readAsBytesSync();
  final pem = File('${dir.path}/$id-cert.pem').readAsStringSync();
  final key = File('${dir.path}/$id-key.pem').readAsStringSync();
  final fingerprint = TlsSyncTransport.fingerprintOfDer(der);
  return DeviceCertificate(
    derBytes: der,
    fingerprint: fingerprint,
    certificatePem: pem,
    privateKeyPem: key,
  );
}

void main() {
  group('TlsSyncTransport', () {
    late DeviceCertificate certA;
    late DeviceCertificate certB;
    late DeviceCertificate certEvil;
    late TlsSyncTransport transportA;
    late TlsSyncTransport transportB;

    setUp(() {
      certA = _loadPeer('a');
      certB = _loadPeer('b');
      certEvil = _loadPeer('evil');
      transportA = TlsSyncTransport(bindAddress: InternetAddress.loopbackIPv4);
      transportB = TlsSyncTransport(bindAddress: InternetAddress.loopbackIPv4);
    });

    tearDown(() async {
      await transportA.stopListening();
      await transportB.stopListening();
    });

    test('fingerprint matches CertificatePinning', () async {
      final asyncFp = await CertificatePinning.fingerprintOf(certA.derBytes);
      expect(certA.fingerprint, asyncFp);
    });

    test('loopback pinned peers exchange a message', () async {
      final pins = {certA.fingerprint, certB.fingerprint};
      final pinnedCerts = [certA, certB];
      final receivedOnB = Completer<Map<String, dynamic>>();
      late int boundPort;

      await transportB.listen(
        local: SyncPeerIdentity(deviceId: 'b', certificate: certB),
        pinnedFingerprints: pins,
        pinnedCertificates: pinnedCerts,
        onBound: (port) => boundPort = port,
        onSession: (conn) async {
          receivedOnB.complete(await conn.receive());
          await conn.close();
        },
      );

      final conn = await transportA.connect(
        local: SyncPeerIdentity(deviceId: 'a', certificate: certA),
        remote: SyncPeerIdentity(
          deviceId: 'b',
          certificate: certB,
          host: InternetAddress.loopbackIPv4.address,
          port: boundPort,
        ),
        pinnedFingerprints: pins,
        pinnedCertificates: pinnedCerts,
      );

      await conn.send(
        EntryBatch(
          entries: [
            SyncJournalEntry(
              id: 'e1',
              transactionDate: '2026-04-01',
              recordedAt: DateTime.utc(2026, 4, 1),
              description: 'tls',
              reversesEntryId: null,
              deviceChainSequence: 1,
              previousEntryHash: List.filled(32, 0),
              entryHash: List.filled(32, 3),
              signedByIdentityId: 'id-a',
              signature: List.filled(64, 4),
              postings: const [],
            ),
          ],
        ).toJson(),
      );

      final received = await receivedOnB.future.timeout(
        const Duration(seconds: 5),
      );
      expect(EntryBatch.fromJson(received).entries.single.id, 'e1');
      await conn.close();
    });

    test('refuses unknown certificate on connect', () async {
      final pins = {certA.fingerprint, certB.fingerprint};
      late int boundPort;
      await transportB.listen(
        local: SyncPeerIdentity(deviceId: 'b', certificate: certB),
        pinnedFingerprints: pins,
        pinnedCertificates: [certA, certB],
        onBound: (port) => boundPort = port,
        onSession: (_) async {},
      );

      await expectLater(
        transportA.connect(
          local: SyncPeerIdentity(deviceId: 'a', certificate: certA),
          remote: SyncPeerIdentity(
            deviceId: 'evil',
            certificate: certEvil,
            host: InternetAddress.loopbackIPv4.address,
            port: boundPort,
          ),
          pinnedFingerprints: pins,
          pinnedCertificates: [certA, certB],
        ),
        throwsA(isA<UnknownCertificateException>()),
      );
    });

    test('streams a 5 MB receipt-sized payload intact', () async {
      final pins = {certA.fingerprint, certB.fingerprint};
      final pinnedCerts = [certA, certB];
      final receivedOnB = Completer<Map<String, dynamic>>();
      late int boundPort;
      final bigDescription = 'x' * (5 * 1024 * 1024);

      await transportB.listen(
        local: SyncPeerIdentity(deviceId: 'b', certificate: certB),
        pinnedFingerprints: pins,
        pinnedCertificates: pinnedCerts,
        onBound: (port) => boundPort = port,
        onSession: (conn) async {
          receivedOnB.complete(await conn.receive());
          await conn.close();
        },
      );

      final conn = await transportA.connect(
        local: SyncPeerIdentity(deviceId: 'a', certificate: certA),
        remote: SyncPeerIdentity(
          deviceId: 'b',
          certificate: certB,
          host: InternetAddress.loopbackIPv4.address,
          port: boundPort,
        ),
        pinnedFingerprints: pins,
        pinnedCertificates: pinnedCerts,
      );

      await conn.send({
        'kind': 'receiptBlob',
        'bytesBase64Length': bigDescription.length,
        'payload': bigDescription,
      });
      final received = await receivedOnB.future.timeout(
        const Duration(seconds: 30),
      );
      expect(received['payload'], bigDescription);
      await conn.close();
    });
  });
}
