import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:smara_accounting/data/database/app_database.dart';
import 'package:smara_accounting/data/database/tables/accounts_table.dart';
import 'package:smara_accounting/data/repositories/ledger_repository.dart';
import 'package:smara_accounting/domain/crypto/signing_key_service.dart';
import 'package:smara_accounting/domain/exceptions.dart';
import 'package:smara_accounting/domain/models/integrity_event.dart';
import 'package:smara_accounting/domain/models/transaction_direction.dart';
import 'package:test/test.dart';

import '../../domain/crypto/in_memory_secure_key_storage.dart';

void main() {
  late AppDatabase db;
  late SigningKeyService signingKeyService;
  late LedgerRepository repository;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    signingKeyService = SigningKeyService(
      secureStorage: InMemorySecureKeyStorage(),
    );
    repository = LedgerRepository(
      database: db,
      signingKeyService: signingKeyService,
    );
    // Every test starts past onboarding - identity lifecycle itself is
    // covered by its own group below, using a fresh Repository/service.
    final generated = await repository.generateFirstIdentity();
    await repository.confirmFirstIdentity(generated);
  });

  tearDown(() async {
    await db.close();
  });

  Future<String> firstCategoryId(AccountType type) async {
    final categories = await repository.watchCategories().first;
    return categories.firstWhere((a) => a.type == type).id;
  }

  group('onCreate seeding', () {
    test('seeds the single asset account and starter categories', () async {
      final categories = await repository.watchCategories().first;
      expect(
        categories.map((a) => a.name),
        containsAll(starterIncomeCategories + starterExpenseCategories),
      );
      expect(categories.every((a) => a.type != AccountType.asset), isTrue);
    });
  });

  group('signing identity lifecycle', () {
    test('recordTransaction throws before an identity is confirmed', () async {
      final freshDb = AppDatabase.forTesting(NativeDatabase.memory());
      final freshRepository = LedgerRepository(
        database: freshDb,
        signingKeyService: SigningKeyService(
          secureStorage: InMemorySecureKeyStorage(),
        ),
      );
      addTearDown(freshDb.close);

      final categories = await freshRepository.watchCategories().first;
      final incomeId = categories
          .firstWhere((a) => a.type == AccountType.income)
          .id;

      expect(
        () => freshRepository.recordTransaction(
          amountMinor: 1000,
          direction: TransactionDirection.moneyIn,
          categoryId: incomeId,
          transactionDate: DateTime(2026, 1, 15),
        ),
        throwsStateError,
      );
    });

    test('currentIdentity is null until confirmFirstIdentity runs', () async {
      final freshDb = AppDatabase.forTesting(NativeDatabase.memory());
      final freshRepository = LedgerRepository(
        database: freshDb,
        signingKeyService: SigningKeyService(
          secureStorage: InMemorySecureKeyStorage(),
        ),
      );
      addTearDown(freshDb.close);

      expect(await freshRepository.currentIdentity(), isNull);

      final generated = await freshRepository.generateFirstIdentity();
      expect(await freshRepository.currentIdentity(), isNull);

      final confirmed = await freshRepository.confirmFirstIdentity(generated);
      expect(
        (await freshRepository.currentIdentity())!.identityId,
        equals(confirmed.identityId),
      );
    });

    test('hasMatchingStoredKey is true right after confirmation', () async {
      final identity = (await repository.currentIdentity())!;
      expect(await repository.hasMatchingStoredKey(identity), isTrue);
    });

    test(
      'restoreIdentity on a reinstalled device with the recovery phrase matches the original identity',
      () async {
        // Simulate a device that already has a confirmed identity and a
        // database file with history - capture the phrase the way
        // onboarding would have shown it to the user.
        final freshDb = AppDatabase.forTesting(NativeDatabase.memory());
        addTearDown(freshDb.close);
        final firstInstallRepository = LedgerRepository(
          database: freshDb,
          signingKeyService: SigningKeyService(
            secureStorage: InMemorySecureKeyStorage(),
          ),
        );
        final generated = await firstInstallRepository.generateFirstIdentity();
        final originalIdentity = await firstInstallRepository
            .confirmFirstIdentity(generated);

        // Reinstall: same database file, fresh secure storage (a new
        // SigningKeyService with empty InMemorySecureKeyStorage), same
        // Repository pointed at the same underlying db.
        final reinstalledRepository = LedgerRepository(
          database: freshDb,
          signingKeyService: SigningKeyService(
            secureStorage: InMemorySecureKeyStorage(),
          ),
        );

        final restored = await reinstalledRepository.restoreIdentity(
          recoveryPhraseWords: generated.phrase.words,
        );

        expect(restored.identityId, equals(originalIdentity.identityId));
        expect(
          await reinstalledRepository.hasMatchingStoredKey(restored),
          isTrue,
        );
      },
    );

    test(
      'restoreIdentity throws when the phrase does not belong to this database',
      () async {
        final identity = (await repository.currentIdentity())!;
        final unrelated = await repository.generateFirstIdentity();

        expect(
          () => repository.restoreIdentity(
            recoveryPhraseWords: unrelated.phrase.words,
          ),
          throwsA(isA<SigningIdentityMismatchException>()),
        );
        // Sanity: the original identity is still on record, untouched.
        expect(
          (await repository.currentIdentity())!.identityId,
          equals(identity.identityId),
        );
      },
    );
  });

  group('recordTransaction', () {
    test('money in credits income category, debits asset', () async {
      final incomeId = await firstCategoryId(AccountType.income);

      await repository.recordTransaction(
        amountMinor: 1000,
        direction: TransactionDirection.moneyIn,
        categoryId: incomeId,
        transactionDate: DateTime(2026, 1, 15),
      );

      final entries = await repository.watchEntries().first;
      expect(entries, hasLength(1));
      final entry = entries.single;
      expect(entry.postings, hasLength(2));
      expect(
        entry.postings.map((p) => p.amountMinor).toSet(),
        equals({1000, -1000}),
      );
      final categoryPosting = entry.postings.firstWhere(
        (p) => p.accountId == incomeId,
      );
      expect(categoryPosting.amountMinor, equals(-1000));
    });

    test('money out debits expense category, credits asset', () async {
      final expenseId = await firstCategoryId(AccountType.expense);

      await repository.recordTransaction(
        amountMinor: 500,
        direction: TransactionDirection.moneyOut,
        categoryId: expenseId,
        transactionDate: DateTime(2026, 1, 15),
      );

      final entry = (await repository.watchEntries().first).single;
      final categoryPosting = entry.postings.firstWhere(
        (p) => p.accountId == expenseId,
      );
      expect(categoryPosting.amountMinor, equals(500));
    });

    test('rejects a zero amount', () async {
      final incomeId = await firstCategoryId(AccountType.income);
      expect(
        () => repository.recordTransaction(
          amountMinor: 0,
          direction: TransactionDirection.moneyIn,
          categoryId: incomeId,
          transactionDate: DateTime(2026, 1, 15),
        ),
        throwsA(isA<InvalidTransactionAmountException>()),
      );
      expect(await repository.watchEntries().first, isEmpty);
    });

    test('rejects a negative amount', () async {
      final incomeId = await firstCategoryId(AccountType.income);
      expect(
        () => repository.recordTransaction(
          amountMinor: -100,
          direction: TransactionDirection.moneyIn,
          categoryId: incomeId,
          transactionDate: DateTime(2026, 1, 15),
        ),
        throwsA(isA<InvalidTransactionAmountException>()),
      );
    });

    test('stores the user-supplied transaction date as given and stamps '
        'recordedAt to the current time, independent of that date', () async {
      final incomeId = await firstCategoryId(AccountType.income);
      final backdatedDate = DateTime(2020, 3, 1);
      final before = DateTime.now();

      await repository.recordTransaction(
        amountMinor: 1000,
        direction: TransactionDirection.moneyIn,
        categoryId: incomeId,
        transactionDate: backdatedDate,
      );

      final after = DateTime.now();
      final entry = (await repository.watchEntries().first).single;

      expect(entry.transactionDate, equals(backdatedDate));
      expect(
        entry.recordedAt.isAfter(before.subtract(const Duration(seconds: 1))),
        isTrue,
      );
      expect(
        entry.recordedAt.isBefore(after.add(const Duration(seconds: 1))),
        isTrue,
      );
    });

    test(
      'the first entry chains onto the genesis hash and is immediately verified',
      () async {
        final incomeId = await firstCategoryId(AccountType.income);
        await repository.recordTransaction(
          amountMinor: 1000,
          direction: TransactionDirection.moneyIn,
          categoryId: incomeId,
          transactionDate: DateTime(2026, 1, 15),
        );

        final entry = (await repository.watchEntries().first).single;
        expect(entry.deviceChainSequence, equals(0));
        expect(entry.isVerified, isTrue);
        expect(entry.breakReason, isNull);
      },
    );

    test('a second entry chains onto the first entry\'s hash', () async {
      final incomeId = await firstCategoryId(AccountType.income);
      await repository.recordTransaction(
        amountMinor: 1000,
        direction: TransactionDirection.moneyIn,
        categoryId: incomeId,
        transactionDate: DateTime(2026, 1, 15),
      );
      await repository.recordTransaction(
        amountMinor: 500,
        direction: TransactionDirection.moneyIn,
        categoryId: incomeId,
        transactionDate: DateTime(2026, 1, 16),
      );

      final entries = await repository.watchEntries().first;
      final sorted = [
        ...entries,
      ]..sort((a, b) => a.deviceChainSequence.compareTo(b.deviceChainSequence));
      expect(sorted.map((e) => e.deviceChainSequence), equals([0, 1]));
    });
  });

  group('reverseEntry', () {
    test(
      'posts a new entry with swapped amounts, original unchanged',
      () async {
        final incomeId = await firstCategoryId(AccountType.income);
        await repository.recordTransaction(
          amountMinor: 1000,
          direction: TransactionDirection.moneyIn,
          categoryId: incomeId,
          transactionDate: DateTime(2026, 1, 15),
        );
        final original = (await repository.watchEntries().first).single;

        await repository.reverseEntry(original.id);

        final entries = await repository.watchEntries().first;
        expect(entries, hasLength(2));

        final unchangedOriginal = entries.firstWhere(
          (e) => e.id == original.id,
        );
        expect(
          unchangedOriginal.postings.map((p) => p.amountMinor).toSet(),
          equals({1000, -1000}),
        );

        final reversal = entries.firstWhere((e) => e.id != original.id);
        expect(reversal.reversesEntryId, equals(original.id));
        expect(
          reversal.postings.map((p) => p.amountMinor).toSet(),
          equals({-1000, 1000}),
        );
      },
    );
  });

  group('category management', () {
    test(
      'archived category is excluded from watchCategories() by default',
      () async {
        final incomeId = await firstCategoryId(AccountType.income);
        await repository.archiveCategory(incomeId);

        final active = await repository.watchCategories().first;
        expect(active.any((a) => a.id == incomeId), isFalse);

        final all = await repository
            .watchCategories(includeArchived: true)
            .first;
        expect(all.any((a) => a.id == incomeId), isTrue);
      },
    );

    test(
      'addCategory makes the new category available for selection',
      () async {
        await repository.addCategory(
          name: 'Freelance',
          type: AccountType.income,
        );

        final categories = await repository.watchCategories().first;
        expect(
          categories.any(
            (a) => a.name == 'Freelance' && a.type == AccountType.income,
          ),
          isTrue,
        );
      },
    );

    test('addCategory rejects AccountType.asset', () async {
      expect(
        () => repository.addCategory(name: 'Nope', type: AccountType.asset),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('renameCategory updates the name', () async {
      final incomeId = await firstCategoryId(AccountType.income);
      await repository.renameCategory(id: incomeId, newName: 'Freelance');
      final categories = await repository.watchCategories().first;
      expect(categories.firstWhere((a) => a.id == incomeId).name, 'Freelance');
    });
  });

  group('watchSummary', () {
    test(
      'sums income and expense within the date range, reversal nets to zero',
      () async {
        final incomeId = await firstCategoryId(AccountType.income);
        final expenseId = await firstCategoryId(AccountType.expense);

        await repository.recordTransaction(
          amountMinor: 1000,
          direction: TransactionDirection.moneyIn,
          categoryId: incomeId,
          transactionDate: DateTime(2026, 1, 10),
        );
        await repository.recordTransaction(
          amountMinor: 300,
          direction: TransactionDirection.moneyOut,
          categoryId: expenseId,
          transactionDate: DateTime(2026, 1, 12),
        );
        final toReverse = (await repository.watchEntries().first).firstWhere(
          (e) =>
              e.postings.any((p) => p.accountId == incomeId) &&
              e.reversesEntryId == null,
        );
        await repository.reverseEntry(toReverse.id);

        // reverseEntry dates the reversal as of today (when the correction
        // happens, not backdated to the original) - so a range wide enough
        // to cover both the fixed historical dates above and "today" is
        // needed to see the net-zero effect.
        final summary = await repository
            .watchSummary(
              start: DateTime(2020, 1, 1),
              end: DateTime(2030, 12, 31),
            )
            .first;

        expect(summary.totalIncomeMinor, equals(0));
        expect(summary.totalExpenseMinor, equals(300));
      },
    );

    test('excludes entries outside the date range', () async {
      final incomeId = await firstCategoryId(AccountType.income);
      await repository.recordTransaction(
        amountMinor: 1000,
        direction: TransactionDirection.moneyIn,
        categoryId: incomeId,
        transactionDate: DateTime(2026, 2, 1),
      );

      final summary = await repository
          .watchSummary(start: DateTime(2026, 1, 1), end: DateTime(2026, 1, 31))
          .first;

      expect(summary.totalIncomeMinor, equals(0));
    });

    test('excludes a quarantined (unverified) entry from totals', () async {
      final incomeId = await firstCategoryId(AccountType.income);
      await repository.recordTransaction(
        amountMinor: 1000,
        direction: TransactionDirection.moneyIn,
        categoryId: incomeId,
        transactionDate: DateTime(2026, 1, 10),
      );
      final entry = (await repository.watchEntries().first).single;

      // Directly tamper with the stored row, bypassing the Repository -
      // simulating an edit made outside the application.
      await (db.update(
        db.journalEntries,
      )..where((e) => e.id.equals(entry.id))).write(
        JournalEntriesCompanion(description: Value('tampered outside the app')),
      );
      await repository.verifyChain();

      final summary = await repository
          .watchSummary(
            start: DateTime(2020, 1, 1),
            end: DateTime(2030, 12, 31),
          )
          .first;
      expect(summary.totalIncomeMinor, equals(0));
    });
  });

  group('verifyChain', () {
    test('an intact chain reports no break', () async {
      final incomeId = await firstCategoryId(AccountType.income);
      await repository.recordTransaction(
        amountMinor: 1000,
        direction: TransactionDirection.moneyIn,
        categoryId: incomeId,
        transactionDate: DateTime(2026, 1, 15),
      );
      await repository.recordTransaction(
        amountMinor: 500,
        direction: TransactionDirection.moneyIn,
        categoryId: incomeId,
        transactionDate: DateTime(2026, 1, 16),
      );

      final result = await repository.verifyChain();

      expect(result.isFullyVerified, isTrue);
      expect(result.totalEntries, equals(2));
    });

    test(
      'detects a tampered entry and quarantines it plus everything after it',
      () async {
        final incomeId = await firstCategoryId(AccountType.income);
        await repository.recordTransaction(
          amountMinor: 1000,
          direction: TransactionDirection.moneyIn,
          categoryId: incomeId,
          transactionDate: DateTime(2026, 1, 15),
        );
        await repository.recordTransaction(
          amountMinor: 500,
          direction: TransactionDirection.moneyIn,
          categoryId: incomeId,
          transactionDate: DateTime(2026, 1, 16),
        );
        final entries = await repository.watchEntries().first;
        final firstEntry = entries.firstWhere(
          (e) => e.deviceChainSequence == 0,
        );

        // Tamper directly with the stored row - not through the Repository
        // (which has no update path), exactly mimicking direct SQLite file
        // access outside the app.
        await (db.update(
          db.journalEntries,
        )..where((e) => e.id.equals(firstEntry.id))).write(
          JournalEntriesCompanion(
            description: Value('tampered outside the app'),
          ),
        );

        final result = await repository.verifyChain();

        expect(result.isFullyVerified, isFalse);
        expect(result.breakEntryId, equals(firstEntry.id));

        final afterVerification = await repository.watchEntries().first;
        expect(afterVerification.every((e) => !e.isVerified), isTrue);
      },
    );

    test(
      'a new transaction after a break re-anchors and records the event',
      () async {
        final incomeId = await firstCategoryId(AccountType.income);
        await repository.recordTransaction(
          amountMinor: 1000,
          direction: TransactionDirection.moneyIn,
          categoryId: incomeId,
          transactionDate: DateTime(2026, 1, 15),
        );
        final entries = await repository.watchEntries().first;
        final firstEntry = entries.single;
        await (db.update(
          db.journalEntries,
        )..where((e) => e.id.equals(firstEntry.id))).write(
          JournalEntriesCompanion(
            description: Value('tampered outside the app'),
          ),
        );
        await repository.verifyChain();

        await repository.recordTransaction(
          amountMinor: 200,
          direction: TransactionDirection.moneyIn,
          categoryId: incomeId,
          transactionDate: DateTime(2026, 1, 17),
        );

        final newEntry = (await repository.watchEntries().first).firstWhere(
          (e) => e.id != firstEntry.id,
        );
        expect(newEntry.isVerified, isTrue);

        final events = await repository.watchIntegrityEvents().first;
        expect(
          events.any(
            (e) => e.eventType == IntegrityEventType.chainBreakDetected,
          ),
          isTrue,
        );
        expect(
          events.any((e) => e.eventType == IntegrityEventType.chainReanchored),
          isTrue,
        );
      },
    );
  });

  group('migrateToNewIdentityAfterKeyLoss', () {
    test(
      're-signs every active entry under a new identity, preserving content',
      () async {
        final incomeId = await firstCategoryId(AccountType.income);
        await repository.recordTransaction(
          amountMinor: 1000,
          direction: TransactionDirection.moneyIn,
          categoryId: incomeId,
          transactionDate: DateTime(2026, 1, 15),
        );
        final legacy = (await repository.watchEntries().first).single;
        final oldIdentity = (await repository.currentIdentity())!;

        await repository.migrateToNewIdentityAfterKeyLoss();

        final newIdentity = (await repository.currentIdentity())!;
        expect(newIdentity.identityId, isNot(equals(oldIdentity.identityId)));
        expect(
          newIdentity.supersedesIdentityId,
          equals(oldIdentity.identityId),
        );

        final entries = await repository.watchEntries().first;
        expect(entries, hasLength(2));
        final migrated = entries.firstWhere(
          (e) => e.migratedFromEntryId == legacy.id,
        );
        expect(
          migrated.postings.map((p) => p.amountMinor).toSet(),
          equals(legacy.postings.map((p) => p.amountMinor).toSet()),
        );
        expect(migrated.signedByIdentityId, equals(newIdentity.identityId));
        // device_chain_sequence is UNIQUE across the whole table (design.md)
        // and never scoped per identity, so migration continues the counter
        // rather than restarting at 0 - it must differ from the legacy
        // entry's own sequence number, which stays exactly as posted.
        expect(
          migrated.deviceChainSequence,
          isNot(equals(legacy.deviceChainSequence)),
        );
      },
    );

    test(
      'legacy entries are excluded from the post-migration summary',
      () async {
        final incomeId = await firstCategoryId(AccountType.income);
        await repository.recordTransaction(
          amountMinor: 1000,
          direction: TransactionDirection.moneyIn,
          categoryId: incomeId,
          transactionDate: DateTime(2026, 1, 15),
        );

        await repository.migrateToNewIdentityAfterKeyLoss();

        final summary = await repository
            .watchSummary(
              start: DateTime(2020, 1, 1),
              end: DateTime(2030, 12, 31),
            )
            .first;
        // Both the legacy and the migrated entry post +1000/-1000 for
        // income - if the legacy one weren't excluded, this would double
        // count to 2000.
        expect(summary.totalIncomeMinor, equals(1000));
      },
    );
  });
}
