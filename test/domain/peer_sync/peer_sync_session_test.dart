import 'dart:async';

import 'package:smara_accounting/domain/linked_devices/device_certificate_store.dart';
import 'package:smara_accounting/domain/linked_devices/local_network_reachability.dart';
import 'package:smara_accounting/domain/peer_sync/peer_sync_session.dart';
import 'package:smara_accounting/domain/peer_sync/sync_payloads.dart';
import 'package:smara_accounting/domain/peer_sync/sync_transport.dart';
import 'package:test/test.dart';

SyncJournalEntry _entry({
  required String id,
  required String identityId,
  required int sequence,
  String description = 'entry',
}) {
  return SyncJournalEntry(
    id: id,
    transactionDate: '2026-04-01',
    recordedAt: DateTime.utc(2026, 4, 1, 12, sequence),
    description: description,
    reversesEntryId: null,
    deviceChainSequence: sequence,
    previousEntryHash: List.filled(32, 0),
    entryHash: List.filled(32, sequence),
    signedByIdentityId: identityId,
    signature: List.filled(64, sequence),
    postings: const [
      SyncPosting(accountId: 'cash', amountMinor: -100, lineNumber: 1),
      SyncPosting(accountId: 'exp', amountMinor: 100, lineNumber: 2),
    ],
  );
}

void main() {
  late FakeDeviceCertificateStore certs;
  late FakeLocalNetworkReachability reachability;
  late InProcessSyncTransport transportA;
  late InProcessSyncTransport transportB;
  late FakeSyncLedgerView ledgerA;
  late FakeSyncLedgerView ledgerB;
  late DeviceCertificate certA;
  late DeviceCertificate certB;
  late Set<String> pins;

  setUp(() async {
    InProcessSyncTransport.resetAll();
    certs = FakeDeviceCertificateStore();
    reachability = FakeLocalNetworkReachability(onLocalNetwork: true);
    transportA = InProcessSyncTransport(networkId: 'lan');
    transportB = InProcessSyncTransport(networkId: 'lan');
    ledgerA = FakeSyncLedgerView();
    ledgerB = FakeSyncLedgerView();
    certA = await certs.localCertificate(deviceId: 'a');
    certB = await certs.localCertificate(deviceId: 'b');
    pins = {certA.fingerprint, certB.fingerprint};
  });

  tearDown(() async {
    await transportA.stopListening();
    await transportB.stopListening();
    InProcessSyncTransport.resetAll();
  });

  test(
    'Sync now exchanges missing entries over in-process transport',
    () async {
      ledgerA.seed(_entry(id: 'a1', identityId: 'id-a', sequence: 1));
      ledgerA.seed(_entry(id: 'a2', identityId: 'id-a', sequence: 2));
      ledgerB.seed(_entry(id: 'b1', identityId: 'id-b', sequence: 1));

      final sessionA = PeerSyncSession(
        transport: transportA,
        ledger: ledgerA,
        reachability: reachability,
        localIdentity: SyncPeerIdentity(deviceId: 'a', certificate: certA),
        pinnedFingerprints: pins,
      );
      final sessionB = PeerSyncSession(
        transport: transportB,
        ledger: ledgerB,
        reachability: reachability,
        localIdentity: SyncPeerIdentity(deviceId: 'b', certificate: certB),
        pinnedFingerprints: pins,
      );

      final bDone = Completer<SyncSessionResult>();
      await sessionB.startListening(onCompleted: bDone.complete);

      final aResult = await sessionA.syncNow(
        remote: SyncPeerIdentity(deviceId: 'b', certificate: certB),
      );
      final bResult = await bDone.future.timeout(const Duration(seconds: 2));

      expect(aResult.connected, isTrue);
      expect(bResult.connected, isTrue);
      expect(aResult.entriesSent, greaterThanOrEqualTo(1));
      expect(aResult.entriesReceived, greaterThanOrEqualTo(1));

      final tipsA = await ledgerA.nextSequenceByIdentity();
      final tipsB = await ledgerB.nextSequenceByIdentity();
      expect(tipsA['id-a'], 3);
      expect(tipsA['id-b'], 2);
      expect(tipsB['id-a'], 3);
      expect(tipsB['id-b'], 2);

      // Original rows unchanged on A.
      final aEntries = await ledgerA.entriesFrom(
        identityId: 'id-a',
        minSequence: 1,
      );
      expect(aEntries.map((e) => e.id), ['a1', 'a2']);
    },
  );

  test('remote network fake does not connect', () async {
    reachability.onLocalNetwork = false;

    final sessionA = PeerSyncSession(
      transport: transportA,
      ledger: ledgerA,
      reachability: reachability,
      localIdentity: SyncPeerIdentity(deviceId: 'a', certificate: certA),
      pinnedFingerprints: pins,
    );

    final result = await sessionA.syncNow(
      remote: SyncPeerIdentity(deviceId: 'b', certificate: certB),
    );

    expect(result.connected, isFalse);
    expect(result.refusedReason, contains('same Wi-Fi'));
    expect(result.entriesSent, 0);
    expect(result.entriesReceived, 0);
  });

  test('Android background sync flag is exposed on the session', () {
    final session = PeerSyncSession(
      transport: transportA,
      ledger: ledgerA,
      reachability: reachability,
      localIdentity: SyncPeerIdentity(deviceId: 'a', certificate: certA),
      pinnedFingerprints: pins,
      allowAndroidBackgroundSync: true,
    );
    expect(session.allowAndroidBackgroundSync, isTrue);
  });
}
