import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:smara_accounting/data/database/app_database.dart';
import 'package:smara_accounting/data/database/tables/accounts_table.dart';
import 'package:smara_accounting/data/repositories/account_repository.dart';
import 'package:smara_accounting/data/repositories/category_repository.dart';
import 'package:smara_accounting/data/repositories/identity_repository.dart';
import 'package:smara_accounting/data/repositories/ledger_chain_verifier.dart';
import 'package:smara_accounting/data/repositories/ledger_repository.dart';
import 'package:smara_accounting/domain/crypto/signing_key_service.dart';
import 'package:smara_accounting/domain/models/integrity_event.dart';
import 'package:smara_accounting/domain/models/transaction_direction.dart';
import 'package:test/test.dart';

import '../../domain/crypto/in_memory_secure_key_storage.dart';

void main() {
  late AppDatabase db;
  late SigningKeyService signingKeyService;
  late InMemorySecureKeyStorage secureStorage;
  late LedgerRepository repository;
  late AccountRepository accountRepository;
  late CategoryRepository categoryRepository;
  late IdentityRepository identityRepository;
  late LedgerChainVerifier chainVerifier;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    secureStorage = InMemorySecureKeyStorage();
    signingKeyService = SigningKeyService(secureStorage: secureStorage);
    repository = LedgerRepository(
      database: db,
      signingKeyService: signingKeyService,
    );
    accountRepository = AccountRepository(
      database: db,
      ledgerRepository: repository,
    );
    categoryRepository = CategoryRepository(database: db);
    identityRepository = IdentityRepository(
      database: db,
      accountRepository: accountRepository,
      signingKeyService: signingKeyService,
    );
    chainVerifier = LedgerChainVerifier(
      database: db,
      signingKeyService: signingKeyService,
    );
    final generated = await identityRepository.generateFirstIdentity();
    await identityRepository.confirmFirstIdentity(generated, currency: 'USD');
  });

  tearDown(() async {
    await db.close();
  });

  Future<String> firstFinancialAccountId() async {
    final accounts = await accountRepository.watchFinancialAccounts().first;
    return accounts.first.id;
  }

  Future<String> firstIncomeCategoryId() async {
    final categories = await categoryRepository.watchCategories().first;
    return categories.firstWhere((a) => a.type == AccountType.income).id;
  }

  test(
    'clean books: Continuation links identities, keeps entries, and signs '
    'the next entry under the new identity',
    () async {
      final accountId = await firstFinancialAccountId();
      final incomeId = await firstIncomeCategoryId();
      await repository.recordTransaction(
        amountMinor: 1000,
        direction: TransactionDirection.moneyIn,
        categoryId: incomeId,
        financialAccountId: accountId,
        transactionDate: DateTime(2026, 1, 15),
      );
      final prior = (await repository.watchEntries().first).single;
      final oldIdentity = (await identityRepository.currentIdentity())!;

      await identityRepository.deleteStoredKey();
      final copySavedAt = DateTime.utc(2026, 1, 10);
      final newIdentity = await identityRepository.continueBooks(
        copySavedAt: copySavedAt,
      );

      expect(newIdentity.identityId, isNot(equals(oldIdentity.identityId)));
      expect(newIdentity.continuesIdentityId, equals(oldIdentity.identityId));
      expect(newIdentity.supersedesIdentityId, isNull);

      final previousRow =
          await (db.select(db.signingIdentities)
                ..where((t) => t.identityId.equals(oldIdentity.identityId)))
              .getSingle();
      expect(previousRow.continuedAt, isNotNull);
      expect(previousRow.supersededAt, isNull);

      final entriesAfter = await repository.watchEntries().first;
      expect(entriesAfter, hasLength(1));
      expect(entriesAfter.single.id, equals(prior.id));
      expect(
        entriesAfter.single.signedByIdentityId,
        equals(oldIdentity.identityId),
      );
      expect(entriesAfter.single.isVerified, isTrue);

      final events = await repository.watchIntegrityEvents().first;
      final continued = events.firstWhere(
        (e) => e.eventType == IntegrityEventType.identityContinued,
      );
      expect(continued.relatedIdentityId, equals(newIdentity.identityId));
      expect(continued.detail, contains(oldIdentity.identityId));
      expect(continued.detail, contains(copySavedAt.toIso8601String()));

      await repository.recordTransaction(
        amountMinor: 250,
        direction: TransactionDirection.moneyIn,
        categoryId: incomeId,
        financialAccountId: accountId,
        transactionDate: DateTime(2026, 1, 16),
      );
      final newest = (await repository.watchEntries().first).firstWhere(
        (e) => e.id != prior.id,
      );
      expect(newest.signedByIdentityId, equals(newIdentity.identityId));
      expect(newest.isVerified, isTrue);

      final verification = await chainVerifier.verifyChain();
      expect(verification.isFullyVerified, isTrue);

      final summary = await repository
          .watchSummary(
            start: DateTime(2020, 1, 1),
            end: DateTime(2030, 12, 31),
          )
          .first;
      expect(summary.totalIncomeMinor, equals(1250));
    },
  );

  test(
    'damaged tail is quarantined; Continuation tips at the trusted entry; '
    'earlier identity entries stay verified and counted; next entry uses '
    'the new identity',
    () async {
      final accountId = await firstFinancialAccountId();
      final incomeId = await firstIncomeCategoryId();
      await repository.recordTransaction(
        amountMinor: 1000,
        direction: TransactionDirection.moneyIn,
        categoryId: incomeId,
        financialAccountId: accountId,
        transactionDate: DateTime(2026, 1, 15),
      );
      await repository.recordTransaction(
        amountMinor: 500,
        direction: TransactionDirection.moneyIn,
        categoryId: incomeId,
        financialAccountId: accountId,
        transactionDate: DateTime(2026, 1, 16),
      );
      await repository.recordTransaction(
        amountMinor: 200,
        direction: TransactionDirection.moneyIn,
        categoryId: incomeId,
        financialAccountId: accountId,
        transactionDate: DateTime(2026, 1, 17),
      );

      final entries = await repository.watchEntries().first;
      final first = entries.firstWhere((e) => e.deviceChainSequence == 0);
      final middle = entries.firstWhere((e) => e.deviceChainSequence == 1);
      final last = entries.firstWhere((e) => e.deviceChainSequence == 2);
      final oldIdentity = (await identityRepository.currentIdentity())!;

      await (db.update(db.journalEntries)
            ..where((e) => e.id.equals(last.id)))
          .write(
            JournalEntriesCompanion(
              description: const Value('tampered outside the app'),
            ),
          );

      final breakResult = await chainVerifier.verifyChain();
      expect(breakResult.isFullyVerified, isFalse);
      expect(breakResult.breakEntryId, equals(last.id));

      final afterBreak = await repository.watchEntries().first;
      expect(
        afterBreak.firstWhere((e) => e.id == first.id).isVerified,
        isTrue,
      );
      expect(
        afterBreak.firstWhere((e) => e.id == middle.id).isVerified,
        isTrue,
      );
      expect(
        afterBreak.firstWhere((e) => e.id == last.id).isVerified,
        isFalse,
      );

      await identityRepository.deleteStoredKey();
      final newIdentity = await identityRepository.continueBooks();

      expect(newIdentity.continuesIdentityId, equals(oldIdentity.identityId));

      // Earlier identity's verified entries still verify and count once.
      final stillThere = await repository.watchEntries().first;
      expect(
        stillThere.firstWhere((e) => e.id == first.id).signedByIdentityId,
        equals(oldIdentity.identityId),
      );
      expect(
        stillThere.firstWhere((e) => e.id == first.id).isVerified,
        isTrue,
      );
      expect(
        stillThere.firstWhere((e) => e.id == middle.id).isVerified,
        isTrue,
      );

      final summary = await repository
          .watchSummary(
            start: DateTime(2020, 1, 1),
            end: DateTime(2030, 12, 31),
          )
          .first;
      // Quarantined tail is excluded from balances.
      expect(summary.totalIncomeMinor, equals(1500));

      await repository.recordTransaction(
        amountMinor: 75,
        direction: TransactionDirection.moneyIn,
        categoryId: incomeId,
        financialAccountId: accountId,
        transactionDate: DateTime(2026, 1, 18),
      );
      final next = (await repository.watchEntries().first).firstWhere(
        (e) => e.signedByIdentityId == newIdentity.identityId,
      );
      expect(next.isVerified, isTrue);

      final nextRow = await (db.select(db.journalEntries)
            ..where((e) => e.id.equals(next.id)))
          .getSingle();
      expect(
        nextRow.previousEntryHash,
        equals(Uint8List.fromList(middle.entryHash)),
      );
    },
  );

  test(
    'restoring a copy onto the phone that still holds its key does not '
    'create a Continuation',
    () async {
      final before = (await identityRepository.currentIdentity())!;
      final after = await identityRepository.continueBooks(
        copySavedAt: DateTime.utc(2026, 4, 1),
      );

      expect(after.identityId, equals(before.identityId));
      expect(after.continuesIdentityId, isNull);

      final events = await repository.watchIntegrityEvents().first;
      expect(
        events.where((e) => e.eventType == IntegrityEventType.identityContinued),
        isEmpty,
      );
    },
  );
}
