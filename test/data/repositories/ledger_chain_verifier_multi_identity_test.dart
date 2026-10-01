import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:smara_accounting/data/database/app_database.dart';
import 'package:smara_accounting/data/database/tables/accounts_table.dart';
import 'package:smara_accounting/data/repositories/account_repository.dart';
import 'package:smara_accounting/data/repositories/category_repository.dart';
import 'package:smara_accounting/data/repositories/identity_repository.dart';
import 'package:smara_accounting/data/repositories/ledger_chain_store.dart';
import 'package:smara_accounting/data/repositories/ledger_chain_verifier.dart';
import 'package:smara_accounting/data/repositories/ledger_repository.dart';
import 'package:smara_accounting/domain/crypto/entry_canonical_hash.dart';
import 'package:smara_accounting/domain/crypto/signing_key_service.dart';
import 'package:smara_accounting/domain/models/transaction_direction.dart';
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
  late LedgerChainVerifier verifier;

  setUp(() async {
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
    verifier = LedgerChainVerifier(
      database: db,
      chain: chain,
      signingKeyService: localKeys,
    );
    final generated = await identity.generateFirstIdentity();
    await identity.confirmFirstIdentity(generated, currency: 'USD');
  });

  tearDown(() async {
    await db.close();
  });

  Future<String> financialId() async =>
      (await accounts.watchFinancialAccounts().first).first.id;

  Future<String> incomeId() async => (await categories.watchCategories().first)
      .firstWhere((a) => a.type == AccountType.income)
      .id;

  /// Inserts a peer-signed entry that starts (or continues) that peer's
  /// own hash chain, using a globally unique deviceChainSequence.
  Future<String> insertPeerEntry({
    required SigningKeyService peerKeys,
    required String peerIdentityId,
    required Uint8List previousHash,
    required int sequence,
    required String description,
    required String financialAccountId,
    required String categoryId,
    required int amountMinor,
  }) async {
    final id = 'peer-entry-$sequence';
    final recordedAt = DateTime.utc(2026, 4, 1, 12, sequence);
    final postings = [
      CanonicalPosting(
        lineNumber: 1,
        accountId: financialAccountId,
        amountMinor: amountMinor,
      ),
      CanonicalPosting(
        lineNumber: 2,
        accountId: categoryId,
        amountMinor: -amountMinor,
      ),
    ];
    final bytes = canonicalEntryBytes(
      previousEntryHash: previousHash,
      id: id,
      deviceChainSequence: sequence,
      transactionDate: '2026-04-01',
      recordedAt: recordedAt,
      description: description,
      reversesEntryId: null,
      signedByIdentityId: peerIdentityId,
      postings: postings,
    );
    final entryHash = await hashCanonicalEntry(bytes);
    final signature = await peerKeys.sign(entryHash);
    await db
        .into(db.journalEntries)
        .insert(
          JournalEntriesCompanion.insert(
            id: Value(id),
            transactionDate: '2026-04-01',
            recordedAt: recordedAt,
            description: Value(description),
            deviceChainSequence: sequence,
            previousEntryHash: previousHash,
            entryHash: entryHash,
            signedByIdentityId: peerIdentityId,
            signature: signature,
          ),
        );
    await db
        .into(db.postings)
        .insert(
          PostingsCompanion.insert(
            entryId: id,
            accountId: financialAccountId,
            amountMinor: amountMinor,
            lineNumber: 1,
          ),
        );
    await db
        .into(db.postings)
        .insert(
          PostingsCompanion.insert(
            entryId: id,
            accountId: categoryId,
            amountMinor: -amountMinor,
            lineNumber: 2,
          ),
        );
    await chain.updateIdentityTip(
      identityId: peerIdentityId,
      trustedTipEntryId: id,
      trustedTipHash: entryHash,
      nextDeviceChainSequence: sequence + 1,
    );
    return id;
  }

  test('entries from two active identities both verify', () async {
    final accountId = await financialId();
    final categoryId = await incomeId();
    await ledger.recordTransaction(
      amountMinor: 1000,
      direction: TransactionDirection.moneyIn,
      categoryId: categoryId,
      financialAccountId: accountId,
      transactionDate: DateTime(2026, 1, 15),
      description: 'local-1',
    );

    final peerStorage = InMemorySecureKeyStorage();
    final peerKeys = SigningKeyService(secureStorage: peerStorage);
    final peerGenerated = await peerKeys.generateNewIdentity();
    final peer = await identity.addLinkedPeerIdentity(
      publicKey: peerGenerated.keyMaterial.publicKey,
    );
    expect(peer.continuedAt, isNull);

    final local = (await identity.currentIdentity())!;
    expect(local.continuedAt, isNull);
    expect(local.identityId, isNot(peer.identityId));

    await insertPeerEntry(
      peerKeys: peerKeys,
      peerIdentityId: peer.identityId,
      previousHash: Uint8List.fromList(genesisPreviousEntryHash),
      sequence: 100,
      description: 'peer-1',
      financialAccountId: accountId,
      categoryId: categoryId,
      amountMinor: 400,
    );

    final result = await verifier.verifyChain();
    expect(result.isFullyVerified, isTrue);

    final entries = await ledger.watchEntries().first;
    expect(entries, hasLength(2));
    expect(entries.every((e) => e.isVerified), isTrue);

    final summary = await ledger
        .watchSummary(start: DateTime(2020), end: DateTime(2030))
        .first;
    expect(summary.totalIncomeMinor, 1400);
  });

  test(
    'break on one identity does not quarantine the other identity',
    () async {
      final accountId = await financialId();
      final categoryId = await incomeId();
      await ledger.recordTransaction(
        amountMinor: 1000,
        direction: TransactionDirection.moneyIn,
        categoryId: categoryId,
        financialAccountId: accountId,
        transactionDate: DateTime(2026, 1, 15),
        description: 'local-ok',
      );

      final peerStorage = InMemorySecureKeyStorage();
      final peerKeys = SigningKeyService(secureStorage: peerStorage);
      final peerGenerated = await peerKeys.generateNewIdentity();
      final peer = await identity.addLinkedPeerIdentity(
        publicKey: peerGenerated.keyMaterial.publicKey,
      );

      final peerFirst = await insertPeerEntry(
        peerKeys: peerKeys,
        peerIdentityId: peer.identityId,
        previousHash: Uint8List.fromList(genesisPreviousEntryHash),
        sequence: 100,
        description: 'peer-ok',
        financialAccountId: accountId,
        categoryId: categoryId,
        amountMinor: 200,
      );
      final peerTip = (await chain.loadIdentityTip(peer.identityId))!;
      await insertPeerEntry(
        peerKeys: peerKeys,
        peerIdentityId: peer.identityId,
        previousHash: peerTip.trustedTipHash!,
        sequence: 101,
        description: 'peer-break',
        financialAccountId: accountId,
        categoryId: categoryId,
        amountMinor: 50,
      );

      await (db.update(
        db.journalEntries,
      )..where((e) => e.description.equals('peer-break'))).write(
        const JournalEntriesCompanion(description: Value('peer-tampered')),
      );

      final result = await verifier.verifyChain();
      expect(result.isFullyVerified, isFalse);

      final entries = await ledger.watchEntries().first;
      final localEntry = entries.firstWhere((e) => e.description == 'local-ok');
      final peerOk = entries.firstWhere((e) => e.id == peerFirst);
      final peerBroken = entries.firstWhere(
        (e) => e.description == 'peer-tampered',
      );
      expect(localEntry.isVerified, isTrue);
      expect(peerOk.isVerified, isTrue);
      expect(peerBroken.isVerified, isFalse);

      final summary = await ledger
          .watchSummary(start: DateTime(2020), end: DateTime(2030))
          .first;
      // Local 1000 + peer-ok 200; tampered peer entry quarantined.
      expect(summary.totalIncomeMinor, 1200);
    },
  );

  test('missing public key fails closed', () async {
    final accountId = await financialId();
    final categoryId = await incomeId();

    // Build a peer-signed entry, then remove that identity's public key
    // from the books so verification cannot resolve it.
    final peerStorage = InMemorySecureKeyStorage();
    final peerKeys = SigningKeyService(secureStorage: peerStorage);
    final peerGenerated = await peerKeys.generateNewIdentity();
    final peer = await identity.addLinkedPeerIdentity(
      publicKey: peerGenerated.keyMaterial.publicKey,
    );
    await insertPeerEntry(
      peerKeys: peerKeys,
      peerIdentityId: peer.identityId,
      previousHash: Uint8List.fromList(genesisPreviousEntryHash),
      sequence: 100,
      description: 'orphan-entry',
      financialAccountId: accountId,
      categoryId: categoryId,
      amountMinor: 100,
    );

    await db.customStatement('PRAGMA foreign_keys = OFF');
    await (db.delete(
      db.signingIdentities,
    )..where((t) => t.identityId.equals(peer.identityId))).go();
    await db.customStatement('PRAGMA foreign_keys = ON');

    final result = await verifier.verifyChain();
    expect(result.isFullyVerified, isFalse);
    final after = await ledger.watchEntries().first;
    expect(
      after.firstWhere((e) => e.description == 'orphan-entry').isVerified,
      isFalse,
    );
  });

  test(
    'linking a peer does not set continuedAt; Continuation still does',
    () async {
      final accountId = await financialId();
      final categoryId = await incomeId();
      await ledger.recordTransaction(
        amountMinor: 500,
        direction: TransactionDirection.moneyIn,
        categoryId: categoryId,
        financialAccountId: accountId,
        transactionDate: DateTime(2026, 1, 15),
      );

      final peerStorage = InMemorySecureKeyStorage();
      final peerKeys = SigningKeyService(secureStorage: peerStorage);
      final peerGenerated = await peerKeys.generateNewIdentity();
      final peer = await identity.addLinkedPeerIdentity(
        publicKey: peerGenerated.keyMaterial.publicKey,
      );
      final peerRow = await (db.select(
        db.signingIdentities,
      )..where((t) => t.identityId.equals(peer.identityId))).getSingle();
      expect(peerRow.continuedAt, isNull);
      expect(peerRow.continuesIdentityId, isNull);

      final localBefore = (await identity.currentIdentity())!;
      expect(localBefore.continuedAt, isNull);

      await identity.deleteStoredKey();
      final continued = await identity.continueBooks();
      expect(continued.continuesIdentityId, localBefore.identityId);

      final previousRow = await (db.select(
        db.signingIdentities,
      )..where((t) => t.identityId.equals(localBefore.identityId))).getSingle();
      expect(previousRow.continuedAt, isNotNull);

      // Peer remains active (not continued).
      final peerAfter = await (db.select(
        db.signingIdentities,
      )..where((t) => t.identityId.equals(peer.identityId))).getSingle();
      expect(peerAfter.continuedAt, isNull);

      final active = await chain.activeSigningIdentities();
      expect(active.map((i) => i.identityId), contains(peer.identityId));
      expect(active.map((i) => i.identityId), contains(continued.identityId));
      expect(
        active.map((i) => i.identityId),
        isNot(contains(localBefore.identityId)),
      );
    },
  );

  test(
    'local device signs onto its own tip after a peer entry is present',
    () async {
      final accountId = await financialId();
      final categoryId = await incomeId();
      await ledger.recordTransaction(
        amountMinor: 1000,
        direction: TransactionDirection.moneyIn,
        categoryId: categoryId,
        financialAccountId: accountId,
        transactionDate: DateTime(2026, 1, 15),
        description: 'local-1',
      );
      final localFirst = (await ledger.watchEntries().first).single;

      final peerStorage = InMemorySecureKeyStorage();
      final peerKeys = SigningKeyService(secureStorage: peerStorage);
      final peerGenerated = await peerKeys.generateNewIdentity();
      final peer = await identity.addLinkedPeerIdentity(
        publicKey: peerGenerated.keyMaterial.publicKey,
      );
      await insertPeerEntry(
        peerKeys: peerKeys,
        peerIdentityId: peer.identityId,
        previousHash: Uint8List.fromList(genesisPreviousEntryHash),
        sequence: 50,
        description: 'peer-1',
        financialAccountId: accountId,
        categoryId: categoryId,
        amountMinor: 300,
      );

      await verifier.verifyChain();

      await ledger.recordTransaction(
        amountMinor: 200,
        direction: TransactionDirection.moneyIn,
        categoryId: categoryId,
        financialAccountId: accountId,
        transactionDate: DateTime(2026, 1, 16),
        description: 'local-2',
      );

      final local = (await identity.currentIdentity())!;
      final entries = await ledger.watchEntries().first;
      final localSecond = entries.firstWhere((e) => e.description == 'local-2');
      expect(localSecond.signedByIdentityId, local.identityId);
      final localSecondRow = await (db.select(
        db.journalEntries,
      )..where((e) => e.id.equals(localSecond.id))).getSingle();
      expect(localSecondRow.previousEntryHash, localFirst.entryHash);

      final result = await verifier.verifyChain();
      expect(result.isFullyVerified, isTrue);

      final summary = await ledger
          .watchSummary(start: DateTime(2020), end: DateTime(2030))
          .first;
      expect(summary.totalIncomeMinor, 1500);
    },
  );
}
