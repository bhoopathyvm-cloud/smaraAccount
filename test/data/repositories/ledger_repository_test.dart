import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:smara_accounting/data/database/app_database.dart';
import 'package:smara_accounting/data/database/tables/account_groups_table.dart';
import 'package:smara_accounting/data/database/tables/accounts_table.dart';
import 'package:smara_accounting/data/repositories/investment_holdings_logic.dart';
import 'package:smara_accounting/data/repositories/ledger_repository.dart';
import 'package:smara_accounting/domain/models/instrument.dart';
import 'package:smara_accounting/domain/crypto/signing_key_service.dart';
import 'package:smara_accounting/domain/exceptions.dart';
import 'package:smara_accounting/domain/models/home_overview.dart';
import 'package:smara_accounting/domain/models/integrity_event.dart';
import 'package:smara_accounting/domain/models/pending_transfer.dart';
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
    await repository.confirmFirstIdentity(generated, currency: 'USD');
  });

  tearDown(() async {
    await db.close();
  });

  Future<String> firstFinancialAccountId() async {
    final accounts = await repository.watchFinancialAccounts().first;
    return accounts.first.id;
  }

  Future<String> firstCategoryId(AccountType type) async {
    final categories = await repository.watchCategories().first;
    return categories.firstWhere((a) => a.type == type).id;
  }

  // Every starter group lands in USD (setUp's confirmFirstIdentity). These
  // helpers park a second currency on an otherwise-empty starter group
  // (groupPensionRetirementId/groupLoansMortgagesId never get the seeded
  // financial account) so cross-currency scenarios have a real second
  // account to work with.
  Future<String> secondCurrencyAssetAccountId({String currency = 'EUR'}) async {
    await repository.changeAccountGroupCurrency(
      groupId: groupPensionRetirementId,
      currency: currency,
    );
    final account = await repository.createFinancialAccount(
      name: 'Euro Savings',
      type: AccountType.asset,
      groupId: groupPensionRetirementId,
    );
    return account.id;
  }

  Future<String> secondCurrencyLiabilityAccountId({
    String currency = 'EUR',
  }) async {
    await repository.changeAccountGroupCurrency(
      groupId: groupLoansMortgagesId,
      currency: currency,
    );
    final account = await repository.createFinancialAccount(
      name: 'Euro Loan',
      type: AccountType.liability,
      groupId: groupLoansMortgagesId,
    );
    return account.id;
  }

  group('starter account seeding', () {
    test(
      'confirmFirstIdentity seeds the single asset account and starter categories',
      () async {
        final categories = await repository.watchCategories().first;
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
        final freshRepository = LedgerRepository(
          database: freshDb,
          signingKeyService: SigningKeyService(
            secureStorage: InMemorySecureKeyStorage(),
          ),
        );

        expect(await freshRepository.watchCategories().first, isEmpty);

        final generated = await freshRepository.generateFirstIdentity();
        expect(await freshRepository.watchCategories().first, isEmpty);

        await freshRepository.confirmFirstIdentity(generated, currency: 'USD');
        final categories = await freshRepository.watchCategories().first;
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

      final confirmed = await freshRepository.confirmFirstIdentity(
        generated,
        currency: 'USD',
      );
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
            .confirmFirstIdentity(generated, currency: 'USD');

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
      'restoreIdentity on a reinstalled device with the keystore file matches the original identity',
      () async {
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
            .confirmFirstIdentity(generated, currency: 'USD');
        final keystoreFile = await firstInstallRepository.exportKeystoreFile(
          passphrase: 'hunter2-hunter2',
        );

        final reinstalledRepository = LedgerRepository(
          database: freshDb,
          signingKeyService: SigningKeyService(
            secureStorage: InMemorySecureKeyStorage(),
          ),
        );

        final restored = await reinstalledRepository.restoreIdentity(
          keystoreFileContents: keystoreFile,
          keystorePassphrase: 'hunter2-hunter2',
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

        final result = await repository.verifyChain();
        expect(result.isFullyVerified, isTrue);
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

  group('financial account management', () {
    test('creates an asset account in a matching group', () async {
      final account = await repository.createFinancialAccount(
        name: 'Savings',
        type: AccountType.asset,
        groupId: groupCashEquivalentsId,
      );

      final accounts = await repository.watchFinancialAccounts().first;
      expect(
        accounts.any((a) => a.id == account.id && a.name == 'Savings'),
        isTrue,
      );
    });

    test('creates a liability account in a matching group', () async {
      final account = await repository.createFinancialAccount(
        name: 'Credit Card',
        type: AccountType.liability,
        groupId: groupCreditShortTermId,
      );

      expect(account.type, equals(AccountType.liability));
    });

    test('rejects a group-kind mismatch on create', () async {
      expect(
        () => repository.createFinancialAccount(
          name: 'Bad',
          type: AccountType.asset,
          groupId: groupCreditShortTermId,
        ),
        throwsA(isA<AccountGroupException>()),
      );
    });

    test('rejects an unknown group on create', () async {
      expect(
        () => repository.createFinancialAccount(
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
        await repository.createFinancialAccount(
          name: 'Credit Card',
          type: AccountType.liability,
          groupId: groupCreditShortTermId,
        );

        final categories = await repository
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
        final second = await repository.createFinancialAccount(
          name: 'Savings',
          type: AccountType.asset,
          groupId: groupCashEquivalentsId,
        );

        await repository.archiveFinancialAccount(second.id);

        final active = await repository.watchFinancialAccounts().first;
        expect(active.any((a) => a.id == second.id), isFalse);

        final all = await repository
            .watchFinancialAccounts(includeArchived: true)
            .first;
        expect(all.any((a) => a.id == second.id), isTrue);
      },
    );

    test('rejects archiving the last active financial account', () async {
      final onlyAccountId = await firstFinancialAccountId();

      expect(
        () => repository.archiveFinancialAccount(onlyAccountId),
        throwsA(isA<LastActiveAccountException>()),
      );
    });

    test(
      'reassignFinancialAccountGroup moves the account to another matching-kind group',
      () async {
        final accountId = await firstFinancialAccountId();

        await repository.reassignFinancialAccountGroup(
          id: accountId,
          groupId: groupPensionRetirementId,
        );

        final accounts = await repository.watchFinancialAccounts().first;
        expect(
          accounts.firstWhere((a) => a.id == accountId).groupId,
          equals(groupPensionRetirementId),
        );
      },
    );

    test('rejects a group-kind mismatch on reassignment', () async {
      final accountId = await firstFinancialAccountId();

      expect(
        () => repository.reassignFinancialAccountGroup(
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
        final destination = await repository.createFinancialAccount(
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
        final card = await repository.createFinancialAccount(
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
      final destination = await repository.createFinancialAccount(
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
        final destination = await repository.createFinancialAccount(
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
        final account = await repository.createFinancialAccount(
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
      final account = await repository.createFinancialAccount(
        name: 'Credit Card',
        type: AccountType.liability,
        groupId: groupCreditShortTermId,
        openingBalanceMinor: 15000,
      );

      expect(await repository.displayBalanceMinor(account.id), equals(15000));
    });

    test('rejects a zero or negative opening balance', () async {
      expect(
        () => repository.createFinancialAccount(
          name: 'Savings',
          type: AccountType.asset,
          groupId: groupCashEquivalentsId,
          openingBalanceMinor: 0,
        ),
        throwsA(isA<InvalidOpeningBalanceException>()),
      );
      expect(
        () => repository.createFinancialAccount(
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
        await repository.createFinancialAccount(
          name: 'Savings',
          type: AccountType.asset,
          groupId: groupCashEquivalentsId,
          openingBalanceMinor: 1000,
        );

        final accounts = await repository
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
      final card = await repository.createFinancialAccount(
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
        final second = await repository.createFinancialAccount(
          name: 'Savings',
          type: AccountType.asset,
          groupId: groupCashEquivalentsId,
          openingBalanceMinor: 5000,
        );
        await repository.archiveFinancialAccount(second.id);

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
        await repository.verifyChain();

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

        final result = await repository.verifyChain();

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

        final result = await repository.verifyChain();
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
        await repository.verifyChain();

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
          financialAccountId: await firstFinancialAccountId(),
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

        await repository.migrateToNewIdentityAfterKeyLoss();
        final result = await repository.verifyChain();

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
        final groups = await repository.watchAccountGroups().first;
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
          () => repository.createFinancialAccount(
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
        () => repository.changeAccountGroupCurrency(
          groupId: groupCashEquivalentsId,
          currency: 'EUR',
        ),
        throwsA(isA<AccountGroupException>()),
      );
    });

    test('allowed when the group has zero active accounts', () async {
      await repository.changeAccountGroupCurrency(
        groupId: groupPensionRetirementId,
        currency: 'EUR',
      );
      final groups = await repository.watchAccountGroups().first;
      expect(
        groups.firstWhere((g) => g.id == groupPensionRetirementId).currency,
        equals('EUR'),
      );
    });
  });

  group('createAccountGroup', () {
    test('creates a non-system group with the next sortOrder', () async {
      final created = await repository.createAccountGroup(
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

      final groups = await repository.watchAccountGroups().first;
      expect(groups.map((g) => g.id), contains(created.id));
    });

    test('rejects a blank currency', () {
      expect(
        () => repository.createAccountGroup(
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
        () => repository.archiveAccountGroup(groupPensionRetirementId),
        throwsA(isA<AccountGroupException>()),
      );
    });

    test(
      'rejected for a user-created group with an active member account',
      () async {
        final group = await repository.createAccountGroup(
          name: 'Business',
          kind: AccountGroupKind.assetGroup,
          currency: 'USD',
        );
        await repository.createFinancialAccount(
          name: 'Business Checking',
          type: AccountType.asset,
          groupId: group.id,
        );

        expect(
          () => repository.archiveAccountGroup(group.id),
          throwsA(isA<AccountGroupException>()),
        );
      },
    );

    test(
      'succeeds for an empty user-created group and sets archived',
      () async {
        final group = await repository.createAccountGroup(
          name: 'Business',
          kind: AccountGroupKind.assetGroup,
          currency: 'USD',
        );

        await repository.archiveAccountGroup(group.id);

        final groups = await repository
            .watchAccountGroups(includeArchived: true)
            .first;
        expect(groups.firstWhere((g) => g.id == group.id).archived, isTrue);
      },
    );

    test('rejected for a group that is already archived', () async {
      final group = await repository.createAccountGroup(
        name: 'Business',
        kind: AccountGroupKind.assetGroup,
        currency: 'USD',
      );
      await repository.archiveAccountGroup(group.id);

      expect(
        () => repository.archiveAccountGroup(group.id),
        throwsA(isA<AccountGroupException>()),
      );
    });

    test(
      'a group with only an archived member account can be archived',
      () async {
        final group = await repository.createAccountGroup(
          name: 'Business',
          kind: AccountGroupKind.assetGroup,
          currency: 'USD',
        );
        // A financial account requires at least one other active account
        // to remain to be archivable - use the seeded Cash & cash
        // equivalents account as that "other" account.
        final account = await repository.createFinancialAccount(
          name: 'Business Checking',
          type: AccountType.asset,
          groupId: group.id,
        );
        await repository.archiveFinancialAccount(account.id);

        await repository.archiveAccountGroup(group.id);

        final groups = await repository
            .watchAccountGroups(includeArchived: true)
            .first;
        expect(groups.firstWhere((g) => g.id == group.id).archived, isTrue);
      },
    );
  });

  group('watchAccountGroups includeArchived', () {
    test(
      'an archived group is excluded by default but included with includeArchived: true',
      () async {
        final group = await repository.createAccountGroup(
          name: 'Business',
          kind: AccountGroupKind.assetGroup,
          currency: 'USD',
        );
        await repository.archiveAccountGroup(group.id);

        final defaultGroups = await repository.watchAccountGroups().first;
        expect(defaultGroups.map((g) => g.id), isNot(contains(group.id)));

        final allGroups = await repository
            .watchAccountGroups(includeArchived: true)
            .first;
        expect(allGroups.map((g) => g.id), contains(group.id));
      },
    );

    test(
      'an account still assigned to an archived group continues to resolve its name and currency',
      () async {
        final group = await repository.createAccountGroup(
          name: 'Business',
          kind: AccountGroupKind.assetGroup,
          currency: 'GBP',
        );
        final account = await repository.createFinancialAccount(
          name: 'Business Checking',
          type: AccountType.asset,
          groupId: group.id,
        );
        await repository.archiveFinancialAccount(account.id);
        await repository.archiveAccountGroup(group.id);

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
        () => repository.deleteAccountGroup(groupCashEquivalentsId),
        throwsA(isA<AccountGroupException>()),
      );
    });

    test(
      'unconditionally rejects a user-created group, archived or not',
      () async {
        final group = await repository.createAccountGroup(
          name: 'Business',
          kind: AccountGroupKind.assetGroup,
          currency: 'USD',
        );
        expect(
          () => repository.deleteAccountGroup(group.id),
          throwsA(isA<AccountGroupException>()),
        );

        await repository.archiveAccountGroup(group.id);
        expect(
          () => repository.deleteAccountGroup(group.id),
          throwsA(isA<AccountGroupException>()),
        );
      },
    );
  });

  group('recordTransfer: same-currency (regression)', () {
    test('unchanged behavior - single entry, no pending transfer', () async {
      final checkingId = await firstFinancialAccountId();
      final card = await repository.createFinancialAccount(
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
        final savings = await repository.createFinancialAccount(
          name: 'Savings',
          type: AccountType.asset,
          groupId: groupCashEquivalentsId,
          openingBalanceMinor: 10000,
        );
        await repository.archiveFinancialAccount(savings.id);

        await repository.recordArchivedAccountCloseoutTransfer(
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
        final zeroAccount = await repository.createFinancialAccount(
          name: 'Empty',
          type: AccountType.asset,
          groupId: groupCashEquivalentsId,
        );
        await repository.archiveFinancialAccount(zeroAccount.id);
        expect(
          () => repository.recordArchivedAccountCloseoutTransfer(
            fromAccountId: zeroAccount.id,
            toAccountId: checkingId,
            transactionDate: DateTime(2026, 1, 15),
          ),
          throwsA(isA<AccountGroupException>()),
        );

        final overdrawn = await repository.createFinancialAccount(
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
        await repository.archiveFinancialAccount(overdrawn.id);
        expect(
          () => repository.recordArchivedAccountCloseoutTransfer(
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
      final savings = await repository.createFinancialAccount(
        name: 'Savings',
        type: AccountType.asset,
        groupId: groupCashEquivalentsId,
        openingBalanceMinor: 10000,
      );
      final other = await repository.createFinancialAccount(
        name: 'Other',
        type: AccountType.asset,
        groupId: groupCashEquivalentsId,
      );
      await repository.archiveFinancialAccount(savings.id);
      await repository.archiveFinancialAccount(other.id);

      expect(
        () => repository.recordArchivedAccountCloseoutTransfer(
          fromAccountId: savings.id,
          toAccountId: other.id,
          transactionDate: DateTime(2026, 1, 15),
        ),
        throwsA(isA<AccountGroupException>()),
      );
      expect(await repository.displayBalanceMinor(checkingId), equals(0));
    });

    test('is rejected when fromAccountId equals toAccountId', () async {
      final savings = await repository.createFinancialAccount(
        name: 'Savings',
        type: AccountType.asset,
        groupId: groupCashEquivalentsId,
        openingBalanceMinor: 10000,
      );
      await repository.archiveFinancialAccount(savings.id);

      expect(
        () => repository.recordArchivedAccountCloseoutTransfer(
          fromAccountId: savings.id,
          toAccountId: savings.id,
          transactionDate: DateTime(2026, 1, 15),
        ),
        throwsA(isA<InvalidTransferException>()),
      );
    });

    test('a second closeout after a successful first is rejected', () async {
      final checkingId = await firstFinancialAccountId();
      final savings = await repository.createFinancialAccount(
        name: 'Savings',
        type: AccountType.asset,
        groupId: groupCashEquivalentsId,
        openingBalanceMinor: 10000,
      );
      await repository.archiveFinancialAccount(savings.id);
      await repository.recordArchivedAccountCloseoutTransfer(
        fromAccountId: savings.id,
        toAccountId: checkingId,
        transactionDate: DateTime(2026, 1, 15),
      );

      expect(
        () => repository.recordArchivedAccountCloseoutTransfer(
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
        final savings = await repository.createFinancialAccount(
          name: 'Savings',
          type: AccountType.asset,
          groupId: groupCashEquivalentsId,
          openingBalanceMinor: 10000,
        );
        await repository.archiveFinancialAccount(savings.id);
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
        final savings = await repository.createFinancialAccount(
          name: 'Savings',
          type: AccountType.asset,
          groupId: groupCashEquivalentsId,
          openingBalanceMinor: 10000,
        );
        await repository.archiveFinancialAccount(savings.id);

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
        final savings = await repository.createFinancialAccount(
          name: 'Savings',
          type: AccountType.asset,
          groupId: groupCashEquivalentsId,
          openingBalanceMinor: 10000,
        );
        await repository.archiveFinancialAccount(savings.id);

        expect(
          () => repository.recordArchivedAccountCloseoutTransfer(
            fromAccountId: savings.id,
            toAccountId: euroId,
            transactionDate: DateTime(2026, 1, 15),
          ),
          throwsA(isA<InvalidTransferException>()),
        );
        expect(await repository.watchPendingTransfers().first, isEmpty);
        expect(await repository.displayBalanceMinor(savings.id), equals(10000));

        await repository.recordArchivedAccountCloseoutTransfer(
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
        await repository.createFinancialAccount(
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
        await repository.archiveFinancialAccount(euroId);

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
      final accounts = await repository
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
        await repository.verifyChain();

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
      await repository.changeAccountGroupCurrency(
        groupId: groupPensionRetirementId,
        currency: 'EUR',
      );

      expect(
        () => repository.reassignFinancialAccountGroup(
          id: checkingId,
          groupId: groupPensionRetirementId,
        ),
        throwsA(isA<AccountGroupException>()),
      );
    });

    test('reassigning within the same currency still works', () async {
      final checkingId = await firstFinancialAccountId();

      await repository.reassignFinancialAccountGroup(
        id: checkingId,
        groupId: groupPensionRetirementId,
      );

      final accounts = await repository
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
      return (await repository.createFinancialAccount(
        name: 'Brokerage',
        type: AccountType.asset,
        groupId: groupInvestmentsId,
        holdsInvestments: true,
      )).id;
    }

    Future<String> nonInvestmentCashAccountId() async {
      final accounts = await repository.watchFinancialAccounts().first;
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
      final instrument = await repository.createInstrument(
        name: 'Apple Inc',
        kind: InstrumentKind.stock,
      );
      await repository.recordBuy(
        accountId: accountId,
        instrumentId: instrument.id,
        quantityScaled: 10000,
        unitPriceMinor: 10000,
        transactionDate: DateTime(2026, 1, 2),
        fundingSource: BuyFundingSource.cash,
      );
      expect(await repository.displayBalanceMinor(accountId), equals(90000));
      final holdings = await repository.computeHoldingsForAccount(accountId);
      expect(holdings.length, equals(1));
      expect(holdings.first.quantityScaled, equals(10000));
      expect(holdings.first.totalCostMinor, equals(10000));
    });

    test('cash-funded buy rejected when cash insufficient', () async {
      final accountId = await createInvestmentAccount();
      final instrument = await repository.createInstrument(
        name: 'Tesla',
        kind: InstrumentKind.stock,
      );
      await expectLater(
        () => repository.recordBuy(
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
      final instrument = await repository.createInstrument(
        name: 'MSFT',
        kind: InstrumentKind.stock,
      );
      await repository.recordBuy(
        accountId: accountId,
        instrumentId: instrument.id,
        quantityScaled: 10000,
        unitPriceMinor: 10000,
        transactionDate: DateTime(2026, 1, 2),
        fundingSource: BuyFundingSource.cash,
      );
      final incomeId = await firstCategoryId(AccountType.income);
      await repository.recordSell(
        accountId: accountId,
        instrumentId: instrument.id,
        quantityScaled: 10000,
        unitPriceMinor: 12000,
        transactionDate: DateTime(2026, 2, 1),
        gainIncomeCategoryId: incomeId,
      );
      expect(await repository.displayBalanceMinor(accountId), equals(102000));
      final holdings = await repository.computeHoldingsForAccount(accountId);
      expect(holdings, isEmpty);
    });
  });
}
