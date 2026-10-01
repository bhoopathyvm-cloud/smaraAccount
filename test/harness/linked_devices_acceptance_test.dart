import 'dart:typed_data';

import 'package:smara_accounting/domain/crypto/entry_canonical_hash.dart';
import 'package:smara_accounting/domain/models/linked_device_role.dart';
import 'package:smara_accounting/domain/models/membership_notice.dart';
import 'package:smara_accounting/domain/models/transaction_direction.dart';
import 'package:smara_accounting/domain/peer_sync/sync_payloads.dart';
import 'package:test/test.dart';

import 'dual_device_harness.dart';

/// CI-runnable linked-devices acceptance group (task 9.2). No physical
/// devices — uses [DualDeviceHarness]. Invoked by
/// `tool/run_acceptance_tests.sh … linked_devices` and by `flutter test`.
void main() {
  group('linked_devices', () {
    late DualDeviceHarness harness;
    late DateTime now;

    setUp(() async {
      now = DateTime.utc(2026, 6, 1, 12);
      harness = DualDeviceHarness(clock: () => now);
      await harness.setUp();
    });

    tearDown(() async {
      await harness.tearDown();
    });

    test('join links A and B for the same books', () async {
      await harness.link();

      final aDevices = await harness.a.membership.listActiveDevices();
      final bDevices = await harness.b.membership.listActiveDevices();
      expect(
        aDevices.map((d) => d.deviceId),
        containsAll(['device-a', 'device-b']),
      );
      expect(
        bDevices.map((d) => d.deviceId),
        containsAll(['device-a', 'device-b']),
      );
      expect(
        aDevices.firstWhere((d) => d.deviceId == 'device-a').role,
        LinkedDeviceRole.owner,
      );
    });

    test('sync exchanges a missing entry', () async {
      await harness.link();
      final id = await harness.a.recordSpend(
        amountMinor: 1200,
        description: 'groceries',
      );
      final result = await harness.syncNow(from: harness.a, to: harness.b);
      expect(result.sender.connected, isTrue);
      expect(
        (await harness.b.ledger.watchEntries().first).map((e) => e.id),
        contains(id),
      );
    });

    test('reject bad signature', () async {
      await harness.link();
      final accountId = await harness.a.financialAccountId();
      final categoryId = await harness.a.expenseCategoryId();
      final aId = await harness.a.currentIdentityId();

      final postings = [
        CanonicalPosting(
          lineNumber: 1,
          accountId: accountId,
          amountMinor: -100,
        ),
        CanonicalPosting(
          lineNumber: 2,
          accountId: categoryId,
          amountMinor: 100,
        ),
      ];
      final at = DateTime.utc(2026, 4, 2);
      final bytes = canonicalEntryBytes(
        previousEntryHash: Uint8List.fromList(genesisPreviousEntryHash),
        id: 'tampered-1',
        deviceChainSequence: 99,
        transactionDate: '2026-04-02',
        recordedAt: at,
        description: 'bad',
        reversesEntryId: null,
        signedByIdentityId: aId,
        postings: postings,
      );
      final entryHash = await hashCanonicalEntry(bytes);
      final tampered = SyncJournalEntry(
        id: 'tampered-1',
        transactionDate: '2026-04-02',
        recordedAt: at,
        description: 'bad',
        reversesEntryId: null,
        deviceChainSequence: 99,
        previousEntryHash: Uint8List.fromList(genesisPreviousEntryHash),
        entryHash: entryHash,
        signedByIdentityId: aId,
        signature: List.filled(64, 7),
        postings: [
          SyncPosting(accountId: accountId, amountMinor: -100, lineNumber: 1),
          SyncPosting(accountId: categoryId, amountMinor: 100, lineNumber: 2),
        ],
      );

      final result = await harness.b.merge.mergeEntryBatch(
        EntryBatch(entries: [tampered]),
        fromDeviceId: harness.a.deviceId,
        fromDeviceDisplayName: harness.a.displayName,
      );
      expect(result.rejectedCount, 1);
      expect(result.insertedCount, 0);

      final notices = await harness.b.db
          .select(harness.b.db.membershipNotices)
          .get();
      expect(
        notices.map((n) => n.kind),
        contains(MembershipNoticeKind.entryNotAccepted),
      );
    });

    test('competing Fix: earlier wins', () async {
      await harness.link();
      final sharedAccountId = await harness.a.financialAccountId();
      final sharedCategoryId = await harness.a.expenseCategoryId();
      final originalId = await harness.a.recordSpend(
        amountMinor: 500,
        description: 'to-fix',
      );
      await harness.syncNow(from: harness.a, to: harness.b);

      await harness.a.ledger.fixPostedTransaction(
        entryId: originalId,
        amountMinor: 450,
        direction: TransactionDirection.moneyOut,
        categoryId: sharedCategoryId,
        financialAccountId: sharedAccountId,
        transactionDate: DateTime(2026, 4, 1),
        description: 'fixed-on-a',
      );

      now = now.add(const Duration(hours: 1));
      await harness.b.ledger.fixPostedTransaction(
        entryId: originalId,
        amountMinor: 400,
        direction: TransactionDirection.moneyOut,
        categoryId: sharedCategoryId,
        financialAccountId: sharedAccountId,
        transactionDate: DateTime(2026, 4, 1),
        description: 'fixed-on-b',
      );

      await harness.syncNow(from: harness.a, to: harness.b);
      await harness.syncNow(from: harness.b, to: harness.a);

      final noticesA = await harness.a.db
          .select(harness.a.db.membershipNotices)
          .get();
      final noticesB = await harness.b.db
          .select(harness.b.db.membershipNotices)
          .get();
      expect(
        [...noticesA, ...noticesB].map((n) => n.kind),
        contains(MembershipNoticeKind.competingFixCheck),
      );
    });

    test('metadata LWW applies books settings only', () async {
      await harness.link();
      final ops = MetadataOps(
        operations: [
          MetadataOperation(
            entityType: 'category',
            entityId: 'cat-1',
            field: 'name',
            value: 'Old',
            updatedAt: DateTime.utc(2026, 4, 1),
            updatedByIdentityId: 'id-a',
          ),
          MetadataOperation(
            entityType: 'category',
            entityId: 'cat-1',
            field: 'name',
            value: 'New',
            updatedAt: DateTime.utc(2026, 4, 2),
            updatedByIdentityId: 'id-b',
          ),
          MetadataOperation(
            entityType: 'settings',
            entityId: 'books',
            field: 'quoteProvider',
            value: 'yahoo',
            updatedAt: DateTime.utc(2026, 4, 2),
            updatedByIdentityId: 'id-b',
          ),
          MetadataOperation(
            entityType: 'settings',
            entityId: 'device',
            field: 'appLockEnabled',
            value: true,
            updatedAt: DateTime.utc(2026, 4, 3),
            updatedByIdentityId: 'id-b',
          ),
        ],
      );
      final merged = await harness.b.merge.applyMetadataOps(ops);
      expect(merged.firstWhere((o) => o.field == 'name').value, 'New');
      expect(harness.b.merge.appliedBooksSettings['quoteProvider'], 'yahoo');
      expect(
        harness.b.merge.appliedBooksSettings.containsKey('appLockEnabled'),
        isFalse,
      );
    });

    test('erase-pending via harness', () async {
      await harness.link();
      await harness.a.membership.removeDevice(
        actorDeviceId: harness.a.deviceId,
        targetDeviceId: harness.b.deviceId,
      );
      final pending = await harness.a.membership.markErasePending(
        actorDeviceId: harness.a.deviceId,
        targetDeviceId: harness.b.deviceId,
      );
      expect(pending.isErasePending, isTrue);

      now = now.add(const Duration(days: 1));
      final erased = await harness.a.membership.markErased(
        targetDeviceId: harness.b.deviceId,
      );
      expect(erased.isErased, isTrue);
    });
  });
}
