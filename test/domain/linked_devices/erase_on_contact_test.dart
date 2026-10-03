import 'dart:async';

import 'package:drift/drift.dart';
import 'package:smara_accounting/domain/linked_devices/erase_on_contact.dart';
import 'package:smara_accounting/domain/peer_sync/peer_sync_session.dart';
import 'package:smara_accounting/domain/peer_sync/sync_payloads.dart';
import 'package:smara_accounting/domain/peer_sync/sync_transport.dart';
import 'package:test/test.dart';

import '../../harness/dual_device_harness.dart';

void main() {
  late DualDeviceHarness harness;

  setUp(() async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    harness = DualDeviceHarness(networkId: 'erase-contact');
    await harness.setUp();
    await harness.link();
  });

  tearDown(() async {
    await harness.tearDown();
  });

  test(
    'erase on next contact wipes joiner books and reports Erased on date',
    () async {
      await harness.a.membership.removeDevice(
        actorDeviceId: harness.a.deviceId,
        targetDeviceId: harness.b.deviceId,
      );
      final pending = await harness.a.membership.markErasePending(
        actorDeviceId: harness.a.deviceId,
        targetDeviceId: harness.b.deviceId,
      );
      expect(pending.isErasePending, isTrue);

      // Lifecycle ops synthesized from Owner membership (real sync path).
      final lifecycle = await harness.a.merge.pendingMetadataOperations();
      final eraseOps = lifecycle
          .where(
            (op) =>
                op.entityType == 'linked_device' &&
                op.entityId == harness.b.deviceId &&
                (op.field == 'removedAt' || op.field == 'erasePendingAt'),
          )
          .toList();
      expect(eraseOps, isNotEmpty);

      await harness.b.merge.applyMetadataOps(MetadataOps(operations: eraseOps));

      var wiped = false;
      final erasedAt = await EraseOnContact.maybeEraseLocalCopy(
        membership: harness.b.membership,
        localDeviceId: harness.b.deviceId,
        wipeLocalBooksCopy: () async {
          wiped = true;
          await harness.b.merge.wipeLocalLedgerForErase();
        },
        clock: () => DateTime.utc(2026, 10, 2, 15),
      );
      expect(wiped, isTrue);
      expect(erasedAt, DateTime.utc(2026, 10, 2, 15));

      final erased = await EraseOnContact.acknowledgeErased(
        membership: harness.a.membership,
        targetDeviceId: harness.b.deviceId,
        erasedAt: erasedAt!,
      );
      expect(erased.isErased, isTrue);
      expect(erased.erasedAt!.toUtc(), erasedAt.toUtc());
    },
  );

  test('two-instance sync delivers erasePending and erasedAt ack', () async {
    await harness.a.membership.removeDevice(
      actorDeviceId: harness.a.deviceId,
      targetDeviceId: harness.b.deviceId,
    );
    await harness.a.membership.markErasePending(
      actorDeviceId: harness.a.deviceId,
      targetDeviceId: harness.b.deviceId,
    );

    var wiped = false;
    final hooksB = PeerSyncSessionHooks(
      afterPeerMetadataApplied: () async {
        final erasedAt = await EraseOnContact.maybeEraseLocalCopy(
          membership: harness.b.membership,
          localDeviceId: harness.b.deviceId,
          wipeLocalBooksCopy: () async {
            wiped = true;
            await harness.b.merge.wipeLocalLedgerForErase();
          },
          clock: () => DateTime.utc(2026, 10, 3, 12),
        );
        if (erasedAt == null) return const [];
        await harness.b.membership.markErased(
          targetDeviceId: harness.b.deviceId,
          at: erasedAt,
        );
        return harness.b.merge.pendingMetadataOperations().then(
          (ops) => ops
              .where(
                (op) =>
                    op.entityType == 'linked_device' &&
                    op.entityId == harness.b.deviceId &&
                    op.field == 'erasedAt',
              )
              .toList(),
        );
      },
    );

    final pins = harness.pinnedFingerprints;
    final senderSession = PeerSyncSession(
      transport: harness.a.transport,
      ledger: harness.a.merge,
      reachability: harness.reachability,
      localIdentity: SyncPeerIdentity(
        deviceId: harness.a.deviceId,
        certificate: harness.a.certificate,
      ),
      pinnedFingerprints: pins,
    );
    final receiverSession = PeerSyncSession(
      transport: harness.b.transport,
      ledger: harness.b.merge,
      reachability: harness.reachability,
      localIdentity: SyncPeerIdentity(
        deviceId: harness.b.deviceId,
        certificate: harness.b.certificate,
      ),
      pinnedFingerprints: pins,
      hooks: hooksB,
    );

    final done = Completer<SyncSessionResult>();
    await receiverSession.startListening(onCompleted: done.complete);
    await senderSession.syncNow(
      remote: SyncPeerIdentity(
        deviceId: harness.b.deviceId,
        certificate: harness.b.certificate,
      ),
    );
    await done.future.timeout(const Duration(seconds: 5));
    await receiverSession.stopListening();

    expect(wiped, isTrue);
    final onOwner = await harness.a.membership.findByDeviceId(
      harness.b.deviceId,
    );
    expect(onOwner?.isErased, isTrue);
    expect(onOwner?.erasedAt?.toUtc(), DateTime.utc(2026, 10, 3, 12));
  });
}
