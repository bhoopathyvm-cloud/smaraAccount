import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:smara_accounting/data/database/app_database.dart';
import 'package:smara_accounting/data/database/tables/accounts_table.dart';
import 'package:smara_accounting/data/repositories/account_chart_reader.dart';
import 'package:smara_accounting/data/repositories/account_repository.dart';
import 'package:smara_accounting/data/repositories/category_repository.dart';
import 'package:smara_accounting/data/repositories/identity_repository.dart';
import 'package:smara_accounting/data/repositories/ledger_chain_store.dart';
import 'package:smara_accounting/data/repositories/ledger_posting.dart';
import 'package:smara_accounting/data/repositories/ledger_repository.dart';
import 'package:smara_accounting/data/repositories/sync_merge_repository.dart';
import 'package:smara_accounting/domain/crypto/entry_canonical_hash.dart';
import 'package:smara_accounting/domain/crypto/signing_key_service.dart';
import 'package:smara_accounting/domain/models/claim_status.dart';
import 'package:smara_accounting/domain/models/linked_device_role.dart';
import 'package:smara_accounting/domain/models/membership_notice.dart';
import 'package:smara_accounting/domain/models/transaction_direction.dart';
import 'package:smara_accounting/domain/peer_sync/sync_payloads.dart';
import 'package:test/test.dart';

import '../../domain/crypto/in_memory_secure_key_storage.dart';

void main() {
  late AppDatabase db;
  late InMemorySecureKeyStorage localStorage;
  late SigningKeyService localKeys;
  late LedgerRepository ledger;
  late AccountRepository accounts;
  late CategoryRepository categories;
  late IdentityRepository identity;
  late LedgerChainStore chain;
  late LedgerPosting posting;
  late SyncMergeRepository merge;
  late DateTime now;

  setUp(() async {
    now = DateTime.utc(2026, 5, 1, 12);
    db = AppDatabase.forTesting(NativeDatabase.memory());
    localStorage = InMemorySecureKeyStorage();
    localKeys = SigningKeyService(secureStorage: localStorage);
    chain = LedgerChainStore(db);
    ledger = LedgerRepository(
      database: db,
      signingKeyService: localKeys,
      chain: chain,
    );
    accounts = AccountRepository(database: db, ledgerRepository: ledger);
    categories = CategoryRepository(database: db);
    identity = IdentityRepository(
      database: db,
      accountRepository: accounts,
      chain: chain,
      signingKeyService: localKeys,
    );
    posting = LedgerPosting(
      database: db,
      chart: AccountChartReader(db),
      chain: chain,
      entriesForAccount: (id) => ledger.watchEntriesForAccount(id).first,
      signingKeyService: localKeys,
    );
    merge = SyncMergeRepository(
      database: db,
      signingKeyService: localKeys,
      chain: chain,
      posting: posting,
      clock: () => now,
    );

    final generated = await identity.generateFirstIdentity();
    await identity.confirmFirstIdentity(generated, currency: 'USD');
  });

  tearDown(() async {
    await db.close();
  });

  Future<String> financialId() async =>
      (await accounts.watchFinancialAccounts().first).first.id;

  Future<String> expenseId() async => (await categories.watchCategories().first)
      .firstWhere((a) => a.type == AccountType.expense)
      .id;

  Future<({SigningKeyService keys, String identityId})> addPeer() async {
    final peerStorage = InMemorySecureKeyStorage();
    final peerKeys = SigningKeyService(secureStorage: peerStorage);
    final generated = await peerKeys.generateNewIdentity();
    final peer = await identity.addLinkedPeerIdentity(
      publicKey: generated.keyMaterial.publicKey,
    );
    return (keys: peerKeys, identityId: peer.identityId);
  }

  Future<SyncJournalEntry> buildPeerEntry({
    required SigningKeyService peerKeys,
    required String peerIdentityId,
    required Uint8List previousHash,
    required int sequence,
    required String financialAccountId,
    required String categoryId,
    required int amountMinor,
    String? id,
    String? description,
    String? reversesEntryId,
    DateTime? recordedAt,
  }) async {
    final entryId = id ?? 'peer-$sequence';
    final at = recordedAt ?? DateTime.utc(2026, 4, 1, 12, sequence);
    final postings = [
      CanonicalPosting(
        lineNumber: 1,
        accountId: financialAccountId,
        amountMinor: -amountMinor,
      ),
      CanonicalPosting(
        lineNumber: 2,
        accountId: categoryId,
        amountMinor: amountMinor,
      ),
    ];
    final bytes = canonicalEntryBytes(
      previousEntryHash: previousHash,
      id: entryId,
      deviceChainSequence: sequence,
      transactionDate: '2026-04-01',
      recordedAt: at,
      description: description ?? 'peer-$sequence',
      reversesEntryId: reversesEntryId,
      signedByIdentityId: peerIdentityId,
      postings: postings,
    );
    final entryHash = await hashCanonicalEntry(bytes);
    final signature = await peerKeys.sign(entryHash);
    return SyncJournalEntry(
      id: entryId,
      transactionDate: '2026-04-01',
      recordedAt: at,
      description: description ?? 'peer-$sequence',
      reversesEntryId: reversesEntryId,
      deviceChainSequence: sequence,
      previousEntryHash: previousHash,
      entryHash: entryHash,
      signedByIdentityId: peerIdentityId,
      signature: signature,
      postings: [
        SyncPosting(
          accountId: financialAccountId,
          amountMinor: -amountMinor,
          lineNumber: 1,
        ),
        SyncPosting(
          accountId: categoryId,
          amountMinor: amountMinor,
          lineNumber: 2,
        ),
      ],
    );
  }

  test(
    '6.1 inserts peer entry; original on A unchanged; skips duplicates',
    () async {
      final accountId = await financialId();
      final categoryId = await expenseId();
      final localId = await ledger.recordTransaction(
        amountMinor: 1000,
        direction: TransactionDirection.moneyOut,
        categoryId: categoryId,
        financialAccountId: accountId,
        transactionDate: DateTime(2026, 1, 15),
        description: 'local-spend',
      );

      final peer = await addPeer();
      final peerEntry = await buildPeerEntry(
        peerKeys: peer.keys,
        peerIdentityId: peer.identityId,
        previousHash: Uint8List.fromList(genesisPreviousEntryHash),
        sequence: 0,
        financialAccountId: accountId,
        categoryId: categoryId,
        amountMinor: 400,
      );

      final first = await merge.mergeEntryBatch(
        EntryBatch(entries: [peerEntry]),
        fromDeviceId: 'device-b',
        fromDeviceDisplayName: 'Phone B',
      );
      expect(first.insertedCount, 1);

      final second = await merge.mergeEntryBatch(
        EntryBatch(entries: [peerEntry]),
        fromDeviceId: 'device-b',
        fromDeviceDisplayName: 'Phone B',
      );
      expect(second.insertedCount, 0);
      expect(second.skippedDuplicateCount, 1);

      final entries = await ledger.watchEntries().first;
      expect(entries.map((e) => e.id), containsAll([localId, peerEntry.id]));
      final local = entries.firstWhere((e) => e.id == localId);
      expect(local.description, 'local-spend');
      expect(local.deviceChainSequence, 0);
    },
  );

  test('6.2 rejects tampered signature and records notices', () async {
    final accountId = await financialId();
    final categoryId = await expenseId();
    final peer = await addPeer();
    final good = await buildPeerEntry(
      peerKeys: peer.keys,
      peerIdentityId: peer.identityId,
      previousHash: Uint8List.fromList(genesisPreviousEntryHash),
      sequence: 0,
      financialAccountId: accountId,
      categoryId: categoryId,
      amountMinor: 200,
    );
    final tampered = SyncJournalEntry(
      id: good.id,
      transactionDate: good.transactionDate,
      recordedAt: good.recordedAt,
      description: good.description,
      reversesEntryId: good.reversesEntryId,
      deviceChainSequence: good.deviceChainSequence,
      previousEntryHash: good.previousEntryHash,
      entryHash: good.entryHash,
      signedByIdentityId: good.signedByIdentityId,
      signature: List.filled(good.signature.length, 9),
      postings: good.postings,
    );

    final result = await merge.mergeEntryBatch(
      EntryBatch(entries: [tampered]),
      fromDeviceId: 'device-b',
      fromDeviceDisplayName: 'Phone B',
    );
    expect(result.rejectedCount, 1);
    expect(result.insertedCount, 0);

    final notices = await db.select(db.membershipNotices).get();
    expect(
      notices.map((n) => n.kind),
      containsAll([
        MembershipNoticeKind.entryNotAccepted,
        MembershipNoticeKind.ownerVerificationAlert,
      ]),
    );
    expect(
      notices
          .firstWhere((n) => n.kind == MembershipNoticeKind.entryNotAccepted)
          .detail,
      contains('Not accepted: couldn\'t be verified (from Phone B)'),
    );
    final stored = await db.select(db.journalEntries).get();
    expect(stored.where((e) => e.id == tampered.id), isEmpty);
  });

  test(
    '6.3 competing Fixes: earlier wins, loser cancelled, notice recorded',
    () async {
      final accountId = await financialId();
      final categoryId = await expenseId();
      final originalId = await ledger.recordTransaction(
        amountMinor: 500,
        direction: TransactionDirection.moneyOut,
        categoryId: categoryId,
        financialAccountId: accountId,
        transactionDate: DateTime(2026, 1, 10),
        description: 'to-fix',
      );

      // Local Fix (earlier).
      await ledger.fixPostedTransaction(
        entryId: originalId,
        amountMinor: 450,
        direction: TransactionDirection.moneyOut,
        categoryId: categoryId,
        financialAccountId: accountId,
        transactionDate: DateTime(2026, 1, 10),
        description: 'fixed-on-a',
      );

      final localReversal = await (db.select(
        db.journalEntries,
      )..where((e) => e.reversesEntryId.equals(originalId))).getSingle();

      final peer = await addPeer();
      // Peer Fix of the same original, recorded later — competing.
      final peerReversal = await buildPeerEntry(
        peerKeys: peer.keys,
        peerIdentityId: peer.identityId,
        previousHash: Uint8List.fromList(genesisPreviousEntryHash),
        sequence: 0,
        financialAccountId: accountId,
        categoryId: categoryId,
        amountMinor: 500,
        id: 'peer-reversal',
        reversesEntryId: originalId,
        recordedAt: DateTime.utc(2099, 1, 1),
        description: 'fixed-on-b-reversal',
      );

      final result = await merge.mergeEntryBatch(
        EntryBatch(entries: [peerReversal]),
        fromDeviceId: 'device-b',
        fromDeviceDisplayName: 'Phone B',
      );
      expect(result.insertedCount, 1);
      expect(result.competingFixCancellations, greaterThanOrEqualTo(1));

      final cancelOfPeer = await (db.select(
        db.journalEntries,
      )..where((e) => e.reversesEntryId.equals(peerReversal.id))).get();
      expect(cancelOfPeer, isNotEmpty);

      // Local (earlier) Fix reversal must not be cancelled.
      final cancelOfLocal = await (db.select(
        db.journalEntries,
      )..where((e) => e.reversesEntryId.equals(localReversal.id))).get();
      expect(cancelOfLocal, isEmpty);

      final notices = await db.select(db.membershipNotices).get();
      expect(
        notices.map((n) => n.kind),
        contains(MembershipNoticeKind.competingFixCheck),
      );
    },
  );

  test('6.4–6.5 MetadataOps LWW + books settings only', () async {
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
        MetadataOperation(
          entityType: 'settings',
          entityId: 'device',
          field: 'preferredLocaleTag',
          value: 'ta',
          updatedAt: DateTime.utc(2026, 4, 3),
          updatedByIdentityId: 'id-b',
        ),
      ],
    );

    final merged = await merge.applyMetadataOps(ops);
    final name = merged.firstWhere((o) => o.field == 'name');
    expect(name.value, 'New');
    expect(merge.appliedBooksSettings['quoteProvider'], 'yahoo');
    expect(merge.appliedBooksSettings.containsKey('appLockEnabled'), isFalse);
    expect(
      merge.appliedBooksSettings.containsKey('preferredLocaleTag'),
      isFalse,
    );
  });

  test('refuses entries signed by removed device after removal time', () async {
    final accountId = await financialId();
    final categoryId = await expenseId();
    final peer = await addPeer();

    await db
        .into(db.linkedDevices)
        .insert(
          LinkedDevicesCompanion.insert(
            deviceId: 'peer-device',
            displayName: 'Peer',
            signingIdentityId: peer.identityId,
            deviceCertFingerprint: 'fp-peer',
            role: LinkedDeviceRole.member,
            removedAt: Value(DateTime.utc(2026, 4, 1)),
          ),
        );

    final before = await buildPeerEntry(
      peerKeys: peer.keys,
      peerIdentityId: peer.identityId,
      previousHash: Uint8List.fromList(genesisPreviousEntryHash),
      sequence: 0,
      financialAccountId: accountId,
      categoryId: categoryId,
      amountMinor: 100,
      recordedAt: DateTime.utc(2026, 3, 15),
    );
    final after = await buildPeerEntry(
      peerKeys: peer.keys,
      peerIdentityId: peer.identityId,
      previousHash: Uint8List.fromList(before.entryHash),
      sequence: 1,
      financialAccountId: accountId,
      categoryId: categoryId,
      amountMinor: 200,
      recordedAt: DateTime.utc(2026, 5, 1),
    );

    final ok = await merge.mergeEntryBatch(
      EntryBatch(entries: [before]),
      fromDeviceId: 'peer-device',
      fromDeviceDisplayName: 'Peer',
    );
    expect(ok.insertedCount, 1);

    final refused = await merge.mergeEntryBatch(
      EntryBatch(entries: [after]),
      fromDeviceId: 'peer-device',
      fromDeviceDisplayName: 'Peer',
    );
    expect(refused.insertedCount, 0);
    expect(refused.rejectedCount, 1);
  });

  test(
    'ClaimBatch export/apply lands submitted claims for Approver queue',
    () async {
      final source = SyncMergeRepository(
        database: db,
        signingKeyService: localKeys,
        chain: chain,
        posting: posting,
      );
      await db
          .into(db.claims)
          .insert(
            ClaimsCompanion.insert(
              id: 'claim-1',
              claimantDeviceId: 'ravi-device',
              status: ClaimStatus.submitted,
              createdAt: Value(DateTime.utc(2026, 5, 1)),
              updatedAt: Value(DateTime.utc(2026, 5, 2)),
              submittedAt: Value(DateTime.utc(2026, 5, 2)),
            ),
          );
      final cats = await categories.watchCategories().first;
      final expense = cats.firstWhere((c) => c.type.name == 'expense');
      await db
          .into(db.claimItems)
          .insert(
            ClaimItemsCompanion.insert(
              id: const Value('item-1'),
              claimId: 'claim-1',
              categoryId: expense.id,
              expenseDate: '2026-05-01',
              paidCurrency: 'EUR',
              paidAmountMinor: 19000,
              companyCurrencyAmountMinor: 19000,
              description: const Value('Hotel'),
            ),
          );

      final batch = await source.pendingClaimBatch();
      expect(batch.claims, hasLength(1));
      expect(batch.claims.single.status, 'submitted');

      final peerDb = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(peerDb.close);
      final peerMerge = SyncMergeRepository(
        database: peerDb,
        signingKeyService: localKeys,
      );
      final applied = await peerMerge.applyPeerClaimBatch(batch);
      expect(applied, 1);
      final rows = await peerDb.select(peerDb.claims).get();
      expect(rows, hasLength(1));
      expect(rows.single.status.name, 'submitted');
      final items = await peerDb.select(peerDb.claimItems).get();
      expect(items.single.description, 'Hotel');
    },
  );
}
