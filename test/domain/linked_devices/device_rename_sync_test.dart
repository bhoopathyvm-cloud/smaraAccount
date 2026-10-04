import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:smara_accounting/data/repositories/metadata_outbox.dart';
import 'package:smara_accounting/domain/peer_sync/sync_payloads.dart';
import 'package:test/test.dart';

import '../../harness/dual_device_harness.dart';

void main() {
  late DualDeviceHarness harness;

  setUp(() async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    harness = DualDeviceHarness(networkId: 'device-rename');
    await harness.setUp();
    await harness.link();
  });

  tearDown(() async {
    await harness.tearDown();
  });

  // Every device used to show as "This device"; a rename must reach peers.
  test('a renamed device shows its new name on the peer after sync', () async {
    final a = harness.a;
    await a.membership.renameDevice(
      deviceId: a.deviceId,
      displayName: 'Office Mac',
    );
    final identity = await a.identity.currentIdentity();
    final outbox = MetadataOutbox(database: a.db);
    await outbox.emit(
      entityType: 'linked_device',
      entityId: a.deviceId,
      field: 'displayName',
      value: 'Office Mac',
      updatedByIdentityId: identity!.identityId,
    );

    // The app's SyncMergeRepository sends outbox ops with every sync; the
    // harness merge has no outbox, so read them from it directly.
    final ops = (await outbox.listAll())
        .where(
          (o) => o.entityType == 'linked_device' && o.field == 'displayName',
        )
        .toList();
    expect(ops, isNotEmpty);
    await harness.b.merge.applyMetadataOps(MetadataOps(operations: ops));

    final onB = await harness.b.membership.findByDeviceId(a.deviceId);
    expect(onB!.displayName, 'Office Mac');
  });

  test('renaming a device that is not a member does nothing', () async {
    expect(
      await harness.a.membership.renameDevice(
        deviceId: 'not-a-member',
        displayName: 'Ghost',
      ),
      isNull,
    );
  });
}
