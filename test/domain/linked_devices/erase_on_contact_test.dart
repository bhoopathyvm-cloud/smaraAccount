import 'package:drift/drift.dart';
import 'package:smara_accounting/data/database/app_database.dart';
import 'package:smara_accounting/domain/linked_devices/erase_on_contact.dart';
import 'package:smara_accounting/domain/models/linked_device_role.dart';
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

      // Simulate B learning erase-pending for itself (membership sync).
      await harness.b.db
          .into(harness.b.db.linkedDevices)
          .insertOnConflictUpdate(
            LinkedDevicesCompanion.insert(
              deviceId: harness.b.deviceId,
              displayName: harness.b.displayName,
              signingIdentityId:
                  (await harness.b.identity.currentIdentity())!.identityId,
              deviceCertFingerprint: harness.b.certificate.fingerprint,
              role: LinkedDeviceRole.member,
              removedAt: Value(pending.removedAt),
              erasePendingAt: Value(pending.erasePendingAt),
            ),
          );

      var wiped = false;
      final erasedAt = await EraseOnContact.maybeEraseLocalCopy(
        membership: harness.b.membership,
        localDeviceId: harness.b.deviceId,
        wipeLocalBooksCopy: () async {
          wiped = true;
          await harness.b.db.delete(harness.b.db.journalEntries).go();
          await harness.b.db.delete(harness.b.db.postings).go();
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
}
