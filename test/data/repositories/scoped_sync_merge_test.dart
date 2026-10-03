import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:smara_accounting/data/database/app_database.dart';
import 'package:smara_accounting/data/repositories/account_repository.dart';
import 'package:smara_accounting/data/repositories/identity_repository.dart';
import 'package:smara_accounting/data/repositories/ledger_chain_store.dart';
import 'package:smara_accounting/data/repositories/ledger_repository.dart';
import 'package:smara_accounting/data/repositories/sync_merge_repository.dart';
import 'package:smara_accounting/domain/crypto/entry_canonical_hash.dart';
import 'package:smara_accounting/domain/crypto/signing_key_service.dart';
import 'package:smara_accounting/domain/models/linked_device_role.dart';
import 'package:smara_accounting/domain/peer_sync/claim_sync_payloads.dart';
import 'package:smara_accounting/domain/peer_sync/sync_payloads.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

import '../../domain/crypto/in_memory_secure_key_storage.dart';

void main() {
  test(
    'Claimant merge accepts scoped Owner entries with chain anchors',
    () async {
      final ownerStorage = InMemorySecureKeyStorage();
      final ownerKeys = SigningKeyService(secureStorage: ownerStorage);
      final ownerGenerated = await ownerKeys.generateNewIdentity();
      final ownerIdentityId = const Uuid().v4();
      final ownerPub = ownerGenerated.keyMaterial.publicKey;

      Future<SyncJournalEntry> buildEntry({
        required int sequence,
        required List<int> previousHash,
        required String bankId,
        required String otherId,
        required int amount,
        required String id,
      }) async {
        final at = DateTime.utc(2026, 4, 1, 12, sequence);
        final postings = [
          CanonicalPosting(
            lineNumber: 1,
            accountId: bankId,
            amountMinor: -amount,
          ),
          CanonicalPosting(
            lineNumber: 2,
            accountId: otherId,
            amountMinor: amount,
          ),
        ];
        final bytes = canonicalEntryBytes(
          previousEntryHash: Uint8List.fromList(previousHash),
          id: id,
          deviceChainSequence: sequence,
          transactionDate: '2026-04-01',
          recordedAt: at,
          description: id,
          reversesEntryId: null,
          signedByIdentityId: ownerIdentityId,
          postings: postings,
        );
        final entryHash = await hashCanonicalEntry(bytes);
        final signature = await ownerKeys.sign(entryHash);
        return SyncJournalEntry(
          id: id,
          transactionDate: '2026-04-01',
          recordedAt: at,
          description: id,
          reversesEntryId: null,
          deviceChainSequence: sequence,
          previousEntryHash: previousHash,
          entryHash: entryHash,
          signedByIdentityId: ownerIdentityId,
          signature: signature,
          postings: [
            SyncPosting(accountId: bankId, amountMinor: -amount, lineNumber: 1),
            SyncPosting(accountId: otherId, amountMinor: amount, lineNumber: 2),
          ],
        );
      }

      final seq0 = await buildEntry(
        sequence: 0,
        previousHash: genesisPreviousEntryHash,
        bankId: 'bank',
        otherId: 'rent',
        amount: 900,
        id: 'out-of-scope',
      );
      final seq1 = await buildEntry(
        sequence: 1,
        previousHash: seq0.entryHash,
        bankId: 'bank',
        otherId: 'owed-ravi',
        amount: 20000,
        id: 'advance',
      );

      final full = EntryBatch(entries: [seq0, seq1]);
      final scoped = ClaimantSyncFilter.filterEntryBatch(
        batch: full,
        allowedAccountIds: {'bank', 'owed-ravi', 'travel'},
      );
      expect(scoped.entries.map((e) => e.id), ['advance']);
      expect(scoped.scopeAnchors.single.firstScopedSequence, 1);

      // Claimant DB with Owner public key + Claimant-only self.
      final claimantDb = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(claimantDb.close);
      final claimantKeys = SigningKeyService(
        secureStorage: InMemorySecureKeyStorage(),
      );
      final chain = LedgerChainStore(claimantDb);
      final ledger = LedgerRepository(
        database: claimantDb,
        signingKeyService: claimantKeys,
        chain: chain,
      );
      final accounts = AccountRepository(
        database: claimantDb,
        ledgerRepository: ledger,
      );
      final identity = IdentityRepository(
        database: claimantDb,
        accountRepository: accounts,
        chain: chain,
        signingKeyService: claimantKeys,
      );
      final generated = await identity.generateFirstIdentity();
      final localIdentity = await identity.confirmFirstIdentity(
        generated,
        currency: 'EUR',
      );
      await claimantDb
          .into(claimantDb.signingIdentities)
          .insertOnConflictUpdate(
            SigningIdentitiesCompanion.insert(
              identityId: Value(ownerIdentityId),
              publicKey: Uint8List.fromList(ownerPub),
            ),
          );
      await claimantDb
          .into(claimantDb.linkedDevices)
          .insert(
            LinkedDevicesCompanion.insert(
              deviceId: 'claimant-device',
              displayName: 'Ravi',
              signingIdentityId: localIdentity.identityId,
              deviceCertFingerprint: 'fp-c',
              role: LinkedDeviceRole.claimant,
              rolesCsv: Value(
                MembershipRoleGates.encodeRoles({LinkedDeviceRole.claimant}),
              ),
            ),
          );

      final merge = SyncMergeRepository(
        database: claimantDb,
        signingKeyService: claimantKeys,
        chain: chain,
        localDeviceId: () async => 'claimant-device',
      );

      final result = await merge.mergeEntryBatch(
        scoped,
        fromDeviceId: 'owner',
        fromDeviceDisplayName: 'Owner',
        emitOwnerAlert: false,
      );
      expect(result.rejectedCount, 0);
      expect(result.insertedCount, 1);

      // Full member without anchors still rejects the sparse batch.
      final memberDb = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(memberDb.close);
      final memberKeys = SigningKeyService(
        secureStorage: InMemorySecureKeyStorage(),
      );
      final memberChain = LedgerChainStore(memberDb);
      final memberLedger = LedgerRepository(
        database: memberDb,
        signingKeyService: memberKeys,
        chain: memberChain,
      );
      final memberAccounts = AccountRepository(
        database: memberDb,
        ledgerRepository: memberLedger,
      );
      final memberIdentity = IdentityRepository(
        database: memberDb,
        accountRepository: memberAccounts,
        chain: memberChain,
        signingKeyService: memberKeys,
      );
      final memberGen = await memberIdentity.generateFirstIdentity();
      await memberIdentity.confirmFirstIdentity(memberGen, currency: 'EUR');
      await memberDb
          .into(memberDb.signingIdentities)
          .insertOnConflictUpdate(
            SigningIdentitiesCompanion.insert(
              identityId: Value(ownerIdentityId),
              publicKey: Uint8List.fromList(ownerPub),
            ),
          );
      final memberMerge = SyncMergeRepository(
        database: memberDb,
        signingKeyService: memberKeys,
        chain: memberChain,
      );
      final stripped = EntryBatch(entries: scoped.entries);
      final memberResult = await memberMerge.mergeEntryBatch(
        stripped,
        fromDeviceId: 'owner',
        fromDeviceDisplayName: 'Owner',
        emitOwnerAlert: false,
      );
      expect(memberResult.rejectedCount, 1);
      expect(memberResult.insertedCount, 0);
    },
  );
}
