import 'dart:async';
import 'dart:convert';

import 'package:smara_accounting/domain/linked_devices/device_certificate_store.dart';
import 'package:smara_accounting/domain/peer_sync/certificate_pinning.dart';
import 'package:smara_accounting/domain/peer_sync/sync_payloads.dart';
import 'package:smara_accounting/domain/peer_sync/sync_transport.dart';
import 'package:test/test.dart';

void main() {
  group('CertificatePinning', () {
    test('accepts pinned fingerprint and refuses unknown', () async {
      final store = FakeDeviceCertificateStore();
      final known = await store.localCertificate(deviceId: 'device-a');
      final unknown = await store.localCertificate(deviceId: 'stranger');

      final pinning = CertificatePinning(
        pinnedFingerprints: {known.fingerprint},
      );

      expect(await pinning.checkCertificate(known), PinCheckResult.accepted);
      expect(
        await pinning.checkCertificate(unknown),
        PinCheckResult.refusedUnknown,
      );
      expect(
        pinning.checkFingerprint('not-a-real-fp'),
        PinCheckResult.refusedUnknown,
      );
    });
  });

  group('sync payloads', () {
    test('EntryBatch round-trips without private keys', () {
      final batch = EntryBatch(
        entries: [
          SyncJournalEntry(
            id: 'e1',
            transactionDate: '2026-04-01',
            recordedAt: DateTime.utc(2026, 4, 1, 12),
            description: 'Groceries',
            reversesEntryId: null,
            deviceChainSequence: 1,
            previousEntryHash: List.filled(32, 0),
            entryHash: List.filled(32, 1),
            signedByIdentityId: 'id-a',
            signature: List.filled(64, 2),
            postings: const [
              SyncPosting(accountId: 'cash', amountMinor: -500, lineNumber: 1),
              SyncPosting(accountId: 'exp', amountMinor: 500, lineNumber: 2),
            ],
          ),
        ],
      );

      final encoded = batch.encode();
      expect(syncPayloadContainsPrivateKeyMaterial(encoded), isFalse);
      expect(encoded.contains('private'), isFalse);

      final decoded = EntryBatch.decode(encoded);
      expect(decoded.entries, hasLength(1));
      expect(decoded.entries.single.id, 'e1');
      expect(decoded.entries.single.postings, hasLength(2));
      expect(decoded.entries.single.signedByIdentityId, 'id-a');
    });

    test('MetadataOps and NoticeOps round-trip', () {
      final meta = MetadataOps(
        operations: [
          MetadataOperation(
            entityType: 'category',
            entityId: 'cat-1',
            field: 'name',
            value: 'Food',
            updatedAt: DateTime.utc(2026, 4, 2),
            updatedByIdentityId: 'id-a',
          ),
        ],
      );
      final notices = NoticeOps(
        notices: [
          SyncNotice(
            noticeId: 'n1',
            kind: 'entryNotAccepted',
            createdAt: DateTime.utc(2026, 4, 3),
            relatedDeviceId: 'device-b',
            detail: 'Not accepted: couldn\'t be verified (from Phone B)',
          ),
        ],
      );

      expect(MetadataOps.decode(meta.encode()).operations.single.field, 'name');
      expect(
        NoticeOps.decode(notices.encode()).notices.single.kind,
        'entryNotAccepted',
      );
    });

    test('payload decode refuses private key fields', () {
      final hostile = jsonEncode({
        'kind': 'entryBatch',
        'entries': [],
        'privateKey': 'deadbeef',
      });
      expect(syncPayloadContainsPrivateKeyMaterial(hostile), isTrue);
      expect(() => EntryBatch.decode(hostile), throwsFormatException);
    });
  });

  group('InProcessSyncTransport', () {
    late FakeDeviceCertificateStore certs;
    late InProcessSyncTransport transportA;
    late InProcessSyncTransport transportB;

    setUp(() {
      InProcessSyncTransport.resetAll();
      certs = FakeDeviceCertificateStore();
      transportA = InProcessSyncTransport(networkId: 'lan');
      transportB = InProcessSyncTransport(networkId: 'lan');
    });

    tearDown(() async {
      await transportA.stopListening();
      await transportB.stopListening();
      InProcessSyncTransport.resetAll();
    });

    test(
      'connect succeeds with pinned certs and exchanges EntryBatch',
      () async {
        final certA = await certs.localCertificate(deviceId: 'a');
        final certB = await certs.localCertificate(deviceId: 'b');
        final pins = {certA.fingerprint, certB.fingerprint};

        final receivedOnB = Completer<Map<String, dynamic>>();
        await transportB.listen(
          local: SyncPeerIdentity(deviceId: 'b', certificate: certB),
          pinnedFingerprints: pins,
          onSession: (conn) async {
            receivedOnB.complete(await conn.receive());
          },
        );

        final conn = await transportA.connect(
          local: SyncPeerIdentity(deviceId: 'a', certificate: certA),
          remote: SyncPeerIdentity(deviceId: 'b', certificate: certB),
          pinnedFingerprints: pins,
        );

        final batch = EntryBatch(
          entries: [
            SyncJournalEntry(
              id: 'e1',
              transactionDate: '2026-04-01',
              recordedAt: DateTime.utc(2026, 4, 1),
              description: 'x',
              reversesEntryId: null,
              deviceChainSequence: 1,
              previousEntryHash: List.filled(32, 0),
              entryHash: List.filled(32, 3),
              signedByIdentityId: 'id-a',
              signature: List.filled(64, 4),
              postings: const [],
            ),
          ],
        );
        await conn.send(batch.toJson());
        final received = await receivedOnB.future.timeout(
          const Duration(seconds: 2),
        );

        expect(EntryBatch.fromJson(received).entries.single.id, 'e1');
        await conn.close();
      },
    );

    test('refuses unknown certificate', () async {
      final certA = await certs.localCertificate(deviceId: 'a');
      final certB = await certs.localCertificate(deviceId: 'b');
      final stranger = await certs.localCertificate(deviceId: 'evil');

      await transportB.listen(
        local: SyncPeerIdentity(deviceId: 'b', certificate: certB),
        pinnedFingerprints: {certA.fingerprint, certB.fingerprint},
        onSession: (_) {},
      );

      await expectLater(
        transportA.connect(
          local: SyncPeerIdentity(deviceId: 'a', certificate: certA),
          remote: SyncPeerIdentity(deviceId: 'evil', certificate: stranger),
          pinnedFingerprints: {certA.fingerprint, certB.fingerprint},
        ),
        throwsA(isA<UnknownCertificateException>()),
      );
    });

    test('remote network cannot connect (no shared listener)', () async {
      final certA = await certs.localCertificate(deviceId: 'a');
      final certB = await certs.localCertificate(deviceId: 'b');
      final pins = {certA.fingerprint, certB.fingerprint};

      final remoteTransport = InProcessSyncTransport(networkId: 'other-lan');
      await remoteTransport.listen(
        local: SyncPeerIdentity(deviceId: 'b', certificate: certB),
        pinnedFingerprints: pins,
        onSession: (_) {},
      );
      addTearDown(() async {
        await remoteTransport.stopListening();
      });

      await expectLater(
        transportA.connect(
          local: SyncPeerIdentity(deviceId: 'a', certificate: certA),
          remote: SyncPeerIdentity(deviceId: 'b', certificate: certB),
          pinnedFingerprints: pins,
        ),
        throwsStateError,
      );
    });
  });
}
