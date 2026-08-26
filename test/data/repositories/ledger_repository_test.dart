import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:smara_accounting/data/database/app_database.dart';
import 'package:smara_accounting/data/database/tables/account_groups_table.dart';
import 'package:smara_accounting/data/database/tables/accounts_table.dart';
import 'package:smara_accounting/data/repositories/account_repository.dart';
import 'package:smara_accounting/data/repositories/category_repository.dart';
import 'package:smara_accounting/data/repositories/investment_holdings_logic.dart';
import 'package:smara_accounting/data/repositories/ledger_repository.dart';
import 'package:smara_accounting/data/repositories/recurring_template_repository.dart';
import 'package:smara_accounting/data/repositories/investment_repository.dart';
import 'package:smara_accounting/data/repositories/identity_repository.dart';
import 'package:smara_accounting/data/repositories/payee_repository.dart';
import 'package:smara_accounting/domain/models/instrument.dart';
import 'package:smara_accounting/domain/crypto/signing_key_service.dart';
import 'package:smara_accounting/domain/exceptions.dart';
import 'package:smara_accounting/domain/models/home_overview.dart';
import 'package:smara_accounting/domain/models/integrity_event.dart';
import 'package:smara_accounting/domain/models/pending_transfer.dart';
import 'package:smara_accounting/domain/models/recurring_template.dart';
import 'package:smara_accounting/domain/models/transaction_direction.dart';
import 'package:test/test.dart';

import '../../domain/crypto/in_memory_secure_key_storage.dart';

void main() {
  late AppDatabase db;
  late SigningKeyService signingKeyService;
  late LedgerRepository repository;
  late AccountRepository accountRepository;
  late CategoryRepository categoryRepository;
  late PayeeRepository payeeRepository;
  late IdentityRepository identityRepository;
  late InvestmentRepository investmentRepository;
  late RecurringTemplateRepository recurringTemplateRepository;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    signingKeyService = SigningKeyService(
      secureStorage: InMemorySecureKeyStorage(),
    );
    repository = LedgerRepository(
      database: db,
      signingKeyService: signingKeyService,
    );
    accountRepository = AccountRepository(
      database: db,
      ledgerRepository: repository,
    );
    categoryRepository = CategoryRepository(database: db);
    payeeRepository = PayeeRepository(database: db);
    identityRepository = IdentityRepository(
      database: db,
      accountRepository: accountRepository,
      signingKeyService: signingKeyService,
    );
    investmentRepository = InvestmentRepository(
      database: db,
      ledgerRepository: repository,
    );
    recurringTemplateRepository = RecurringTemplateRepository(
      database: db,
      ledgerRepository: repository,
    );
    // Every test starts past onboarding - identity lifecycle itself is
    // covered by its own group below, using a fresh Repository/service.
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

  Future<String> firstCategoryId(AccountType type) async {
    final categories = await categoryRepository.watchCategories().first;
    return categories.firstWhere((a) => a.type == type).id;
  }

  // Every starter group lands in USD (setUp's confirmFirstIdentity). These
  // helpers park a second currency on an otherwise-empty starter group
  // (groupPensionRetirementId/groupLoansMortgagesId never get the seeded
  // financial account) so cross-currency scenarios have a real second
  // account to work with.
  Future<String> secondCurrencyAssetAccountId({String currency = 'EUR'}) async {
    await accountRepository.changeAccountGroupCurrency(
      groupId: groupPensionRetirementId,
      currency: currency,
    );
    final account = await accountRepository.createFinancialAccount(
      name: 'Euro Savings',
      type: AccountType.asset,
      groupId: groupPensionRetirementId,
    );
    return account.id;
  }

  Future<String> secondCurrencyLiabilityAccountId({
    String currency = 'EUR',
  }) async {
    await accountRepository.changeAccountGroupCurrency(
      groupId: groupLoansMortgagesId,
      currency: currency,
    );
    final account = await accountRepository.createFinancialAccount(
      name: 'Euro Loan',
      type: AccountType.liability,
      groupId: groupLoansMortgagesId,
    );
    return account.id;
  }

  IdentityRepository identityFor(
    AppDatabase database,
    SigningKeyService keys,
    LedgerRepository ledger,
  ) {
    return IdentityRepository(
      database: database,
      accountRepository: AccountRepository(
        database: database,
        ledgerRepository: ledger,
      ),
      signingKeyService: keys,
    );
  }

  group('starter account seeding', () {
    test(
      'confirmFirstIdentity seeds the single asset account and starter categories',
      () async {
        final categories = await categoryRepository.watchCategories().first;
        expect(
          categories.map((a) => a.name),
          containsAll(starterIncomeCategories + starterExpenseCategories),
        );
        expect(categories.every((a) => a.type != AccountType.asset), isTrue);
      },
    );

    test(
      'no starter accounts exist until confirmFirstIdentity runs - spec: identity must exist first',
      () async {
        final freshDb = AppDatabase.forTesting(NativeDatabase.memory());
        addTearDown(freshDb.close);
        final freshKeys = SigningKeyService(
          secureStorage: InMemorySecureKeyStorage(),
        );
        final freshRepository = LedgerRepository(
          database: freshDb,
          signingKeyService: freshKeys,
        );
        final freshIdentity = identityFor(freshDb, freshKeys, freshRepository);
        final freshCategoryRepository = CategoryRepository(database: freshDb);

        expect(await freshCategoryRepository.watchCategories().first, isEmpty);

        final generated = await freshIdentity.generateFirstIdentity();
        expect(await freshCategoryRepository.watchCategories().first, isEmpty);

        await freshIdentity.confirmFirstIdentity(generated, currency: 'USD');
        final categories = await freshCategoryRepository
            .watchCategories()
            .first;
        expect(
          categories.map((a) => a.name),
          containsAll(starterIncomeCategories + starterExpenseCategories),
        );
      },
    );
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

      // No identity confirmed yet, so no starter accounts exist either
      // (spec: identity must exist before any account or entry does) -
      // categoryId is an arbitrary placeholder; recordTransaction must
      // reject this before it ever gets far enough to resolve it. The
      // account lookup now throws a domain exception (AccountGroupException)
      // rather than letting Drift's raw getSingleOrNull-then-null-check
      // surface as a StateError.
      expect(
        () => freshRepository.recordTransaction(
          amountMinor: 1000,
          direction: TransactionDirection.moneyIn,
          categoryId: 'placeholder-category-id',
          financialAccountId: 'no-account',
          transactionDate: DateTime(2026, 1, 15),
        ),
        throwsA(isA<AccountGroupException>()),
      );
    });

    test('currentIdentity is null until confirmFirstIdentity runs', () async {
      final freshDb = AppDatabase.forTesting(NativeDatabase.memory());
      final freshKeys = SigningKeyService(
        secureStorage: InMemorySecureKeyStorage(),
      );
      final freshRepository = LedgerRepository(
        database: freshDb,
        signingKeyService: freshKeys,
      );
      final freshIdentity = identityFor(freshDb, freshKeys, freshRepository);
      addTearDown(freshDb.close);

      expect(await freshIdentity.currentIdentity(), isNull);

      final generated = await freshIdentity.generateFirstIdentity();
      expect(await freshIdentity.currentIdentity(), isNull);

      final confirmed = await freshIdentity.confirmFirstIdentity(
        generated,
        currency: 'USD',
      );
      expect(
        (await freshIdentity.currentIdentity())!.identityId,
        equals(confirmed.identityId),
      );
    });

    test('hasMatchingStoredKey is true right after confirmation', () async {
      final identity = (await identityRepository.currentIdentity())!;
      expect(await identityRepository.hasMatchingStoredKey(identity), isTrue);
    });

    test(
      'restoreIdentity on a reinstalled device with the recovery phrase matches the original identity',
      () async {
        // Simulate a device that already has a confirmed identity and a
        // database file with history - capture the phrase the way
        // onboarding would have shown it to the user.
        final freshDb = AppDatabase.forTesting(NativeDatabase.memory());
        addTearDown(freshDb.close);
        final firstKeys = SigningKeyService(
          secureStorage: InMemorySecureKeyStorage(),
        );
        final firstInstallRepository = LedgerRepository(
          database: freshDb,
          signingKeyService: firstKeys,
        );
        final firstInstallIdentity = identityFor(
          freshDb,
          firstKeys,
          firstInstallRepository,
        );
        final generated = await firstInstallIdentity.generateFirstIdentity();
        final originalIdentity = await firstInstallIdentity
            .confirmFirstIdentity(generated, currency: 'USD');

        // Reinstall: same database file, fresh secure storage (a new
        // SigningKeyService with empty InMemorySecureKeyStorage), same
        // Repository pointed at the same underlying db.
        final reinstalledKeys = SigningKeyService(
          secureStorage: InMemorySecureKeyStorage(),
        );
        final reinstalledRepository = LedgerRepository(
          database: freshDb,
          signingKeyService: reinstalledKeys,
        );
        final reinstalledIdentity = identityFor(
          freshDb,
          reinstalledKeys,
          reinstalledRepository,
        );

        final restored = await reinstalledIdentity.restoreIdentity(
          recoveryPhraseWords: generated.phrase.words,
        );

        expect(restored.identityId, equals(originalIdentity.identityId));
        expect(
          await reinstalledIdentity.hasMatchingStoredKey(restored),
          isTrue,
        );
      },
    );

    test(
      'restoreIdentity on a reinstalled device with the keystore file matches the original identity',
      () async {
        final freshDb = AppDatabase.forTesting(NativeDatabase.memory());
        addTearDown(freshDb.close);
        final firstKeys = SigningKeyService(
          secureStorage: InMemorySecureKeyStorage(),
        );
        final firstInstallRepository = LedgerRepository(
          database: freshDb,
          signingKeyService: firstKeys,
        );
        final firstInstallIdentity = identityFor(
          freshDb,
          firstKeys,
          firstInstallRepository,
        );
        final generated = await firstInstallIdentity.generateFirstIdentity();
        final originalIdentity = await firstInstallIdentity
            .confirmFirstIdentity(generated, currency: 'USD');
        final keystoreFile = await firstInstallIdentity.exportKeystoreFile(
          passphrase: 'hunter2-hunter2',
        );

        final reinstalledKeys = SigningKeyService(
          secureStorage: InMemorySecureKeyStorage(),
        );
        final reinstalledRepository = LedgerRepository(
          database: freshDb,
          signingKeyService: reinstalledKeys,
        );
        final reinstalledIdentity = identityFor(
          freshDb,
          reinstalledKeys,
          reinstalledRepository,
        );

        final restored = await reinstalledIdentity.restoreIdentity(
          keystoreFileContents: keystoreFile,
          keystorePassphrase: 'hunter2-hunter2',
        );

        expect(restored.identityId, equals(originalIdentity.identityId));
        expect(
          await reinstalledIdentity.hasMatchingStoredKey(restored),
          isTrue,
        );
      },
    );

    test(
      'restoreIdentity throws when the phrase does not belong to this database',
      () async {
        final identity = (await identityRepository.currentIdentity())!;
        final unrelated = await identityRepository.generateFirstIdentity();

        expect(
          () => identityRepository.restoreIdentity(
            recoveryPhraseWords: unrelated.phrase.words,
          ),
          throwsA(isA<SigningIdentityMismatchException>()),
        );
        // Sanity: the original identity is still on record, untouched.
        expect(
          (await identityRepository.currentIdentity())!.identityId,
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
        financialAccountId: await firstFinancialAccountId(),
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
        financialAccountId: await firstFinancialAccountId(),
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
      final financialAccountId = await firstFinancialAccountId();
      expect(
        () => repository.recordTransaction(
          amountMinor: 0,
          direction: TransactionDirection.moneyIn,
          categoryId: incomeId,
          financialAccountId: financialAccountId,
          transactionDate: DateTime(2026, 1, 15),
        ),
        throwsA(isA<InvalidTransactionAmountException>()),
      );
      expect(await repository.watchEntries().first, isEmpty);
    });

    test('rejects a negative amount', () async {
      final incomeId = await firstCategoryId(AccountType.income);
      final financialAccountId = await firstFinancialAccountId();
      expect(
        () => repository.recordTransaction(
          amountMinor: -100,
          direction: TransactionDirection.moneyIn,
          categoryId: incomeId,
          financialAccountId: financialAccountId,
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
        financialAccountId: await firstFinancialAccountId(),
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
          financialAccountId: await firstFinancialAccountId(),
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
        financialAccountId: await firstFinancialAccountId(),
        transactionDate: DateTime(2026, 1, 15),
      );
      await repository.recordTransaction(
        amountMinor: 500,
        direction: TransactionDirection.moneyIn,
        categoryId: incomeId,
        financialAccountId: await firstFinancialAccountId(),
        transactionDate: DateTime(2026, 1, 16),
      );

      final entries = await repository.watchEntries().first;
      final sorted = [
        ...entries,
      ]..sort((a, b) => a.deviceChainSequence.compareTo(b.deviceChainSequence));
      expect(sorted.map((e) => e.deviceChainSequence), equals([0, 1]));
    });
  });

  group('recordSplitTransaction', () {
    Future<List<String>> categoryIds(AccountType type, int count) async {
      final categories = await categoryRepository.watchCategories().first;
      return categories
          .where((c) => c.type == type)
          .take(count)
          .map((c) => c.id)
          .toList();
    }

    test('posts one financial-account leg for the total and one posting per '
        'split line', () async {
      final categories = await categoryIds(AccountType.expense, 2);
      final financialAccountId = await firstFinancialAccountId();

      final entryId = await repository.recordSplitTransaction(
        totalAmountMinor: 10000,
        splitLines: [
          (categoryId: categories[0], amountMinor: 6000),
          (categoryId: categories[1], amountMinor: 4000),
        ],
        direction: TransactionDirection.moneyOut,
        financialAccountId: financialAccountId,
        transactionDate: DateTime(2026, 1, 15),
      );

      final entry = (await repository.watchEntries().first).singleWhere(
        (e) => e.id == entryId,
      );
      expect(entry.postings, hasLength(3));

      final financialPosting = entry.postings.firstWhere(
        (p) => p.accountId == financialAccountId,
      );
      expect(financialPosting.amountMinor, equals(-10000));

      final line1 = entry.postings.firstWhere(
        (p) => p.accountId == categories[0],
      );
      expect(line1.amountMinor, equals(6000));
      final line2 = entry.postings.firstWhere(
        (p) => p.accountId == categories[1],
      );
      expect(line2.amountMinor, equals(4000));

      expect(
        await repository.displayBalanceMinor(financialAccountId),
        equals(-10000),
      );
    });

    test(
      'money in splits credit the income categories, debit the asset',
      () async {
        final categories = await categoryIds(AccountType.income, 2);
        final financialAccountId = await firstFinancialAccountId();

        final entryId = await repository.recordSplitTransaction(
          totalAmountMinor: 5000,
          splitLines: [
            (categoryId: categories[0], amountMinor: 3000),
            (categoryId: categories[1], amountMinor: 2000),
          ],
          direction: TransactionDirection.moneyIn,
          financialAccountId: financialAccountId,
          transactionDate: DateTime(2026, 1, 15),
        );

        final entry = (await repository.watchEntries().first).singleWhere(
          (e) => e.id == entryId,
        );
        final line1 = entry.postings.firstWhere(
          (p) => p.accountId == categories[0],
        );
        expect(line1.amountMinor, equals(-3000));
      },
    );

    test('rejects a single-line split', () async {
      final categories = await categoryIds(AccountType.expense, 1);
      final financialAccountId = await firstFinancialAccountId();
      expect(
        () => repository.recordSplitTransaction(
          totalAmountMinor: 1000,
          splitLines: [(categoryId: categories[0], amountMinor: 1000)],
          direction: TransactionDirection.moneyOut,
          financialAccountId: financialAccountId,
          transactionDate: DateTime(2026, 1, 15),
        ),
        throwsA(isA<InvalidTransactionAmountException>()),
      );
    });

    test('rejects lines that don\'t sum to the total', () async {
      final categories = await categoryIds(AccountType.expense, 2);
      final financialAccountId = await firstFinancialAccountId();
      expect(
        () => repository.recordSplitTransaction(
          totalAmountMinor: 10000,
          splitLines: [
            (categoryId: categories[0], amountMinor: 6000),
            (categoryId: categories[1], amountMinor: 3000),
          ],
          direction: TransactionDirection.moneyOut,
          financialAccountId: financialAccountId,
          transactionDate: DateTime(2026, 1, 15),
        ),
        throwsA(isA<InvalidTransactionAmountException>()),
      );
      expect(await repository.watchEntries().first, isEmpty);
    });

    test('rejects a zero or negative line amount', () async {
      final categories = await categoryIds(AccountType.expense, 2);
      final financialAccountId = await firstFinancialAccountId();
      expect(
        () => repository.recordSplitTransaction(
          totalAmountMinor: 6000,
          splitLines: [
            (categoryId: categories[0], amountMinor: 6000),
            (categoryId: categories[1], amountMinor: 0),
          ],
          direction: TransactionDirection.moneyOut,
          financialAccountId: financialAccountId,
          transactionDate: DateTime(2026, 1, 15),
        ),
        throwsA(isA<InvalidTransactionAmountException>()),
      );
    });

    test(
      'rejects a line whose category is the wrong type for the direction',
      () async {
        final expenseId = (await categoryIds(AccountType.expense, 1)).single;
        final incomeId = (await categoryIds(AccountType.income, 1)).single;
        final financialAccountId = await firstFinancialAccountId();
        expect(
          () => repository.recordSplitTransaction(
            totalAmountMinor: 10000,
            splitLines: [
              (categoryId: expenseId, amountMinor: 6000),
              // Wrong type: an income category on a moneyOut split.
              (categoryId: incomeId, amountMinor: 4000),
            ],
            direction: TransactionDirection.moneyOut,
            financialAccountId: financialAccountId,
            transactionDate: DateTime(2026, 1, 15),
          ),
          throwsA(isA<InvalidTransactionAmountException>()),
        );
        expect(await repository.watchEntries().first, isEmpty);
      },
    );

    test('rejects a line with an archived category', () async {
      final categories = await categoryIds(AccountType.expense, 2);
      final financialAccountId = await firstFinancialAccountId();
      await categoryRepository.archiveCategory(categories[1]);

      expect(
        () => repository.recordSplitTransaction(
          totalAmountMinor: 10000,
          splitLines: [
            (categoryId: categories[0], amountMinor: 6000),
            (categoryId: categories[1], amountMinor: 4000),
          ],
          direction: TransactionDirection.moneyOut,
          financialAccountId: financialAccountId,
          transactionDate: DateTime(2026, 1, 15),
        ),
        throwsA(isA<InvalidTransactionAmountException>()),
      );
      expect(await repository.watchEntries().first, isEmpty);
    });

    test(
      'reversing a split entry reverses every category leg at once '
      '(design.md Decision 4: reverseEntry needs no split-specific change)',
      () async {
        final categories = await categoryIds(AccountType.expense, 2);
        final financialAccountId = await firstFinancialAccountId();
        final entryId = await repository.recordSplitTransaction(
          totalAmountMinor: 10000,
          splitLines: [
            (categoryId: categories[0], amountMinor: 6000),
            (categoryId: categories[1], amountMinor: 4000),
          ],
          direction: TransactionDirection.moneyOut,
          financialAccountId: financialAccountId,
          transactionDate: DateTime(2026, 1, 15),
        );

        await repository.reverseEntry(entryId);

        expect(
          await repository.displayBalanceMinor(financialAccountId),
          equals(0),
        );
        final entries = await repository.watchEntries().first;
        final reversal = entries.singleWhere(
          (e) => e.reversesEntryId == entryId,
        );
        expect(reversal.postings, hasLength(3));
      },
    );

    test(
      'Summary totals each split leg into its own category '
      '(design.md Decision 4: watchSummary needs no split-specific change)',
      () async {
        final categories = await categoryIds(AccountType.expense, 2);
        await repository.recordSplitTransaction(
          totalAmountMinor: 10000,
          splitLines: [
            (categoryId: categories[0], amountMinor: 6000),
            (categoryId: categories[1], amountMinor: 4000),
          ],
          direction: TransactionDirection.moneyOut,
          financialAccountId: await firstFinancialAccountId(),
          transactionDate: DateTime(2026, 1, 15),
        );

        final totals = await categoryRepository
            .watchCategoryTotals(
              start: DateTime(2026, 1, 1),
              end: DateTime(2026, 1, 31),
            )
            .first;
        final total1 = totals.singleWhere((t) => t.categoryId == categories[0]);
        final total2 = totals.singleWhere((t) => t.categoryId == categories[1]);
        expect(total1.totalMinor, equals(6000));
        expect(total2.totalMinor, equals(4000));
      },
    );
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
          financialAccountId: await firstFinancialAccountId(),
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

    test(
      'the reversal is chained and signed using the same mechanism as an ordinary transaction',
      () async {
        final incomeId = await firstCategoryId(AccountType.income);
        await repository.recordTransaction(
          amountMinor: 1000,
          direction: TransactionDirection.moneyIn,
          categoryId: incomeId,
          financialAccountId: await firstFinancialAccountId(),
          transactionDate: DateTime(2026, 1, 15),
        );
        final original = (await repository.watchEntries().first).single;

        await repository.reverseEntry(original.id);

        final entries = await repository.watchEntries().first;
        final reversal = entries.firstWhere((e) => e.id != original.id);

        expect(
          reversal.deviceChainSequence,
          equals(original.deviceChainSequence + 1),
        );
        expect(
          reversal.signedByIdentityId,
          equals(original.signedByIdentityId),
        );
        expect(reversal.signature, isNotEmpty);
        expect(reversal.entryHash, isNotEmpty);
        expect(reversal.isVerified, isTrue);

        final result = await identityRepository.verifyChain();
        expect(result.isFullyVerified, isTrue);
      },
    );

    test('a second reverse of the same original is rejected', () async {
      final incomeId = await firstCategoryId(AccountType.income);
      await repository.recordTransaction(
        amountMinor: 1000,
        direction: TransactionDirection.moneyIn,
        categoryId: incomeId,
        financialAccountId: await firstFinancialAccountId(),
        transactionDate: DateTime(2026, 1, 15),
      );
      final original = (await repository.watchEntries().first).single;

      await repository.reverseEntry(original.id);
      await expectLater(
        repository.reverseEntry(original.id),
        throwsA(isA<AlreadyReversedException>()),
      );

      final entries = await repository.watchEntries().first;
      expect(entries, hasLength(2));
    });

    test(
      'two concurrent reverses of the same original never both succeed',
      () async {
        final incomeId = await firstCategoryId(AccountType.income);
        await repository.recordTransaction(
          amountMinor: 1000,
          direction: TransactionDirection.moneyIn,
          categoryId: incomeId,
          financialAccountId: await firstFinancialAccountId(),
          transactionDate: DateTime(2026, 1, 15),
        );
        final original = (await repository.watchEntries().first).single;

        Future<Object?> attempt() async {
          try {
            await repository.reverseEntry(original.id);
            return null;
          } catch (e) {
            return e;
          }
        }

        final results = await Future.wait([attempt(), attempt()]);

        final failures = results.whereType<AlreadyReversedException>();
        expect(
          failures,
          hasLength(1),
          reason:
              'exactly one of the two concurrent calls must be rejected as '
              'already-reversed - the guard check and the insert must be '
              'atomic so overlapping callers cannot both pass the check '
              'before either has posted its reversal',
        );

        final entries = await repository.watchEntries().first;
        expect(entries, hasLength(2));
      },
    );

    test(
      'fixPostedTransaction posts a reversal and a replacement together',
      () async {
        final accountId = await firstFinancialAccountId();
        final incomeId = await firstCategoryId(AccountType.income);
        final expenseId = await firstCategoryId(AccountType.expense);
        await repository.recordTransaction(
          amountMinor: 1000,
          direction: TransactionDirection.moneyIn,
          categoryId: incomeId,
          financialAccountId: accountId,
          transactionDate: DateTime(2026, 1, 15),
        );
        final original = (await repository.watchEntries().first).single;

        final replacementId = await repository.fixPostedTransaction(
          entryId: original.id,
          amountMinor: 2500,
          direction: TransactionDirection.moneyOut,
          categoryId: expenseId,
          financialAccountId: accountId,
          transactionDate: DateTime(2026, 1, 16),
          description: 'Corrected',
        );

        final entries = await repository.watchEntries().first;
        expect(entries, hasLength(3));
        expect(
          entries.where((e) => e.reversesEntryId == original.id),
          hasLength(1),
        );
        final replacement = entries.firstWhere((e) => e.id == replacementId);
        expect(replacement.description, equals('Corrected'));
        expect(replacement.reversesEntryId, isNull);

        await expectLater(
          repository.fixPostedTransaction(
            entryId: original.id,
            amountMinor: 100,
            direction: TransactionDirection.moneyOut,
            categoryId: expenseId,
            financialAccountId: accountId,
            transactionDate: DateTime(2026, 1, 17),
          ),
          throwsA(isA<AlreadyReversedException>()),
        );
        expect((await repository.watchEntries().first), hasLength(3));
      },
    );
  });

  group('category management', () {
    test(
      'archived category is excluded from watchCategories() by default',
      () async {
        final incomeId = await firstCategoryId(AccountType.income);
        await categoryRepository.archiveCategory(incomeId);

        final active = await categoryRepository.watchCategories().first;
        expect(active.any((a) => a.id == incomeId), isFalse);

        final all = await categoryRepository
            .watchCategories(includeArchived: true)
            .first;
        expect(all.any((a) => a.id == incomeId), isTrue);
      },
    );

    test(
      'addCategory makes the new category available for selection',
      () async {
        await categoryRepository.addCategory(
          name: 'Freelance',
          type: AccountType.income,
        );

        final categories = await categoryRepository.watchCategories().first;
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
        () => categoryRepository.addCategory(
          name: 'Nope',
          type: AccountType.asset,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('renameCategory updates the name', () async {
      final incomeId = await firstCategoryId(AccountType.income);
      await categoryRepository.renameCategory(
        id: incomeId,
        newName: 'Freelance',
      );
      final categories = await categoryRepository.watchCategories().first;
      expect(categories.firstWhere((a) => a.id == incomeId).name, 'Freelance');
    });

    group('setCategoryMonthlyLimit', () {
      test('sets and then clears a limit on an Expense category', () async {
        final expenseId = await firstCategoryId(AccountType.expense);

        await categoryRepository.setCategoryMonthlyLimit(
          id: expenseId,
          monthlyLimitMinor: 15000,
        );
        var category = (await categoryRepository.watchCategories().first)
            .firstWhere((a) => a.id == expenseId);
        expect(category.monthlyLimitMinor, equals(15000));

        await categoryRepository.setCategoryMonthlyLimit(
          id: expenseId,
          monthlyLimitMinor: null,
        );
        category = (await categoryRepository.watchCategories().first)
            .firstWhere((a) => a.id == expenseId);
        expect(category.monthlyLimitMinor, isNull);
      });

      test('rejects setting a limit on an Income category', () async {
        final incomeId = await firstCategoryId(AccountType.income);
        expect(
          () => categoryRepository.setCategoryMonthlyLimit(
            id: incomeId,
            monthlyLimitMinor: 15000,
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('rejects a non-positive limit', () async {
        final expenseId = await firstCategoryId(AccountType.expense);
        expect(
          () => categoryRepository.setCategoryMonthlyLimit(
            id: expenseId,
            monthlyLimitMinor: 0,
          ),
          throwsA(isA<InvalidTransactionAmountException>()),
        );
      });
    });
  });

  group('financial account management', () {
    test('creates an asset account in a matching group', () async {
      final account = await accountRepository.createFinancialAccount(
        name: 'Savings',
        type: AccountType.asset,
        groupId: groupCashEquivalentsId,
      );

      final accounts = await accountRepository.watchFinancialAccounts().first;
      expect(
        accounts.any((a) => a.id == account.id && a.name == 'Savings'),
        isTrue,
      );
    });

    test('creates a liability account in a matching group', () async {
      final account = await accountRepository.createFinancialAccount(
        name: 'Credit Card',
        type: AccountType.liability,
        groupId: groupCreditShortTermId,
      );

      expect(account.type, equals(AccountType.liability));
    });

    test('creates a credit-card-flagged liability account', () async {
      final account = await accountRepository.createFinancialAccount(
        name: 'Visa',
        type: AccountType.liability,
        groupId: groupCreditShortTermId,
        isCreditCard: true,
      );

      expect(account.isCreditCard, isTrue);
      final accounts = await accountRepository.watchFinancialAccounts().first;
      expect(
        accounts.firstWhere((a) => a.id == account.id).isCreditCard,
        isTrue,
      );
    });

    test('a liability account defaults to not a credit card', () async {
      final account = await accountRepository.createFinancialAccount(
        name: 'Mortgage',
        type: AccountType.liability,
        groupId: groupCreditShortTermId,
      );

      expect(account.isCreditCard, isFalse);
    });

    test('rejects isCreditCard on an asset account', () async {
      expect(
        () => accountRepository.createFinancialAccount(
          name: 'Checking',
          type: AccountType.asset,
          groupId: groupCashEquivalentsId,
          isCreditCard: true,
        ),
        throwsA(isA<AccountGroupException>()),
      );
    });

    test(
      'the credit-card flag is immutable - renaming never changes it',
      () async {
        final account = await accountRepository.createFinancialAccount(
          name: 'Visa',
          type: AccountType.liability,
          groupId: groupCreditShortTermId,
          isCreditCard: true,
        );

        await accountRepository.renameFinancialAccount(
          id: account.id,
          newName: 'Visa Platinum',
        );

        final accounts = await accountRepository.watchFinancialAccounts().first;
        final renamed = accounts.firstWhere((a) => a.id == account.id);
        expect(renamed.name, equals('Visa Platinum'));
        expect(renamed.isCreditCard, isTrue);
      },
    );

    test('rejects a group-kind mismatch on create', () async {
      expect(
        () => accountRepository.createFinancialAccount(
          name: 'Bad',
          type: AccountType.asset,
          groupId: groupCreditShortTermId,
        ),
        throwsA(isA<AccountGroupException>()),
      );
    });

    test('rejects an unknown group on create', () async {
      expect(
        () => accountRepository.createFinancialAccount(
          name: 'Bad',
          type: AccountType.asset,
          groupId: 'no-such-group',
        ),
        throwsA(isA<AccountGroupException>()),
      );
    });

    test(
      'watchCategories never returns liability, asset, or equity rows',
      () async {
        await accountRepository.createFinancialAccount(
          name: 'Credit Card',
          type: AccountType.liability,
          groupId: groupCreditShortTermId,
        );

        final categories = await categoryRepository
            .watchCategories(includeArchived: true)
            .first;
        expect(
          categories.every(
            (a) =>
                a.type == AccountType.income || a.type == AccountType.expense,
          ),
          isTrue,
        );
      },
    );

    test(
      'archiveFinancialAccount hides the account from the picker but keeps history',
      () async {
        final second = await accountRepository.createFinancialAccount(
          name: 'Savings',
          type: AccountType.asset,
          groupId: groupCashEquivalentsId,
        );

        await accountRepository.archiveFinancialAccount(second.id);

        final active = await accountRepository.watchFinancialAccounts().first;
        expect(active.any((a) => a.id == second.id), isFalse);

        final all = await accountRepository
            .watchFinancialAccounts(includeArchived: true)
            .first;
        expect(all.any((a) => a.id == second.id), isTrue);
      },
    );

    test('rejects archiving the last active financial account', () async {
      final onlyAccountId = await firstFinancialAccountId();

      expect(
        () => accountRepository.archiveFinancialAccount(onlyAccountId),
        throwsA(isA<LastActiveAccountException>()),
      );
    });

    test(
      'reassignFinancialAccountGroup moves the account to another matching-kind group',
      () async {
        final accountId = await firstFinancialAccountId();

        await accountRepository.reassignFinancialAccountGroup(
          id: accountId,
          groupId: groupPensionRetirementId,
        );

        final accounts = await accountRepository.watchFinancialAccounts().first;
        expect(
          accounts.firstWhere((a) => a.id == accountId).groupId,
          equals(groupPensionRetirementId),
        );
      },
    );

    test('rejects a group-kind mismatch on reassignment', () async {
      final accountId = await firstFinancialAccountId();

      expect(
        () => accountRepository.reassignFinancialAccountGroup(
          id: accountId,
          groupId: groupCreditShortTermId,
        ),
        throwsA(isA<AccountGroupException>()),
      );
    });
  });

  group('recordTransfer', () {
    test(
      'moves value between two accounts without affecting income/expense totals',
      () async {
        final source = await firstFinancialAccountId();
        final destination = await accountRepository.createFinancialAccount(
          name: 'Savings',
          type: AccountType.asset,
          groupId: groupCashEquivalentsId,
        );

        await repository.recordTransfer(
          fromAccountId: source,
          toAccountId: destination.id,
          amountMinor: 5000,
          transactionDate: DateTime(2026, 1, 15),
        );

        expect(await repository.displayBalanceMinor(source), equals(-5000));
        expect(
          await repository.displayBalanceMinor(destination.id),
          equals(5000),
        );

        final summary = await repository
            .watchSummary(
              start: DateTime(2020, 1, 1),
              end: DateTime(2030, 12, 31),
            )
            .first;
        expect(summary.totalIncomeMinor, equals(0));
        expect(summary.totalExpenseMinor, equals(0));
      },
    );

    test(
      'a payment from an asset account reduces a liability balance owed',
      () async {
        final checking = await firstFinancialAccountId();
        final card = await accountRepository.createFinancialAccount(
          name: 'Credit Card',
          type: AccountType.liability,
          groupId: groupCreditShortTermId,
          openingBalanceMinor: 10000,
        );
        expect(await repository.displayBalanceMinor(card.id), equals(10000));

        await repository.recordTransfer(
          fromAccountId: checking,
          toAccountId: card.id,
          amountMinor: 4000,
          transactionDate: DateTime(2026, 1, 15),
        );

        expect(await repository.displayBalanceMinor(card.id), equals(6000));
      },
    );

    test('rejects a transfer to the same account', () async {
      final accountId = await firstFinancialAccountId();
      expect(
        () => repository.recordTransfer(
          fromAccountId: accountId,
          toAccountId: accountId,
          amountMinor: 100,
          transactionDate: DateTime(2026, 1, 15),
        ),
        throwsA(isA<InvalidTransferException>()),
      );
    });

    test('rejects a non-positive transfer amount', () async {
      final source = await firstFinancialAccountId();
      final destination = await accountRepository.createFinancialAccount(
        name: 'Savings',
        type: AccountType.asset,
        groupId: groupCashEquivalentsId,
      );

      expect(
        () => repository.recordTransfer(
          fromAccountId: source,
          toAccountId: destination.id,
          amountMinor: 0,
          transactionDate: DateTime(2026, 1, 15),
        ),
        throwsA(isA<InvalidTransferException>()),
      );
    });

    test(
      'a reversed transfer restores both accounts to their prior balance',
      () async {
        final source = await firstFinancialAccountId();
        final destination = await accountRepository.createFinancialAccount(
          name: 'Savings',
          type: AccountType.asset,
          groupId: groupCashEquivalentsId,
        );
        await repository.recordTransfer(
          fromAccountId: source,
          toAccountId: destination.id,
          amountMinor: 3000,
          transactionDate: DateTime(2026, 1, 15),
        );
        final entry = (await repository.watchEntries().first).single;

        await repository.reverseEntry(entry.id);

        expect(await repository.displayBalanceMinor(source), equals(0));
        expect(await repository.displayBalanceMinor(destination.id), equals(0));
      },
    );
  });

  group('opening balance', () {
    test(
      'sets an asset account balance without affecting income/expense totals',
      () async {
        final account = await accountRepository.createFinancialAccount(
          name: 'Savings',
          type: AccountType.asset,
          groupId: groupCashEquivalentsId,
          openingBalanceMinor: 25000,
        );

        expect(await repository.displayBalanceMinor(account.id), equals(25000));

        final summary = await repository
            .watchSummary(
              start: DateTime(2000, 1, 1),
              end: DateTime(2030, 12, 31),
            )
            .first;
        expect(summary.totalIncomeMinor, equals(0));
      },
    );

    test('sets a liability account amount owed', () async {
      final account = await accountRepository.createFinancialAccount(
        name: 'Credit Card',
        type: AccountType.liability,
        groupId: groupCreditShortTermId,
        openingBalanceMinor: 15000,
      );

      expect(await repository.displayBalanceMinor(account.id), equals(15000));
    });

    test('rejects a zero or negative opening balance', () async {
      expect(
        () => accountRepository.createFinancialAccount(
          name: 'Savings',
          type: AccountType.asset,
          groupId: groupCashEquivalentsId,
          openingBalanceMinor: 0,
        ),
        throwsA(isA<InvalidOpeningBalanceException>()),
      );
      expect(
        () => accountRepository.createFinancialAccount(
          name: 'Savings',
          type: AccountType.asset,
          groupId: groupCashEquivalentsId,
          openingBalanceMinor: -100,
        ),
        throwsA(isA<InvalidOpeningBalanceException>()),
      );
    });

    test(
      'the equity offset account never appears in the financial-account picker',
      () async {
        await accountRepository.createFinancialAccount(
          name: 'Savings',
          type: AccountType.asset,
          groupId: groupCashEquivalentsId,
          openingBalanceMinor: 1000,
        );

        final accounts = await accountRepository
            .watchFinancialAccounts(includeArchived: true)
            .first;
        expect(
          accounts.any((a) => a.id == openingBalanceEquityAccountId),
          isFalse,
        );
      },
    );
  });

  group('watchHomeOverview', () {
    test('computes group totals and overall net position', () async {
      final checkingId = await firstFinancialAccountId();
      final incomeId = await firstCategoryId(AccountType.income);
      await repository.recordTransaction(
        amountMinor: 100000,
        direction: TransactionDirection.moneyIn,
        categoryId: incomeId,
        financialAccountId: checkingId,
        transactionDate: DateTime(2026, 1, 15),
      );
      final card = await accountRepository.createFinancialAccount(
        name: 'Credit Card',
        type: AccountType.liability,
        groupId: groupCreditShortTermId,
        openingBalanceMinor: 20000,
      );

      final overview = await repository.watchHomeOverview().first;

      final usdPosition = overview.netPositionsByCurrency.single;
      expect(usdPosition.currency, equals('USD'));
      expect(usdPosition.totalAssetsMinor, equals(100000));
      expect(usdPosition.totalLiabilitiesMinor, equals(20000));
      expect(usdPosition.netPositionMinor, equals(80000));

      final cashSection = overview.sections.firstWhere(
        (s) => s.group.id == groupCashEquivalentsId,
      );
      expect(cashSection.totalDisplayBalanceMinor, equals(100000));
      final creditSection = overview.sections.firstWhere(
        (s) => s.group.id == groupCreditShortTermId,
      );
      expect(
        creditSection.accounts.any(
          (a) => a.account.id == card.id && a.displayBalanceMinor == 20000,
        ),
        isTrue,
      );
    });

    test(
      'an archived account still contributes to its group total and net position',
      () async {
        final second = await accountRepository.createFinancialAccount(
          name: 'Savings',
          type: AccountType.asset,
          groupId: groupCashEquivalentsId,
          openingBalanceMinor: 5000,
        );
        await accountRepository.archiveFinancialAccount(second.id);

        final overview = await repository.watchHomeOverview().first;
        expect(
          overview.netPositionsByCurrency.single.totalAssetsMinor,
          equals(5000),
        );
      },
    );

    test('a group with no member accounts is omitted from sections', () async {
      final overview = await repository.watchHomeOverview().first;
      expect(
        overview.sections.any((s) => s.group.id == groupLoansMortgagesId),
        isFalse,
      );
    });

    test(
      'a quarantined entry is excluded from balance, group totals, and net position',
      () async {
        final checkingId = await firstFinancialAccountId();
        final incomeId = await firstCategoryId(AccountType.income);
        await repository.recordTransaction(
          amountMinor: 100000,
          direction: TransactionDirection.moneyIn,
          categoryId: incomeId,
          financialAccountId: checkingId,
          transactionDate: DateTime(2026, 1, 15),
        );
        final entry = (await repository.watchEntries().first).single;

        // Tamper directly with the stored row - not through the
        // Repository - exactly mimicking direct SQLite file access
        // outside the app, then let verifyChain quarantine it.
        await (db.update(
          db.journalEntries,
        )..where((e) => e.id.equals(entry.id))).write(
          JournalEntriesCompanion(
            description: Value('tampered outside the app'),
          ),
        );
        await identityRepository.verifyChain();

        expect(await repository.displayBalanceMinor(checkingId), equals(0));
        final overview = await repository.watchHomeOverview().first;
        expect(
          overview.netPositionsByCurrency.single.totalAssetsMinor,
          equals(0),
        );

        // Still visible in the register for review, never hidden.
        final entries = await repository
            .watchEntriesForAccount(checkingId)
            .first;
        expect(entries.any((e) => e.id == entry.id), isTrue);
      },
    );
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
          financialAccountId: await firstFinancialAccountId(),
          transactionDate: DateTime(2026, 1, 10),
        );
        await repository.recordTransaction(
          amountMinor: 300,
          direction: TransactionDirection.moneyOut,
          categoryId: expenseId,
          financialAccountId: await firstFinancialAccountId(),
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
        financialAccountId: await firstFinancialAccountId(),
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
        financialAccountId: await firstFinancialAccountId(),
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
      await identityRepository.verifyChain();

      final summary = await repository
          .watchSummary(
            start: DateTime(2020, 1, 1),
            end: DateTime(2030, 12, 31),
          )
          .first;
      expect(summary.totalIncomeMinor, equals(0));
    });
  });

  group('watchCategoryTotals', () {
    Future<String> categoryIdNamed(String name) async {
      final categories = await categoryRepository.watchCategories().first;
      return categories.firstWhere((a) => a.name == name).id;
    }

    test('groups by category (not collapsed into one total per direction), '
        'excludes a category with no activity in range', () async {
      final groceriesId = await categoryIdNamed('Groceries');
      final rentId = await categoryIdNamed('Rent/Mortgage');
      final salaryId = await categoryIdNamed('Salary');
      final accountId = await firstFinancialAccountId();

      await repository.recordTransaction(
        amountMinor: 5000,
        direction: TransactionDirection.moneyOut,
        categoryId: groceriesId,
        financialAccountId: accountId,
        transactionDate: DateTime(2026, 1, 5),
      );
      await repository.recordTransaction(
        amountMinor: 3000,
        direction: TransactionDirection.moneyOut,
        categoryId: groceriesId,
        financialAccountId: accountId,
        transactionDate: DateTime(2026, 1, 15),
      );
      await repository.recordTransaction(
        amountMinor: 150000,
        direction: TransactionDirection.moneyOut,
        categoryId: rentId,
        financialAccountId: accountId,
        transactionDate: DateTime(2026, 1, 1),
      );
      await repository.recordTransaction(
        amountMinor: 300000,
        direction: TransactionDirection.moneyIn,
        categoryId: salaryId,
        financialAccountId: accountId,
        transactionDate: DateTime(2026, 1, 1),
      );

      final totals = await categoryRepository
          .watchCategoryTotals(
            start: DateTime(2026, 1, 1),
            end: DateTime(2026, 1, 31),
          )
          .first;

      final byName = {for (final t in totals) t.categoryName: t};
      expect(byName['Groceries']!.totalMinor, equals(8000));
      expect(byName['Groceries']!.isIncome, isFalse);
      expect(byName['Rent/Mortgage']!.totalMinor, equals(150000));
      expect(byName['Salary']!.totalMinor, equals(300000));
      expect(byName['Salary']!.isIncome, isTrue);
      // Utilities had no activity in range - absent, not zero.
      expect(byName.containsKey('Utilities'), isFalse);
    });

    test('excludes entries outside the date range', () async {
      final groceriesId = await categoryIdNamed('Groceries');
      await repository.recordTransaction(
        amountMinor: 5000,
        direction: TransactionDirection.moneyOut,
        categoryId: groceriesId,
        financialAccountId: await firstFinancialAccountId(),
        transactionDate: DateTime(2026, 2, 1),
      );

      final totals = await categoryRepository
          .watchCategoryTotals(
            start: DateTime(2026, 1, 1),
            end: DateTime(2026, 1, 31),
          )
          .first;

      expect(totals, isEmpty);
    });

    test('excludes a quarantined (unverified) entry', () async {
      final groceriesId = await categoryIdNamed('Groceries');
      await repository.recordTransaction(
        amountMinor: 5000,
        direction: TransactionDirection.moneyOut,
        categoryId: groceriesId,
        financialAccountId: await firstFinancialAccountId(),
        transactionDate: DateTime(2026, 1, 10),
      );
      final entry = (await repository.watchEntries().first).single;
      await (db.update(
        db.journalEntries,
      )..where((e) => e.id.equals(entry.id))).write(
        JournalEntriesCompanion(description: Value('tampered outside the app')),
      );
      await identityRepository.verifyChain();

      final totals = await categoryRepository
          .watchCategoryTotals(
            start: DateTime(2026, 1, 1),
            end: DateTime(2026, 1, 31),
          )
          .first;

      expect(totals, isEmpty);
    });
  });

  group('verifyChain', () {
    test('an intact chain reports no break', () async {
      final incomeId = await firstCategoryId(AccountType.income);
      await repository.recordTransaction(
        amountMinor: 1000,
        direction: TransactionDirection.moneyIn,
        categoryId: incomeId,
        financialAccountId: await firstFinancialAccountId(),
        transactionDate: DateTime(2026, 1, 15),
      );
      await repository.recordTransaction(
        amountMinor: 500,
        direction: TransactionDirection.moneyIn,
        categoryId: incomeId,
        financialAccountId: await firstFinancialAccountId(),
        transactionDate: DateTime(2026, 1, 16),
      );

      final result = await identityRepository.verifyChain();

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
          financialAccountId: await firstFinancialAccountId(),
          transactionDate: DateTime(2026, 1, 15),
        );
        await repository.recordTransaction(
          amountMinor: 500,
          direction: TransactionDirection.moneyIn,
          categoryId: incomeId,
          financialAccountId: await firstFinancialAccountId(),
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

        final result = await identityRepository.verifyChain();

        expect(result.isFullyVerified, isFalse);
        expect(result.breakEntryId, equals(firstEntry.id));

        final afterVerification = await repository.watchEntries().first;
        expect(afterVerification.every((e) => !e.isVerified), isTrue);
      },
    );

    test(
      'tampering a later entry does not affect any entry before it',
      () async {
        final incomeId = await firstCategoryId(AccountType.income);
        for (var i = 0; i < 3; i++) {
          await repository.recordTransaction(
            amountMinor: 1000,
            direction: TransactionDirection.moneyIn,
            categoryId: incomeId,
            financialAccountId: await firstFinancialAccountId(),
            transactionDate: DateTime(2026, 1, 15 + i),
          );
        }
        final entries = await repository.watchEntries().first;
        final middleEntry = entries.firstWhere(
          (e) => e.deviceChainSequence == 1,
        );
        final firstEntry = entries.firstWhere(
          (e) => e.deviceChainSequence == 0,
        );

        await (db.update(
          db.journalEntries,
        )..where((e) => e.id.equals(middleEntry.id))).write(
          JournalEntriesCompanion(
            description: Value('tampered outside the app'),
          ),
        );

        final result = await identityRepository.verifyChain();
        expect(result.breakEntryId, equals(middleEntry.id));

        final afterVerification = await repository.watchEntries().first;
        expect(
          afterVerification.firstWhere((e) => e.id == firstEntry.id).isVerified,
          isTrue,
        );
        expect(
          afterVerification
              .firstWhere((e) => e.id == middleEntry.id)
              .isVerified,
          isFalse,
        );
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
          financialAccountId: await firstFinancialAccountId(),
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
        await identityRepository.verifyChain();

        await repository.recordTransaction(
          amountMinor: 200,
          direction: TransactionDirection.moneyIn,
          categoryId: incomeId,
          financialAccountId: await firstFinancialAccountId(),
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
          financialAccountId: await firstFinancialAccountId(),
          transactionDate: DateTime(2026, 1, 15),
        );
        final legacy = (await repository.watchEntries().first).single;
        final oldIdentity = (await identityRepository.currentIdentity())!;

        await identityRepository.migrateToNewIdentityAfterKeyLoss();

        final newIdentity = (await identityRepository.currentIdentity())!;
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
          financialAccountId: await firstFinancialAccountId(),
          transactionDate: DateTime(2026, 1, 15),
        );

        await identityRepository.migrateToNewIdentityAfterKeyLoss();

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

    test(
      'a startup verifyChain after migration does not flag the migrated entry as a chain break',
      () async {
        // Regression test: the migrated entry's previous_entry_hash is a
        // fresh genesis (a new identity cannot chain onto the
        // unrecoverable old identity's hash), while device_chain_sequence
        // keeps incrementing across the boundary. verifyChain() must
        // recognize a migratedFromEntryId-marked entry as a legitimate new
        // chain root, not a broken link - this exact scenario is what the
        // real app runs into via app_router.dart's redirect immediately
        // after a migration completes.
        final incomeId = await firstCategoryId(AccountType.income);
        await repository.recordTransaction(
          amountMinor: 1000,
          direction: TransactionDirection.moneyIn,
          categoryId: incomeId,
          financialAccountId: await firstFinancialAccountId(),
          transactionDate: DateTime(2026, 1, 15),
        );

        await identityRepository.migrateToNewIdentityAfterKeyLoss();
        final result = await identityRepository.verifyChain();

        expect(result.isFullyVerified, isTrue);

        final entries = await repository.watchEntries().first;
        final migrated = entries.firstWhere(
          (e) => e.migratedFromEntryId != null,
        );
        expect(migrated.isVerified, isTrue);

        final summary = await repository
            .watchSummary(
              start: DateTime(2020, 1, 1),
              end: DateTime(2030, 12, 31),
            )
            .first;
        expect(summary.totalIncomeMinor, equals(1000));
      },
    );
  });

  group('currency requirements', () {
    test(
      'every starter group has a currency; an account\'s display currency comes from its group',
      () async {
        final groups = await accountRepository.watchAccountGroups().first;
        expect(groups, isNotEmpty);
        expect(groups.every((g) => g.currency == 'USD'), isTrue);
      },
    );

    test(
      'creating a financial account in a group with no currency is rejected',
      () async {
        // Simulate the transient post-upgrade-from-v3 state directly - no
        // app-level path can normally reach this, since needsCurrencyBackfill
        // gates every screen first, but the Repository defends anyway.
        await (db.update(db.accountGroups)
              ..where((g) => g.id.equals(groupPensionRetirementId)))
            .write(const AccountGroupsCompanion(currency: Value(null)));

        expect(
          () => accountRepository.createFinancialAccount(
            name: 'Savings',
            type: AccountType.asset,
            groupId: groupPensionRetirementId,
          ),
          throwsA(isA<AccountGroupException>()),
        );
      },
    );
  });

  group('group currency changes', () {
    test('rejected while the group has an active financial account', () {
      expect(
        () => accountRepository.changeAccountGroupCurrency(
          groupId: groupCashEquivalentsId,
          currency: 'EUR',
        ),
        throwsA(isA<AccountGroupException>()),
      );
    });

    test('allowed when the group has zero active accounts', () async {
      await accountRepository.changeAccountGroupCurrency(
        groupId: groupPensionRetirementId,
        currency: 'EUR',
      );
      final groups = await accountRepository.watchAccountGroups().first;
      expect(
        groups.firstWhere((g) => g.id == groupPensionRetirementId).currency,
        equals('EUR'),
      );
    });
  });

  group('createAccountGroup', () {
    test('creates a non-system group with the next sortOrder', () async {
      final created = await accountRepository.createAccountGroup(
        name: 'Business',
        kind: AccountGroupKind.assetGroup,
        currency: 'GBP',
      );

      expect(created.name, equals('Business'));
      expect(created.kind, equals(AccountGroupKind.assetGroup));
      expect(created.currency, equals('GBP'));
      expect(created.isSystem, isFalse);
      expect(created.archived, isFalse);
      // The five seeded system groups occupy sortOrder 0-4.
      expect(created.sortOrder, equals(5));

      final groups = await accountRepository.watchAccountGroups().first;
      expect(groups.map((g) => g.id), contains(created.id));
    });

    test('rejects a blank currency', () {
      expect(
        () => accountRepository.createAccountGroup(
          name: 'Business',
          kind: AccountGroupKind.assetGroup,
          currency: '   ',
        ),
        throwsA(isA<AccountGroupException>()),
      );
    });
  });

  group('archiveAccountGroup', () {
    test('rejected for a system group regardless of member accounts', () {
      expect(
        () => accountRepository.archiveAccountGroup(groupPensionRetirementId),
        throwsA(isA<AccountGroupException>()),
      );
    });

    test(
      'rejected for a user-created group with an active member account',
      () async {
        final group = await accountRepository.createAccountGroup(
          name: 'Business',
          kind: AccountGroupKind.assetGroup,
          currency: 'USD',
        );
        await accountRepository.createFinancialAccount(
          name: 'Business Checking',
          type: AccountType.asset,
          groupId: group.id,
        );

        expect(
          () => accountRepository.archiveAccountGroup(group.id),
          throwsA(isA<AccountGroupException>()),
        );
      },
    );

    test(
      'succeeds for an empty user-created group and sets archived',
      () async {
        final group = await accountRepository.createAccountGroup(
          name: 'Business',
          kind: AccountGroupKind.assetGroup,
          currency: 'USD',
        );

        await accountRepository.archiveAccountGroup(group.id);

        final groups = await accountRepository
            .watchAccountGroups(includeArchived: true)
            .first;
        expect(groups.firstWhere((g) => g.id == group.id).archived, isTrue);
      },
    );

    test('rejected for a group that is already archived', () async {
      final group = await accountRepository.createAccountGroup(
        name: 'Business',
        kind: AccountGroupKind.assetGroup,
        currency: 'USD',
      );
      await accountRepository.archiveAccountGroup(group.id);

      expect(
        () => accountRepository.archiveAccountGroup(group.id),
        throwsA(isA<AccountGroupException>()),
      );
    });

    test(
      'a group with only an archived member account can be archived',
      () async {
        final group = await accountRepository.createAccountGroup(
          name: 'Business',
          kind: AccountGroupKind.assetGroup,
          currency: 'USD',
        );
        // A financial account requires at least one other active account
        // to remain to be archivable - use the seeded Cash & cash
        // equivalents account as that "other" account.
        final account = await accountRepository.createFinancialAccount(
          name: 'Business Checking',
          type: AccountType.asset,
          groupId: group.id,
        );
        await accountRepository.archiveFinancialAccount(account.id);

        await accountRepository.archiveAccountGroup(group.id);

        final groups = await accountRepository
            .watchAccountGroups(includeArchived: true)
            .first;
        expect(groups.firstWhere((g) => g.id == group.id).archived, isTrue);
      },
    );
  });

  group('unarchive-accounts-categories', () {
    test('unarchiveFinancialAccount clears archivedAt', () async {
      final group = await accountRepository.createAccountGroup(
        name: 'Business',
        kind: AccountGroupKind.assetGroup,
        currency: 'USD',
      );
      final account = await accountRepository.createFinancialAccount(
        name: 'Business Checking',
        type: AccountType.asset,
        groupId: group.id,
      );
      await accountRepository.archiveFinancialAccount(account.id);

      await accountRepository.unarchiveFinancialAccount(account.id);

      final accounts = await accountRepository
          .watchFinancialAccounts(includeArchived: true)
          .first;
      expect(accounts.firstWhere((a) => a.id == account.id).archived, isFalse);
    });

    test('unarchiving an account whose group is itself archived unarchives '
        'both, in the same action', () async {
      final group = await accountRepository.createAccountGroup(
        name: 'Business',
        kind: AccountGroupKind.assetGroup,
        currency: 'USD',
      );
      // A financial account requires at least one other active account
      // to remain to be archivable - the seeded Cash & cash equivalents
      // account is that "other" account throughout this test.
      final account = await accountRepository.createFinancialAccount(
        name: 'Business Checking',
        type: AccountType.asset,
        groupId: group.id,
      );
      await accountRepository.archiveFinancialAccount(account.id);
      // Now that the group has zero active members, it too can be
      // archived - the only way a group ever reaches this state
      // (design.md Context).
      await accountRepository.archiveAccountGroup(group.id);

      await accountRepository.unarchiveFinancialAccount(account.id);

      final accounts = await accountRepository
          .watchFinancialAccounts(includeArchived: true)
          .first;
      expect(accounts.firstWhere((a) => a.id == account.id).archived, isFalse);
      final groups = await accountRepository
          .watchAccountGroups(includeArchived: true)
          .first;
      expect(groups.firstWhere((g) => g.id == group.id).archived, isFalse);
    });

    test('unarchiveAccountGroup clears archivedAt but does not touch its '
        'former (already-archived) member accounts', () async {
      final group = await accountRepository.createAccountGroup(
        name: 'Business',
        kind: AccountGroupKind.assetGroup,
        currency: 'USD',
      );
      final account = await accountRepository.createFinancialAccount(
        name: 'Business Checking',
        type: AccountType.asset,
        groupId: group.id,
      );
      await accountRepository.archiveFinancialAccount(account.id);
      await accountRepository.archiveAccountGroup(group.id);

      await accountRepository.unarchiveAccountGroup(group.id);

      final groups = await accountRepository
          .watchAccountGroups(includeArchived: true)
          .first;
      expect(groups.firstWhere((g) => g.id == group.id).archived, isFalse);
      final accounts = await accountRepository
          .watchFinancialAccounts(includeArchived: true)
          .first;
      expect(
        accounts.firstWhere((a) => a.id == account.id).archived,
        isTrue,
        reason: 'unarchiving a group is independent of its member accounts',
      );
    });

    test('unarchiveAccountGroup rejects a system group', () {
      expect(
        () => accountRepository.unarchiveAccountGroup(groupPensionRetirementId),
        throwsA(isA<AccountGroupException>()),
      );
    });

    test('unarchiveCategory clears archivedAt', () async {
      final incomeId = await firstCategoryId(AccountType.income);
      await categoryRepository.archiveCategory(incomeId);

      await categoryRepository.unarchiveCategory(incomeId);

      final categories = await categoryRepository
          .watchCategories(includeArchived: true)
          .first;
      expect(categories.firstWhere((a) => a.id == incomeId).archived, isFalse);
      final active = await categoryRepository.watchCategories().first;
      expect(active.any((a) => a.id == incomeId), isTrue);
    });
  });

  group('watchAccountGroups includeArchived', () {
    test(
      'an archived group is excluded by default but included with includeArchived: true',
      () async {
        final group = await accountRepository.createAccountGroup(
          name: 'Business',
          kind: AccountGroupKind.assetGroup,
          currency: 'USD',
        );
        await accountRepository.archiveAccountGroup(group.id);

        final defaultGroups = await accountRepository
            .watchAccountGroups()
            .first;
        expect(defaultGroups.map((g) => g.id), isNot(contains(group.id)));

        final allGroups = await accountRepository
            .watchAccountGroups(includeArchived: true)
            .first;
        expect(allGroups.map((g) => g.id), contains(group.id));
      },
    );

    test(
      'an account still assigned to an archived group continues to resolve its name and currency',
      () async {
        final group = await accountRepository.createAccountGroup(
          name: 'Business',
          kind: AccountGroupKind.assetGroup,
          currency: 'GBP',
        );
        final account = await accountRepository.createFinancialAccount(
          name: 'Business Checking',
          type: AccountType.asset,
          groupId: group.id,
        );
        await accountRepository.archiveFinancialAccount(account.id);
        await accountRepository.archiveAccountGroup(group.id);

        final overview = await repository.watchHomeOverview().first;
        final section = overview.sections.firstWhere(
          (s) => s.group.id == group.id,
        );
        expect(section.group.name, equals('Business'));
        expect(section.group.currency, equals('GBP'));
        expect(section.accounts.map((b) => b.account.id), contains(account.id));
      },
    );
  });

  group('deleteAccountGroup', () {
    test('unconditionally rejects a system group', () {
      expect(
        () => accountRepository.deleteAccountGroup(groupCashEquivalentsId),
        throwsA(isA<AccountGroupException>()),
      );
    });

    test(
      'unconditionally rejects a user-created group, archived or not',
      () async {
        final group = await accountRepository.createAccountGroup(
          name: 'Business',
          kind: AccountGroupKind.assetGroup,
          currency: 'USD',
        );
        expect(
          () => accountRepository.deleteAccountGroup(group.id),
          throwsA(isA<AccountGroupException>()),
        );

        await accountRepository.archiveAccountGroup(group.id);
        expect(
          () => accountRepository.deleteAccountGroup(group.id),
          throwsA(isA<AccountGroupException>()),
        );
      },
    );
  });

  group('recordTransfer: same-currency (regression)', () {
    test('unchanged behavior - single entry, no pending transfer', () async {
      final checkingId = await firstFinancialAccountId();
      final card = await accountRepository.createFinancialAccount(
        name: 'Credit Card',
        type: AccountType.liability,
        groupId: groupCreditShortTermId,
        openingBalanceMinor: 5000,
      );

      await repository.recordTransfer(
        fromAccountId: checkingId,
        toAccountId: card.id,
        amountMinor: 1000,
        transactionDate: DateTime(2026, 1, 15),
      );

      expect(await repository.watchPendingTransfers().first, isEmpty);
    });
  });

  group('recordTransfer: known-rate cross-currency', () {
    test('posts one complete entry, no pending_transfers row', () async {
      final checkingId = await firstFinancialAccountId();
      final euroId = await secondCurrencyAssetAccountId();

      await repository.recordTransfer(
        fromAccountId: checkingId,
        toAccountId: euroId,
        amountMinor: 10000,
        destinationAmountMinor: 9200,
        transactionDate: DateTime(2026, 1, 15),
      );

      expect(await repository.watchPendingTransfers().first, isEmpty);
      expect(await repository.displayBalanceMinor(euroId), equals(9200));
    });

    test(
      'works for a payment into a different-currency liability account too',
      () async {
        final checkingId = await firstFinancialAccountId();
        final euroCardId = await secondCurrencyLiabilityAccountId(
          currency: 'EUR',
        );

        await repository.recordTransfer(
          fromAccountId: checkingId,
          toAccountId: euroCardId,
          amountMinor: 10000,
          destinationAmountMinor: 9200,
          transactionDate: DateTime(2026, 1, 15),
        );

        expect(await repository.watchPendingTransfers().first, isEmpty);
        expect(await repository.displayBalanceMinor(euroCardId), equals(-9200));
      },
    );

    test('rejects a zero or negative amount in either currency', () async {
      final checkingId = await firstFinancialAccountId();
      final euroId = await secondCurrencyAssetAccountId();

      expect(
        () => repository.recordTransfer(
          fromAccountId: checkingId,
          toAccountId: euroId,
          amountMinor: 10000,
          destinationAmountMinor: 0,
          transactionDate: DateTime(2026, 1, 15),
        ),
        throwsA(isA<InvalidTransferException>()),
      );
    });
  });

  group('recordTransfer: unknown-rate cross-currency', () {
    test('posts a provisional entry and creates a pending row', () async {
      final checkingId = await firstFinancialAccountId();
      final euroId = await secondCurrencyAssetAccountId();

      await repository.recordTransfer(
        fromAccountId: checkingId,
        toAccountId: euroId,
        amountMinor: 10000,
        transactionDate: DateTime(2026, 1, 15),
      );

      final pending = await repository.watchPendingTransfers().first;
      expect(pending, hasLength(1));
      expect(pending.single.kind, equals(PendingTransferKind.transfer));
      expect(pending.single.status, equals(PendingTransferStatus.pending));
      expect(pending.single.sourceAccountId, equals(checkingId));
      expect(pending.single.destinationAccountId, equals(euroId));
      expect(pending.single.currency, equals('USD'));
    });
  });

  group('recordArchivedAccountCloseoutTransfer', () {
    test(
      'posts from an archived account with a positive balance and zeroes the source',
      () async {
        final checkingId = await firstFinancialAccountId();
        final savings = await accountRepository.createFinancialAccount(
          name: 'Savings',
          type: AccountType.asset,
          groupId: groupCashEquivalentsId,
          openingBalanceMinor: 10000,
        );
        await accountRepository.archiveFinancialAccount(savings.id);

        await accountRepository.recordArchivedAccountCloseoutTransfer(
          fromAccountId: savings.id,
          toAccountId: checkingId,
          transactionDate: DateTime(2026, 1, 15),
        );

        expect(await repository.displayBalanceMinor(savings.id), equals(0));
        expect(await repository.displayBalanceMinor(checkingId), equals(10000));
      },
    );

    test(
      'is rejected when the archived account\'s balance is zero or negative',
      () async {
        final checkingId = await firstFinancialAccountId();
        final zeroAccount = await accountRepository.createFinancialAccount(
          name: 'Empty',
          type: AccountType.asset,
          groupId: groupCashEquivalentsId,
        );
        await accountRepository.archiveFinancialAccount(zeroAccount.id);
        expect(
          () => accountRepository.recordArchivedAccountCloseoutTransfer(
            fromAccountId: zeroAccount.id,
            toAccountId: checkingId,
            transactionDate: DateTime(2026, 1, 15),
          ),
          throwsA(isA<AccountGroupException>()),
        );

        final overdrawn = await accountRepository.createFinancialAccount(
          name: 'Overdrawn',
          type: AccountType.asset,
          groupId: groupCashEquivalentsId,
        );
        final expenseId = await firstCategoryId(AccountType.expense);
        await repository.recordTransaction(
          amountMinor: 100,
          direction: TransactionDirection.moneyOut,
          categoryId: expenseId,
          financialAccountId: overdrawn.id,
          transactionDate: DateTime(2026, 1, 15),
        );
        await accountRepository.archiveFinancialAccount(overdrawn.id);
        expect(
          () => accountRepository.recordArchivedAccountCloseoutTransfer(
            fromAccountId: overdrawn.id,
            toAccountId: checkingId,
            transactionDate: DateTime(2026, 1, 15),
          ),
          throwsA(isA<AccountGroupException>()),
        );
      },
    );

    test('is rejected when the destination is also archived', () async {
      final checkingId = await firstFinancialAccountId();
      final savings = await accountRepository.createFinancialAccount(
        name: 'Savings',
        type: AccountType.asset,
        groupId: groupCashEquivalentsId,
        openingBalanceMinor: 10000,
      );
      final other = await accountRepository.createFinancialAccount(
        name: 'Other',
        type: AccountType.asset,
        groupId: groupCashEquivalentsId,
      );
      await accountRepository.archiveFinancialAccount(savings.id);
      await accountRepository.archiveFinancialAccount(other.id);

      expect(
        () => accountRepository.recordArchivedAccountCloseoutTransfer(
          fromAccountId: savings.id,
          toAccountId: other.id,
          transactionDate: DateTime(2026, 1, 15),
        ),
        throwsA(isA<AccountGroupException>()),
      );
      expect(await repository.displayBalanceMinor(checkingId), equals(0));
    });

    test('is rejected when fromAccountId equals toAccountId', () async {
      final savings = await accountRepository.createFinancialAccount(
        name: 'Savings',
        type: AccountType.asset,
        groupId: groupCashEquivalentsId,
        openingBalanceMinor: 10000,
      );
      await accountRepository.archiveFinancialAccount(savings.id);

      expect(
        () => accountRepository.recordArchivedAccountCloseoutTransfer(
          fromAccountId: savings.id,
          toAccountId: savings.id,
          transactionDate: DateTime(2026, 1, 15),
        ),
        throwsA(isA<InvalidTransferException>()),
      );
    });

    test('a second closeout after a successful first is rejected', () async {
      final checkingId = await firstFinancialAccountId();
      final savings = await accountRepository.createFinancialAccount(
        name: 'Savings',
        type: AccountType.asset,
        groupId: groupCashEquivalentsId,
        openingBalanceMinor: 10000,
      );
      await accountRepository.archiveFinancialAccount(savings.id);
      await accountRepository.recordArchivedAccountCloseoutTransfer(
        fromAccountId: savings.id,
        toAccountId: checkingId,
        transactionDate: DateTime(2026, 1, 15),
      );

      expect(
        () => accountRepository.recordArchivedAccountCloseoutTransfer(
          fromAccountId: savings.id,
          toAccountId: checkingId,
          transactionDate: DateTime(2026, 1, 16),
        ),
        throwsA(isA<AccountGroupException>()),
      );
    });

    test(
      'recordTransaction against an archived account is still rejected',
      () async {
        final savings = await accountRepository.createFinancialAccount(
          name: 'Savings',
          type: AccountType.asset,
          groupId: groupCashEquivalentsId,
          openingBalanceMinor: 10000,
        );
        await accountRepository.archiveFinancialAccount(savings.id);
        final incomeId = await firstCategoryId(AccountType.income);

        expect(
          () => repository.recordTransaction(
            amountMinor: 100,
            direction: TransactionDirection.moneyIn,
            categoryId: incomeId,
            financialAccountId: savings.id,
            transactionDate: DateTime(2026, 1, 15),
          ),
          throwsA(isA<AccountGroupException>()),
        );
      },
    );

    test(
      'recordTransfer still rejects an archived account as source or destination',
      () async {
        final checkingId = await firstFinancialAccountId();
        final savings = await accountRepository.createFinancialAccount(
          name: 'Savings',
          type: AccountType.asset,
          groupId: groupCashEquivalentsId,
          openingBalanceMinor: 10000,
        );
        await accountRepository.archiveFinancialAccount(savings.id);

        expect(
          () => repository.recordTransfer(
            fromAccountId: savings.id,
            toAccountId: checkingId,
            amountMinor: 10000,
            transactionDate: DateTime(2026, 1, 15),
          ),
          throwsA(isA<AccountGroupException>()),
        );
        expect(
          () => repository.recordTransfer(
            fromAccountId: checkingId,
            toAccountId: savings.id,
            amountMinor: 100,
            transactionDate: DateTime(2026, 1, 15),
          ),
          throwsA(isA<AccountGroupException>()),
        );
      },
    );

    test(
      'cross-currency closeout without destinationAmountMinor is rejected; with it, one complete entry and no pending row',
      () async {
        final euroId = await secondCurrencyAssetAccountId();
        final savings = await accountRepository.createFinancialAccount(
          name: 'Savings',
          type: AccountType.asset,
          groupId: groupCashEquivalentsId,
          openingBalanceMinor: 10000,
        );
        await accountRepository.archiveFinancialAccount(savings.id);

        expect(
          () => accountRepository.recordArchivedAccountCloseoutTransfer(
            fromAccountId: savings.id,
            toAccountId: euroId,
            transactionDate: DateTime(2026, 1, 15),
          ),
          throwsA(isA<InvalidTransferException>()),
        );
        expect(await repository.watchPendingTransfers().first, isEmpty);
        expect(await repository.displayBalanceMinor(savings.id), equals(10000));

        await accountRepository.recordArchivedAccountCloseoutTransfer(
          fromAccountId: savings.id,
          toAccountId: euroId,
          transactionDate: DateTime(2026, 1, 15),
          destinationAmountMinor: 9200,
        );

        expect(await repository.displayBalanceMinor(savings.id), equals(0));
        expect(await repository.displayBalanceMinor(euroId), equals(9200));
        expect(await repository.watchPendingTransfers().first, isEmpty);
      },
    );
  });

  group('recordTransaction: foreign-currency transaction', () {
    test(
      'posts the category leg immediately in its native currency, creates a pending row',
      () async {
        final checkingId = await firstFinancialAccountId();
        final expenseId = await firstCategoryId(AccountType.expense);

        await repository.recordTransaction(
          amountMinor: 5000,
          direction: TransactionDirection.moneyOut,
          categoryId: expenseId,
          financialAccountId: checkingId,
          transactionDate: DateTime(2026, 1, 15),
          nativeCurrency: 'EUR',
        );

        final summary = await repository
            .watchSummary(
              start: DateTime(2020, 1, 1),
              end: DateTime(2030, 12, 31),
            )
            .first;
        expect(summary.totalExpenseMinor, equals(5000));

        final pending = await repository.watchPendingTransfers().first;
        expect(pending, hasLength(1));
        expect(
          pending.single.kind,
          equals(PendingTransferKind.foreignTransaction),
        );
        expect(pending.single.sourceAccountId, equals(checkingId));
        expect(pending.single.categoryId, equals(expenseId));
        expect(pending.single.currency, equals('EUR'));

        // The account leg hasn't posted yet - only the category leg has,
        // via the clearing account.
        expect(await repository.displayBalanceMinor(checkingId), equals(0));
      },
    );

    test(
      'known-rate foreign-currency transaction posts one complete entry, no pending row',
      () async {
        final checkingId = await firstFinancialAccountId();
        final expenseId = await firstCategoryId(AccountType.expense);

        await repository.recordTransaction(
          amountMinor: 5000,
          direction: TransactionDirection.moneyOut,
          categoryId: expenseId,
          financialAccountId: checkingId,
          transactionDate: DateTime(2026, 1, 15),
          nativeCurrency: 'EUR',
          accountCurrencyAmountMinor: 5400,
        );

        expect(await repository.watchPendingTransfers().first, isEmpty);
        expect(await repository.displayBalanceMinor(checkingId), equals(-5400));
      },
    );
  });

  group('settlePendingTransfer: transfer settling to destination', () {
    test(
      'no shortfall comparison, even when numerically less than the provisional amount',
      () async {
        final checkingId = await firstFinancialAccountId();
        final euroId = await secondCurrencyAssetAccountId();
        await repository.recordTransfer(
          fromAccountId: checkingId,
          toAccountId: euroId,
          amountMinor: 10000,
          transactionDate: DateTime(2026, 1, 15),
        );
        final pending = (await repository.watchPendingTransfers().first).single;

        await repository.settlePendingTransfer(
          pendingTransferId: pending.id,
          settledToAccountId: euroId,
          settledAmountMinor: 9200,
        );

        expect(await repository.displayBalanceMinor(euroId), equals(9200));
        expect(await repository.watchPendingTransfers().first, isEmpty);
      },
    );

    test('a fee category supplied on this path is rejected', () async {
      final checkingId = await firstFinancialAccountId();
      final euroId = await secondCurrencyAssetAccountId();
      final expenseId = await firstCategoryId(AccountType.expense);
      await repository.recordTransfer(
        fromAccountId: checkingId,
        toAccountId: euroId,
        amountMinor: 10000,
        transactionDate: DateTime(2026, 1, 15),
      );
      final pending = (await repository.watchPendingTransfers().first).single;

      expect(
        () => repository.settlePendingTransfer(
          pendingTransferId: pending.id,
          settledToAccountId: euroId,
          settledAmountMinor: 9200,
          feeCategoryId: expenseId,
        ),
        throwsA(isA<PendingTransferException>()),
      );
    });
  });

  group('settlePendingTransfer: transfer settling back to its source', () {
    test(
      'less than the provisional amount posts the shortfall as a fee, fully closes the position',
      () async {
        final checkingId = await firstFinancialAccountId();
        final euroId = await secondCurrencyAssetAccountId();
        final expenseId = await firstCategoryId(AccountType.expense);
        await repository.recordTransfer(
          fromAccountId: checkingId,
          toAccountId: euroId,
          amountMinor: 10000,
          transactionDate: DateTime(2026, 1, 15),
        );
        final pending = (await repository.watchPendingTransfers().first).single;
        final before = await repository.displayBalanceMinor(checkingId);

        await repository.settlePendingTransfer(
          pendingTransferId: pending.id,
          settledToAccountId: checkingId,
          settledAmountMinor: 9000,
          feeCategoryId: expenseId,
        );

        // Settlement (9000) + fee (1000) exactly equal the provisional
        // amount (10000) - the shortfall invariant.
        expect(
          await repository.displayBalanceMinor(checkingId),
          equals(before + 9000),
        );
        final summary = await repository
            .watchSummary(
              start: DateTime(2020, 1, 1),
              end: DateTime(2030, 12, 31),
            )
            .first;
        expect(summary.totalExpenseMinor, equals(1000));
        expect(await repository.watchPendingTransfers().first, isEmpty);
      },
    );

    test(
      'a zero settlement posts the full original amount as a fee/loss entry',
      () async {
        final checkingId = await firstFinancialAccountId();
        final euroId = await secondCurrencyAssetAccountId();
        final expenseId = await firstCategoryId(AccountType.expense);
        await repository.recordTransfer(
          fromAccountId: checkingId,
          toAccountId: euroId,
          amountMinor: 10000,
          transactionDate: DateTime(2026, 1, 15),
        );
        final pending = (await repository.watchPendingTransfers().first).single;

        await repository.settlePendingTransfer(
          pendingTransferId: pending.id,
          settledToAccountId: checkingId,
          settledAmountMinor: 0,
          feeCategoryId: expenseId,
        );

        final summary = await repository
            .watchSummary(
              start: DateTime(2020, 1, 1),
              end: DateTime(2030, 12, 31),
            )
            .first;
        expect(summary.totalExpenseMinor, equals(10000));
        expect(await repository.watchPendingTransfers().first, isEmpty);
      },
    );

    test('exceeding the provisional amount is rejected', () async {
      final checkingId = await firstFinancialAccountId();
      final euroId = await secondCurrencyAssetAccountId();
      await repository.recordTransfer(
        fromAccountId: checkingId,
        toAccountId: euroId,
        amountMinor: 10000,
        transactionDate: DateTime(2026, 1, 15),
      );
      final pending = (await repository.watchPendingTransfers().first).single;

      expect(
        () => repository.settlePendingTransfer(
          pendingTransferId: pending.id,
          settledToAccountId: checkingId,
          settledAmountMinor: 10001,
        ),
        throwsA(isA<PendingTransferException>()),
      );
    });

    test(
      'settling against an account that has since been archived still succeeds',
      () async {
        final checkingId = await firstFinancialAccountId();
        final euroId = await secondCurrencyAssetAccountId();
        // A third account so archiving euroId doesn't hit the
        // last-active-account guard.
        await accountRepository.createFinancialAccount(
          name: 'Spare',
          type: AccountType.asset,
          groupId: groupCashEquivalentsId,
          openingBalanceMinor: 100,
        );
        await repository.recordTransfer(
          fromAccountId: checkingId,
          toAccountId: euroId,
          amountMinor: 10000,
          transactionDate: DateTime(2026, 1, 15),
        );
        final pending = (await repository.watchPendingTransfers().first).single;
        await accountRepository.archiveFinancialAccount(euroId);

        await repository.settlePendingTransfer(
          pendingTransferId: pending.id,
          settledToAccountId: euroId,
          settledAmountMinor: 9200,
        );

        expect(await repository.displayBalanceMinor(euroId), equals(9200));
      },
    );
  });

  group('settlePendingTransfer: foreignTransaction', () {
    test(
      'always resolves to its own source account, no-shortfall path, rejects a fee category',
      () async {
        final checkingId = await firstFinancialAccountId();
        final euroId = await secondCurrencyAssetAccountId();
        final expenseId = await firstCategoryId(AccountType.expense);
        await repository.recordTransaction(
          amountMinor: 5000,
          direction: TransactionDirection.moneyOut,
          categoryId: expenseId,
          financialAccountId: checkingId,
          transactionDate: DateTime(2026, 1, 15),
          nativeCurrency: 'EUR',
        );
        final pending = (await repository.watchPendingTransfers().first).single;

        // Even supplying a different account as settledToAccountId, the
        // settlement always resolves to the transaction's own account.
        await repository.settlePendingTransfer(
          pendingTransferId: pending.id,
          settledToAccountId: euroId,
          settledAmountMinor: 5400,
        );

        expect(await repository.displayBalanceMinor(checkingId), equals(-5400));
        expect(await repository.displayBalanceMinor(euroId), equals(0));
      },
    );

    test('rejects a fee category if supplied', () async {
      final checkingId = await firstFinancialAccountId();
      final expenseId = await firstCategoryId(AccountType.expense);
      await repository.recordTransaction(
        amountMinor: 5000,
        direction: TransactionDirection.moneyOut,
        categoryId: expenseId,
        financialAccountId: checkingId,
        transactionDate: DateTime(2026, 1, 15),
        nativeCurrency: 'EUR',
      );
      final pending = (await repository.watchPendingTransfers().first).single;

      expect(
        () => repository.settlePendingTransfer(
          pendingTransferId: pending.id,
          settledToAccountId: checkingId,
          settledAmountMinor: 5400,
          feeCategoryId: expenseId,
        ),
        throwsA(isA<PendingTransferException>()),
      );
    });

    test('a zero settled amount is rejected and posts nothing', () async {
      final checkingId = await firstFinancialAccountId();
      final expenseId = await firstCategoryId(AccountType.expense);
      await repository.recordTransaction(
        amountMinor: 5000,
        direction: TransactionDirection.moneyOut,
        categoryId: expenseId,
        financialAccountId: checkingId,
        transactionDate: DateTime(2026, 1, 15),
        nativeCurrency: 'EUR',
      );
      final pending = (await repository.watchPendingTransfers().first).single;
      final before = await repository.displayBalanceMinor(checkingId);

      expect(
        () => repository.settlePendingTransfer(
          pendingTransferId: pending.id,
          settledToAccountId: checkingId,
          settledAmountMinor: 0,
        ),
        throwsA(isA<PendingTransferException>()),
      );
      expect(await repository.displayBalanceMinor(checkingId), equals(before));
      expect(
        (await repository.watchPendingTransfers().first).single.id,
        pending.id,
      );
    });
  });

  group('settlePendingTransfer: validation', () {
    test('a negative settled amount is rejected', () async {
      final checkingId = await firstFinancialAccountId();
      final euroId = await secondCurrencyAssetAccountId();
      await repository.recordTransfer(
        fromAccountId: checkingId,
        toAccountId: euroId,
        amountMinor: 10000,
        transactionDate: DateTime(2026, 1, 15),
      );
      final pending = (await repository.watchPendingTransfers().first).single;

      expect(
        () => repository.settlePendingTransfer(
          pendingTransferId: pending.id,
          settledToAccountId: euroId,
          settledAmountMinor: -1,
        ),
        throwsA(isA<PendingTransferException>()),
      );
    });

    test('settling an already-settled pending transfer is rejected', () async {
      final checkingId = await firstFinancialAccountId();
      final euroId = await secondCurrencyAssetAccountId();
      await repository.recordTransfer(
        fromAccountId: checkingId,
        toAccountId: euroId,
        amountMinor: 10000,
        transactionDate: DateTime(2026, 1, 15),
      );
      final pending = (await repository.watchPendingTransfers().first).single;
      await repository.settlePendingTransfer(
        pendingTransferId: pending.id,
        settledToAccountId: euroId,
        settledAmountMinor: 9200,
      );

      expect(
        () => repository.settlePendingTransfer(
          pendingTransferId: pending.id,
          settledToAccountId: euroId,
          settledAmountMinor: 100,
        ),
        throwsA(isA<PendingTransferException>()),
      );
    });

    test(
      'a fee category that is not an active Expense category is rejected',
      () async {
        final checkingId = await firstFinancialAccountId();
        final euroId = await secondCurrencyAssetAccountId();
        final incomeId = await firstCategoryId(AccountType.income);
        await repository.recordTransfer(
          fromAccountId: checkingId,
          toAccountId: euroId,
          amountMinor: 10000,
          transactionDate: DateTime(2026, 1, 15),
        );
        final pending = (await repository.watchPendingTransfers().first).single;

        expect(
          () => repository.settlePendingTransfer(
            pendingTransferId: pending.id,
            settledToAccountId: checkingId,
            settledAmountMinor: 9000,
            feeCategoryId: incomeId,
          ),
          throwsA(isA<PendingTransferException>()),
        );
      },
    );
  });

  group('Transfers-in-transit exclusion', () {
    test('never appears in the financial-account picker', () async {
      final accounts = await accountRepository
          .watchFinancialAccounts(includeArchived: true)
          .first;
      expect(accounts.any((a) => a.id == transfersInTransitAccountId), isFalse);
    });

    test('never appears in the Home overview\'s sections', () async {
      final checkingId = await firstFinancialAccountId();
      final euroId = await secondCurrencyAssetAccountId();
      await repository.recordTransfer(
        fromAccountId: checkingId,
        toAccountId: euroId,
        amountMinor: 10000,
        transactionDate: DateTime(2026, 1, 15),
      );

      final overview = await repository.watchHomeOverview().first;
      final allAccountIds = overview.sections
          .expand((s) => s.accounts)
          .map((b) => b.account.id);
      expect(allAccountIds.contains(transfersInTransitAccountId), isFalse);
    });
  });

  group('per-currency net position', () {
    test('computes independent totals per currency, each labeled', () async {
      final checkingId = await firstFinancialAccountId();
      final euroId = await secondCurrencyAssetAccountId();
      final incomeId = await firstCategoryId(AccountType.income);
      await repository.recordTransaction(
        amountMinor: 100000,
        direction: TransactionDirection.moneyIn,
        categoryId: incomeId,
        financialAccountId: checkingId,
        transactionDate: DateTime(2026, 1, 15),
      );
      await repository.recordTransfer(
        fromAccountId: checkingId,
        toAccountId: euroId,
        amountMinor: 10000,
        destinationAmountMinor: 9200,
        transactionDate: DateTime(2026, 1, 15),
      );

      final overview = await repository.watchHomeOverview().first;
      final usd = overview.netPositionsByCurrency.firstWhere(
        (p) => p.currency == 'USD',
      );
      final eur = overview.netPositionsByCurrency.firstWhere(
        (p) => p.currency == 'EUR',
      );
      expect(usd.totalAssetsMinor, equals(90000));
      expect(eur.totalAssetsMinor, equals(9200));
    });

    test(
      'a pending item\'s provisional amount is counted in its source currency\'s net position',
      () async {
        final checkingId = await firstFinancialAccountId();
        final euroId = await secondCurrencyAssetAccountId();
        final incomeId = await firstCategoryId(AccountType.income);
        await repository.recordTransaction(
          amountMinor: 50000,
          direction: TransactionDirection.moneyIn,
          categoryId: incomeId,
          financialAccountId: checkingId,
          transactionDate: DateTime(2026, 1, 15),
        );

        await repository.recordTransfer(
          fromAccountId: checkingId,
          toAccountId: euroId,
          amountMinor: 10000,
          transactionDate: DateTime(2026, 1, 15),
        );

        // The source leg debits checking immediately (money has genuinely
        // left it), with the same amount held in Transfers-in-transit -
        // so total USD net worth is unaffected by the transfer still being
        // provisional; only its location within USD assets shifted.
        expect(await repository.displayBalanceMinor(checkingId), equals(40000));
        final overview = await repository.watchHomeOverview().first;
        final usd = overview.netPositionsByCurrency.firstWhere(
          (p) => p.currency == 'USD',
        );
        expect(usd.totalAssetsMinor, equals(50000));
        expect(overview.pendingTransfers, hasLength(1));
        expect(overview.pendingTransfers.single.currency, equals('USD'));
        expect(overview.pendingTransfers.single.amountMinor, equals(10000));
      },
    );

    test(
      'a settled pending transfer no longer appears in the pending list',
      () async {
        final checkingId = await firstFinancialAccountId();
        final euroId = await secondCurrencyAssetAccountId();
        await repository.recordTransfer(
          fromAccountId: checkingId,
          toAccountId: euroId,
          amountMinor: 10000,
          transactionDate: DateTime(2026, 1, 15),
        );
        final pending = (await repository.watchPendingTransfers().first).single;

        var overview = await repository.watchHomeOverview().first;
        expect(overview.pendingTransfers, hasLength(1));

        await repository.settlePendingTransfer(
          pendingTransferId: pending.id,
          settledToAccountId: euroId,
          settledAmountMinor: 9200,
        );

        overview = await repository.watchHomeOverview().first;
        expect(overview.pendingTransfers, isEmpty);
      },
    );

    test(
      'pendingTransferSummary matches Home and is null after settle',
      () async {
        final checkingId = await firstFinancialAccountId();
        final euroId = await secondCurrencyAssetAccountId();
        await repository.recordTransfer(
          fromAccountId: checkingId,
          toAccountId: euroId,
          amountMinor: 10000,
          transactionDate: DateTime(2026, 1, 15),
        );
        final pending = (await repository.watchPendingTransfers().first).single;
        final overview = await repository.watchHomeOverview().first;
        final listed = overview.pendingTransfers.single;

        final byId = await repository.pendingTransferSummary(pending.id);
        expect(byId, isNotNull);
        expect(byId!.pendingTransfer.id, listed.pendingTransfer.id);
        expect(byId.sourceAccountName, listed.sourceAccountName);
        expect(byId.destinationLabel, listed.destinationLabel);
        expect(byId.currency, listed.currency);
        expect(byId.amountMinor, listed.amountMinor);

        await repository.settlePendingTransfer(
          pendingTransferId: pending.id,
          settledToAccountId: euroId,
          settledAmountMinor: 9200,
        );
        expect(await repository.pendingTransferSummary(pending.id), isNull);
        expect(await repository.pendingTransferSummary('missing'), isNull);
      },
    );

    test(
      'a quarantined provisional entry is excluded from net worth but still listed as pending',
      () async {
        final checkingId = await firstFinancialAccountId();
        final euroId = await secondCurrencyAssetAccountId();
        await repository.recordTransfer(
          fromAccountId: checkingId,
          toAccountId: euroId,
          amountMinor: 10000,
          transactionDate: DateTime(2026, 1, 15),
        );
        final pending = (await repository.watchPendingTransfers().first).single;

        await (db.update(
          db.journalEntries,
        )..where((e) => e.id.equals(pending.provisionalEntryId))).write(
          JournalEntriesCompanion(
            description: Value('tampered outside the app'),
          ),
        );
        await identityRepository.verifyChain();

        final overview = await repository.watchHomeOverview().first;
        final usd = overview.netPositionsByCurrency.firstWhere(
          (p) => p.currency == 'USD',
          orElse: () => const CurrencyNetPosition(
            currency: 'USD',
            totalAssetsMinor: 0,
            totalLiabilitiesMinor: 0,
          ),
        );
        expect(usd.totalAssetsMinor, equals(0));
        // Still visible for review, per the same "never hidden" rule as
        // any other quarantined entry.
        expect(overview.pendingTransfers, hasLength(1));
      },
    );
  });

  group('reassignFinancialAccountGroup: currency constraint', () {
    test('rejects reassigning to a different-currency group', () async {
      final checkingId = await firstFinancialAccountId();
      await accountRepository.changeAccountGroupCurrency(
        groupId: groupPensionRetirementId,
        currency: 'EUR',
      );

      expect(
        () => accountRepository.reassignFinancialAccountGroup(
          id: checkingId,
          groupId: groupPensionRetirementId,
        ),
        throwsA(isA<AccountGroupException>()),
      );
    });

    test('reassigning within the same currency still works', () async {
      final checkingId = await firstFinancialAccountId();

      await accountRepository.reassignFinancialAccountGroup(
        id: checkingId,
        groupId: groupPensionRetirementId,
      );

      final accounts = await accountRepository
          .watchFinancialAccounts(includeArchived: true)
          .first;
      expect(
        accounts.firstWhere((a) => a.id == checkingId).groupId,
        equals(groupPensionRetirementId),
      );
    });
  });

  group('pending transfer reversal guard', () {
    test(
      'directly reversing a still-pending provisional entry is rejected',
      () async {
        final checkingId = await firstFinancialAccountId();
        final euroId = await secondCurrencyAssetAccountId();
        await repository.recordTransfer(
          fromAccountId: checkingId,
          toAccountId: euroId,
          amountMinor: 10000,
          transactionDate: DateTime(2026, 1, 15),
        );
        final pending = (await repository.watchPendingTransfers().first).single;

        expect(
          () => repository.reverseEntry(pending.provisionalEntryId),
          throwsA(isA<PendingTransferException>()),
        );
      },
    );

    test('reversing after settlement succeeds normally', () async {
      final checkingId = await firstFinancialAccountId();
      final euroId = await secondCurrencyAssetAccountId();
      final incomeId = await firstCategoryId(AccountType.income);
      await repository.recordTransaction(
        amountMinor: 50000,
        direction: TransactionDirection.moneyIn,
        categoryId: incomeId,
        financialAccountId: checkingId,
        transactionDate: DateTime(2026, 1, 15),
      );
      await repository.recordTransfer(
        fromAccountId: checkingId,
        toAccountId: euroId,
        amountMinor: 10000,
        transactionDate: DateTime(2026, 1, 15),
      );
      final pending = (await repository.watchPendingTransfers().first).single;
      await repository.settlePendingTransfer(
        pendingTransferId: pending.id,
        settledToAccountId: euroId,
        settledAmountMinor: 9200,
      );
      expect(await repository.displayBalanceMinor(checkingId), equals(40000));

      await repository.reverseEntry(pending.provisionalEntryId);

      // The reversal undoes exactly the source leg's original debit,
      // restoring checking to its pre-transfer balance.
      expect(await repository.displayBalanceMinor(checkingId), equals(50000));
    });
  });

  group('investment holdings', () {
    Future<String> createInvestmentAccount() async {
      return (await accountRepository.createFinancialAccount(
        name: 'Brokerage',
        type: AccountType.asset,
        groupId: groupInvestmentsId,
        holdsInvestments: true,
      )).id;
    }

    Future<String> nonInvestmentCashAccountId() async {
      final accounts = await accountRepository.watchFinancialAccounts().first;
      return accounts.firstWhere((a) => !a.isInvestmentAccount).id;
    }

    test('cash-funded buy updates cash and inventory', () async {
      final accountId = await createInvestmentAccount();
      await repository.recordTransfer(
        fromAccountId: await nonInvestmentCashAccountId(),
        toAccountId: accountId,
        amountMinor: 100000,
        transactionDate: DateTime(2026, 1, 1),
      );
      final instrument = await investmentRepository.createInstrument(
        name: 'Apple Inc',
        kind: InstrumentKind.stock,
      );
      await investmentRepository.recordBuy(
        accountId: accountId,
        instrumentId: instrument.id,
        quantityScaled: 10000,
        unitPriceMinor: 10000,
        transactionDate: DateTime(2026, 1, 2),
        fundingSource: BuyFundingSource.cash,
      );
      expect(await repository.displayBalanceMinor(accountId), equals(90000));
      final holdings = await investmentRepository.computeHoldingsForAccount(
        accountId,
      );
      expect(holdings.length, equals(1));
      expect(holdings.first.quantityScaled, equals(10000));
      expect(holdings.first.totalCostMinor, equals(10000));
    });

    test('cash-funded buy rejected when cash insufficient', () async {
      final accountId = await createInvestmentAccount();
      final instrument = await investmentRepository.createInstrument(
        name: 'Tesla',
        kind: InstrumentKind.stock,
      );
      await expectLater(
        () => investmentRepository.recordBuy(
          accountId: accountId,
          instrumentId: instrument.id,
          quantityScaled: 10000,
          unitPriceMinor: 10000,
          transactionDate: DateTime(2026, 1, 2),
          fundingSource: BuyFundingSource.cash,
        ),
        throwsA(isA<InsufficientCashException>()),
      );
    });

    test('sell at gain posts proceeds and reduces inventory', () async {
      final accountId = await createInvestmentAccount();
      await repository.recordTransfer(
        fromAccountId: await nonInvestmentCashAccountId(),
        toAccountId: accountId,
        amountMinor: 100000,
        transactionDate: DateTime(2026, 1, 1),
      );
      final instrument = await investmentRepository.createInstrument(
        name: 'MSFT',
        kind: InstrumentKind.stock,
      );
      await investmentRepository.recordBuy(
        accountId: accountId,
        instrumentId: instrument.id,
        quantityScaled: 10000,
        unitPriceMinor: 10000,
        transactionDate: DateTime(2026, 1, 2),
        fundingSource: BuyFundingSource.cash,
      );
      final incomeId = await firstCategoryId(AccountType.income);
      await investmentRepository.recordSell(
        accountId: accountId,
        instrumentId: instrument.id,
        quantityScaled: 10000,
        unitPriceMinor: 12000,
        transactionDate: DateTime(2026, 2, 1),
        gainIncomeCategoryId: incomeId,
      );
      expect(await repository.displayBalanceMinor(accountId), equals(102000));
      final holdings = await investmentRepository.computeHoldingsForAccount(
        accountId,
      );
      expect(holdings, isEmpty);
    });
  });

  group('payees', () {
    test('createPayee, watchPayees, renamePayee, deletePayee', () async {
      final expenseCategoryId = await firstCategoryId(AccountType.expense);
      final created = await payeeRepository.createPayee(
        name: 'Starbucks',
        defaultCategoryId: expenseCategoryId,
      );
      expect(created.name, equals('Starbucks'));
      expect(created.defaultCategoryId, equals(expenseCategoryId));

      var payees = await payeeRepository.watchPayees().first;
      expect(payees.map((p) => p.name), equals(['Starbucks']));

      await payeeRepository.renamePayee(
        id: created.id,
        newName: 'Starbucks Coffee',
      );
      payees = await payeeRepository.watchPayees().first;
      expect(payees.single.name, equals('Starbucks Coffee'));

      await payeeRepository.deletePayee(created.id);
      payees = await payeeRepository.watchPayees().first;
      expect(payees, isEmpty);
    });

    test(
      'recordPayeeUsage updates the remembered defaults to what was just used',
      () async {
        final groceriesId = await firstCategoryId(AccountType.expense);
        final incomeId = await firstCategoryId(AccountType.income);
        final accountId = await firstFinancialAccountId();
        final created = await payeeRepository.createPayee(name: 'Landlord');

        await payeeRepository.recordPayeeUsage(
          payeeId: created.id,
          categoryId: groceriesId,
          financialAccountId: accountId,
        );
        var payee = (await payeeRepository.watchPayees().first).single;
        expect(payee.defaultCategoryId, equals(groceriesId));
        expect(payee.defaultFinancialAccountId, equals(accountId));

        // A later recording updates the default again, to the newest usage.
        await payeeRepository.recordPayeeUsage(
          payeeId: created.id,
          categoryId: incomeId,
          financialAccountId: accountId,
        );
        payee = (await payeeRepository.watchPayees().first).single;
        expect(payee.defaultCategoryId, equals(incomeId));
      },
    );

    group('findOrCreatePayeeByName', () {
      test(
        'creates a new payee when no normalized-name match exists',
        () async {
          final categoryId = await firstCategoryId(AccountType.expense);
          final payee = await payeeRepository.findOrCreatePayeeByName(
            name: 'Amazon',
            defaultCategoryId: categoryId,
          );
          expect(payee.name, equals('Amazon'));
          expect(payee.defaultCategoryId, equals(categoryId));
          final all = await payeeRepository.watchPayees().first;
          expect(all, hasLength(1));
        },
      );

      test(
        'links (and updates the default category of) an existing payee '
        'matched by normalized name, rather than creating a duplicate',
        () async {
          final firstCategoryIdValue = await firstCategoryId(
            AccountType.expense,
          );
          final existing = await payeeRepository.createPayee(
            name: '  amazon  ',
            defaultCategoryId: firstCategoryIdValue,
          );

          final incomeId = await firstCategoryId(AccountType.income);
          final linked = await payeeRepository.findOrCreatePayeeByName(
            name: 'Amazon',
            defaultCategoryId: incomeId,
          );

          expect(linked.id, equals(existing.id));
          final all = await payeeRepository.watchPayees().first;
          expect(all, hasLength(1));
          expect(all.single.defaultCategoryId, equals(incomeId));
        },
      );
    });
  });

  group('recurring templates', () {
    test(
      'createRecurringTemplate, watchRecurringTemplates, update, delete',
      () async {
        final accountId = await firstFinancialAccountId();
        final expenseId = await firstCategoryId(AccountType.expense);
        final incomeId = await firstCategoryId(AccountType.income);

        final created = await recurringTemplateRepository
            .createRecurringTemplate(
              name: 'Rent',
              direction: TransactionDirection.moneyOut,
              financialAccountId: accountId,
              categoryId: expenseId,
              amountMinor: 150000,
              dayOfMonth: 1,
            );
        expect(created.name, equals('Rent'));

        var templates = await recurringTemplateRepository
            .watchRecurringTemplates()
            .first;
        expect(templates, hasLength(1));
        expect(templates.single.dayOfMonth, equals(1));

        await recurringTemplateRepository.updateRecurringTemplate(
          id: created.id,
          name: 'Rent (updated)',
          direction: TransactionDirection.moneyIn,
          financialAccountId: accountId,
          categoryId: incomeId,
          amountMinor: 200000,
          dayOfMonth: 5,
        );
        templates = await recurringTemplateRepository
            .watchRecurringTemplates()
            .first;
        expect(templates.single.name, equals('Rent (updated)'));
        expect(
          templates.single.direction,
          equals(TransactionDirection.moneyIn),
        );
        expect(templates.single.amountMinor, equals(200000));
        expect(templates.single.dayOfMonth, equals(5));

        await recurringTemplateRepository.deleteRecurringTemplate(created.id);
        templates = await recurringTemplateRepository
            .watchRecurringTemplates()
            .first;
        expect(templates, isEmpty);
      },
    );

    test('createRecurringTemplate rejects a non-positive amount', () async {
      final accountId = await firstFinancialAccountId();
      final expenseId = await firstCategoryId(AccountType.expense);

      expect(
        () => recurringTemplateRepository.createRecurringTemplate(
          name: 'Rent',
          direction: TransactionDirection.moneyOut,
          financialAccountId: accountId,
          categoryId: expenseId,
          amountMinor: 0,
          dayOfMonth: 1,
        ),
        throwsA(isA<InvalidTransactionAmountException>()),
      );
    });

    test(
      'createRecurringTemplate rejects a day-of-month outside 1-31',
      () async {
        final accountId = await firstFinancialAccountId();
        final expenseId = await firstCategoryId(AccountType.expense);

        expect(
          () => recurringTemplateRepository.createRecurringTemplate(
            name: 'Rent',
            direction: TransactionDirection.moneyOut,
            financialAccountId: accountId,
            categoryId: expenseId,
            amountMinor: 1000,
            dayOfMonth: 32,
          ),
          throwsA(isA<ArgumentError>()),
        );
      },
    );

    test(
      'watchDueRecurringTemplates surfaces a due template with resolved '
      'names and currency, and excludes one already recorded this month',
      () async {
        final accountId = await firstFinancialAccountId();
        final expenseId = await firstCategoryId(AccountType.expense);
        final today = DateTime.now();

        final due = await recurringTemplateRepository.createRecurringTemplate(
          name: 'Rent',
          direction: TransactionDirection.moneyOut,
          financialAccountId: accountId,
          categoryId: expenseId,
          amountMinor: 150000,
          dayOfMonth: today.day,
        );
        final notDue = await recurringTemplateRepository
            .createRecurringTemplate(
              name: 'Already paid',
              direction: TransactionDirection.moneyOut,
              financialAccountId: accountId,
              categoryId: expenseId,
              amountMinor: 5000,
              dayOfMonth: today.day,
            );
        // Mark as already recorded this month via the same path
        // recordDueTemplate uses, so it's excluded from "due" going
        // forward this month.
        await recurringTemplateRepository.recordDueTemplate(notDue.id);

        final dueList = await recurringTemplateRepository
            .watchDueRecurringTemplates()
            .first;

        expect(dueList, hasLength(1));
        expect(dueList.single.template.id, equals(due.id));
        expect(dueList.single.currency, equals('USD'));
        expect(dueList.single.categoryName, isNotEmpty);
        expect(dueList.single.financialAccountName, isNotEmpty);
      },
    );

    test('recordDueTemplate posts a real transaction and removes the template '
        'from the due list afterward', () async {
      final accountId = await firstFinancialAccountId();
      final expenseId = await firstCategoryId(AccountType.expense);
      final today = DateTime.now();
      final startingBalance = await repository.displayBalanceMinor(accountId);

      final template = await recurringTemplateRepository
          .createRecurringTemplate(
            name: 'Rent',
            direction: TransactionDirection.moneyOut,
            financialAccountId: accountId,
            categoryId: expenseId,
            amountMinor: 150000,
            dayOfMonth: today.day,
          );

      var dueList = await recurringTemplateRepository
          .watchDueRecurringTemplates()
          .first;
      expect(dueList, hasLength(1));

      final entryId = await recurringTemplateRepository.recordDueTemplate(
        template.id,
      );
      expect(entryId, isNotEmpty);

      expect(
        await repository.displayBalanceMinor(accountId),
        equals(startingBalance - 150000),
      );

      dueList = await recurringTemplateRepository
          .watchDueRecurringTemplates()
          .first;
      expect(dueList, isEmpty);

      final templates = await recurringTemplateRepository
          .watchRecurringTemplates()
          .first;
      expect(
        templates.single.lastRecordedYearMonth,
        equals(yearMonthOf(today)),
      );
    });
  });

  group('exportLedgerCsv', () {
    test(
      'exports a header plus one row per ordinary transaction, oldest first',
      () async {
        final accountId = await firstFinancialAccountId();
        final incomeId = await firstCategoryId(AccountType.income);
        final expenseId = await firstCategoryId(AccountType.expense);
        await repository.recordTransaction(
          amountMinor: 300000,
          direction: TransactionDirection.moneyIn,
          categoryId: incomeId,
          financialAccountId: accountId,
          transactionDate: DateTime(2026, 1, 20),
          description: 'Paycheck',
        );
        await repository.recordTransaction(
          amountMinor: 5000,
          direction: TransactionDirection.moneyOut,
          categoryId: expenseId,
          financialAccountId: accountId,
          transactionDate: DateTime(2026, 1, 5),
          description: 'Groceries run',
        );

        final csv = await repository.exportLedgerCsv(
          financialAccountId: accountId,
          start: DateTime(2026, 1, 1),
          end: DateTime(2026, 1, 31),
        );

        final lines = csv.trim().split('\n');
        expect(
          lines[0],
          equals(
            'Date,Description,Category,Direction,Amount,Currency,Verified',
          ),
        );
        expect(lines, hasLength(3));
        // Oldest first: the expense (Jan 5) before the income (Jan 20).
        expect(lines[1], startsWith('2026-01-05,Groceries run,'));
        expect(lines[1], contains('Spent'));
        expect(lines[1], contains('50.00'));
        expect(lines[2], startsWith('2026-01-20,Paycheck,'));
        expect(lines[2], contains('Received'));
        expect(lines[2], contains('3000.00'));
        expect(lines[2], endsWith(',USD,Yes'));
      },
    );

    test('excludes transactions outside the requested date range', () async {
      final accountId = await firstFinancialAccountId();
      final expenseId = await firstCategoryId(AccountType.expense);
      await repository.recordTransaction(
        amountMinor: 1000,
        direction: TransactionDirection.moneyOut,
        categoryId: expenseId,
        financialAccountId: accountId,
        transactionDate: DateTime(2026, 2, 1),
      );

      final csv = await repository.exportLedgerCsv(
        financialAccountId: accountId,
        start: DateTime(2026, 1, 1),
        end: DateTime(2026, 1, 31),
      );

      expect(csv.trim().split('\n'), hasLength(1)); // header only
    });

    test('a split entry exports one row per category leg', () async {
      final accountId = await firstFinancialAccountId();
      final categories = await categoryRepository.watchCategories().first;
      final expenseIds = categories
          .where((c) => c.type == AccountType.expense)
          .take(2)
          .map((c) => c.id)
          .toList();
      await repository.recordSplitTransaction(
        totalAmountMinor: 10000,
        splitLines: [
          (categoryId: expenseIds[0], amountMinor: 6000),
          (categoryId: expenseIds[1], amountMinor: 4000),
        ],
        direction: TransactionDirection.moneyOut,
        financialAccountId: accountId,
        transactionDate: DateTime(2026, 1, 10),
      );

      final csv = await repository.exportLedgerCsv(
        financialAccountId: accountId,
        start: DateTime(2026, 1, 1),
        end: DateTime(2026, 1, 31),
      );

      final lines = csv.trim().split('\n');
      expect(lines, hasLength(3)); // header + 2 legs
      expect(lines[1], contains('60.00'));
      expect(lines[2], contains('40.00'));
    });

    test('a transfer exports the counterparty account as its label', () async {
      final fromId = await firstFinancialAccountId();
      final toAccount = await accountRepository.createFinancialAccount(
        name: 'Savings',
        type: AccountType.asset,
        groupId: groupCashEquivalentsId,
      );
      await repository.recordTransfer(
        fromAccountId: fromId,
        toAccountId: toAccount.id,
        amountMinor: 2000,
        transactionDate: DateTime(2026, 1, 15),
      );

      final csv = await repository.exportLedgerCsv(
        financialAccountId: fromId,
        start: DateTime(2026, 1, 1),
        end: DateTime(2026, 1, 31),
      );

      expect(csv, contains('Transfer: Savings'));
    });

    test('a quarantined entry is still exported, marked Verified=No', () async {
      final accountId = await firstFinancialAccountId();
      final incomeId = await firstCategoryId(AccountType.income);
      final entryId = await repository.recordTransaction(
        amountMinor: 1000,
        direction: TransactionDirection.moneyIn,
        categoryId: incomeId,
        financialAccountId: accountId,
        transactionDate: DateTime(2026, 1, 10),
      );
      // Tamper directly with the stored row (mirrors the verifyChain
      // group's own pattern) - not through the Repository, which has
      // no update path for a posted entry.
      await (db.update(
        db.journalEntries,
      )..where((e) => e.id.equals(entryId))).write(
        JournalEntriesCompanion(description: Value('tampered outside the app')),
      );
      await identityRepository.verifyChain();

      final csv = await repository.exportLedgerCsv(
        financialAccountId: accountId,
        start: DateTime(2026, 1, 1),
        end: DateTime(2026, 1, 31),
      );

      final lines = csv.trim().split('\n');
      expect(lines, hasLength(2));
      expect(lines[1], endsWith(',No'));
    });

    test(
      'JPY (0 decimal digits) formats amounts with no decimal point',
      () async {
        await accountRepository.changeAccountGroupCurrency(
          groupId: groupPensionRetirementId,
          currency: 'JPY',
        );
        final jpyAccount = await accountRepository.createFinancialAccount(
          name: 'Yen Account',
          type: AccountType.asset,
          groupId: groupPensionRetirementId,
        );
        final incomeId = await firstCategoryId(AccountType.income);
        await repository.recordTransaction(
          amountMinor: 5000,
          direction: TransactionDirection.moneyIn,
          categoryId: incomeId,
          financialAccountId: jpyAccount.id,
          transactionDate: DateTime(2026, 1, 10),
        );

        final csv = await repository.exportLedgerCsv(
          financialAccountId: jpyAccount.id,
          start: DateTime(2026, 1, 1),
          end: DateTime(2026, 1, 31),
        );

        // JPY's minor unit digit count is 0 - the raw minor-unit amount
        // (5000) IS the major-unit amount, formatted with no decimal point.
        expect(csv, contains(',5000,JPY,'));
      },
    );

    test('rejects an id that is not a financial account', () async {
      final incomeId = await firstCategoryId(AccountType.income);
      expect(
        () => repository.exportLedgerCsv(
          financialAccountId: incomeId,
          start: DateTime(2026, 1, 1),
          end: DateTime(2026, 1, 31),
        ),
        throwsA(isA<AccountGroupException>()),
      );
    });

    test('a description containing a comma is CSV-quoted', () async {
      final accountId = await firstFinancialAccountId();
      final incomeId = await firstCategoryId(AccountType.income);
      await repository.recordTransaction(
        amountMinor: 1000,
        direction: TransactionDirection.moneyIn,
        categoryId: incomeId,
        financialAccountId: accountId,
        transactionDate: DateTime(2026, 1, 10),
        description: 'Bonus, Q1',
      );

      final csv = await repository.exportLedgerCsv(
        financialAccountId: accountId,
        start: DateTime(2026, 1, 1),
        end: DateTime(2026, 1, 31),
      );

      expect(csv, contains('"Bonus, Q1"'));
    });
  });
}
