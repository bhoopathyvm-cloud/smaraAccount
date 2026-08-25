import 'package:drift/native.dart';
import 'package:smara_accounting/data/database/app_database.dart';
import 'package:smara_accounting/data/database/tables/account_groups_table.dart';
import 'package:smara_accounting/data/database/tables/accounts_table.dart';
import 'package:smara_accounting/data/repositories/account_repository.dart';
import 'package:smara_accounting/data/repositories/category_repository.dart';
import 'package:smara_accounting/data/repositories/investment_holdings_logic.dart';
import 'package:smara_accounting/data/repositories/ledger_repository.dart';
import 'package:smara_accounting/domain/crypto/signing_key_service.dart';
import 'package:smara_accounting/domain/exceptions.dart';
import 'package:smara_accounting/domain/models/instrument.dart';
import 'package:smara_accounting/domain/models/instrument_quote.dart';
import 'package:smara_accounting/domain/models/transaction_direction.dart';
import 'package:test/test.dart';

import '../../domain/crypto/in_memory_secure_key_storage.dart';

void main() {
  late AppDatabase db;
  late LedgerRepository repository;
  late AccountRepository accountRepository;
  late CategoryRepository categoryRepository;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = LedgerRepository(
      database: db,
      signingKeyService: SigningKeyService(
        secureStorage: InMemorySecureKeyStorage(),
      ),
    );
    accountRepository = AccountRepository(
      database: db,
      ledgerRepository: repository,
    );
    categoryRepository = CategoryRepository(database: db);
    final generated = await repository.generateFirstIdentity();
    await repository.confirmFirstIdentity(generated, currency: 'USD');
  });

  tearDown(() async {
    await db.close();
  });

  Future<String> cashAccountId() async {
    final accounts = await accountRepository.watchFinancialAccounts().first;
    return accounts.firstWhere((a) => !a.isInvestmentAccount).id;
  }

  Future<String> expenseId() async {
    final categories = await categoryRepository.watchCategories().first;
    return categories.firstWhere((a) => a.type == AccountType.expense).id;
  }

  Future<String> incomeId() async {
    final categories = await categoryRepository.watchCategories().first;
    return categories.firstWhere((a) => a.type == AccountType.income).id;
  }

  Future<String> createInvestmentAccount({String name = 'Brokerage'}) async {
    return (await accountRepository.createFinancialAccount(
      name: name,
      type: AccountType.asset,
      groupId: groupInvestmentsId,
      holdsInvestments: true,
    )).id;
  }

  Future<void> fund(String accountId, {int amountMinor = 1000000}) async {
    await repository.recordTransfer(
      fromAccountId: await cashAccountId(),
      toAccountId: accountId,
      amountMinor: amountMinor,
      transactionDate: DateTime(2026, 1, 1),
    );
  }

  group('cash in/out', () {
    test('transfer in increases cash and leaves inventory unchanged', () async {
      final accountId = await createInvestmentAccount();
      final instrument = await repository.createInstrument(
        name: 'Apple',
        kind: InstrumentKind.stock,
      );
      await fund(accountId, amountMinor: 50000);
      expect(await repository.displayBalanceMinor(accountId), equals(50000));
      expect(await repository.computeHoldingsForAccount(accountId), isEmpty);

      await repository.recordBuy(
        accountId: accountId,
        instrumentId: instrument.id,
        quantityScaled: 10000,
        unitPriceMinor: 10000,
        transactionDate: DateTime(2026, 1, 2),
        fundingSource: BuyFundingSource.cash,
      );
      final qtyAfterBuy = (await repository.computeHoldingsForAccount(
        accountId,
      )).first.quantityScaled;
      await repository.recordTransfer(
        fromAccountId: await cashAccountId(),
        toAccountId: accountId,
        amountMinor: 20000,
        transactionDate: DateTime(2026, 1, 3),
      );
      expect(await repository.displayBalanceMinor(accountId), equals(60000));
      expect(
        (await repository.computeHoldingsForAccount(
          accountId,
        )).first.quantityScaled,
        equals(qtyAfterBuy),
      );
    });

    test(
      'cash-out exceeding cash is rejected and inventory is unchanged',
      () async {
        final accountId = await createInvestmentAccount();
        await fund(accountId, amountMinor: 10000);
        final dest = await cashAccountId();
        await expectLater(
          () => repository.recordTransfer(
            fromAccountId: accountId,
            toAccountId: dest,
            amountMinor: 20000,
            transactionDate: DateTime(2026, 1, 2),
          ),
          throwsA(isA<InvalidTransferException>()),
        );
        expect(await repository.displayBalanceMinor(accountId), equals(10000));
      },
    );

    test(
      'ordinary expense against investment cash does not touch inventory',
      () async {
        final accountId = await createInvestmentAccount();
        await fund(accountId, amountMinor: 50000);
        final instrument = await repository.createInstrument(
          name: 'Apple',
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
        await repository.recordTransaction(
          amountMinor: 500,
          direction: TransactionDirection.moneyOut,
          categoryId: await expenseId(),
          financialAccountId: accountId,
          transactionDate: DateTime(2026, 1, 3),
        );
        expect(await repository.displayBalanceMinor(accountId), equals(39500));
        expect(
          (await repository.computeHoldingsForAccount(
            accountId,
          )).first.quantityScaled,
          equals(10000),
        );
      },
    );
  });

  group('buy', () {
    test('cash-funded buy with brokerage posts a second expense', () async {
      final accountId = await createInvestmentAccount();
      await fund(accountId, amountMinor: 200000);
      final instrument = await repository.createInstrument(
        name: 'Apple',
        kind: InstrumentKind.stock,
      );
      await repository.recordBuy(
        accountId: accountId,
        instrumentId: instrument.id,
        quantityScaled: 100000,
        unitPriceMinor: 10000,
        transactionDate: DateTime(2026, 1, 2),
        fundingSource: BuyFundingSource.cash,
        brokerageMinor: 500,
        brokerageExpenseCategoryId: await expenseId(),
      );
      // 10 units * 100.00 = 100000 + 500 brokerage
      expect(await repository.displayBalanceMinor(accountId), equals(99500));
      final holdings = await repository.computeHoldingsForAccount(accountId);
      expect(holdings.single.totalCostMinor, equals(100000));
    });

    test('zero-cash account rejects a cash-funded buy', () async {
      final accountId = await createInvestmentAccount();
      final instrument = await repository.createInstrument(
        name: 'Apple',
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

    test('non-cash acquisition posts income not cash', () async {
      final accountId = await createInvestmentAccount();
      await fund(accountId, amountMinor: 50000);
      final instrument = await repository.createInstrument(
        name: 'Employer stock',
        kind: InstrumentKind.stock,
      );
      await repository.recordBuy(
        accountId: accountId,
        instrumentId: instrument.id,
        quantityScaled: 10000,
        unitPriceMinor: 20000,
        transactionDate: DateTime(2026, 1, 2),
        fundingSource: BuyFundingSource.nonCash,
        incomeCategoryId: await incomeId(),
      );
      expect(await repository.displayBalanceMinor(accountId), equals(50000));
      final holdings = await repository.computeHoldingsForAccount(accountId);
      expect(holdings.single.quantityScaled, equals(10000));
      expect(holdings.single.totalCostMinor, equals(20000));
    });

    test('non-cash without income category is rejected', () async {
      final accountId = await createInvestmentAccount();
      final instrument = await repository.createInstrument(
        name: 'Gift',
        kind: InstrumentKind.stock,
      );
      await expectLater(
        () => repository.recordBuy(
          accountId: accountId,
          instrumentId: instrument.id,
          quantityScaled: 10000,
          unitPriceMinor: 10000,
          transactionDate: DateTime(2026, 1, 2),
          fundingSource: BuyFundingSource.nonCash,
        ),
        throwsA(isA<InvestmentException>()),
      );
    });

    test('buy 3 cash + 1 non-cash match tracks 4 units', () async {
      final accountId = await createInvestmentAccount();
      await fund(accountId, amountMinor: 400000);
      final instrument = await repository.createInstrument(
        name: 'ESPP',
        kind: InstrumentKind.stock,
      );
      await repository.recordBuy(
        accountId: accountId,
        instrumentId: instrument.id,
        quantityScaled: 30000,
        unitPriceMinor: 10000,
        transactionDate: DateTime(2026, 1, 2),
        fundingSource: BuyFundingSource.cash,
      );
      await repository.recordBuy(
        accountId: accountId,
        instrumentId: instrument.id,
        quantityScaled: 10000,
        unitPriceMinor: 10000,
        transactionDate: DateTime(2026, 1, 2),
        fundingSource: BuyFundingSource.nonCash,
        incomeCategoryId: await incomeId(),
        lockedUntil: DateTime(2027, 1, 2),
      );
      final holding = (await repository.computeHoldingsForAccount(
        accountId,
      )).single;
      expect(holding.quantityScaled, equals(40000));
      expect(holding.sellableQuantityScaled, equals(30000));
    });

    test('same instrument in two accounts tracks independently', () async {
      final a = await createInvestmentAccount(name: 'Broker A');
      final b = await createInvestmentAccount(name: 'Broker B');
      await fund(a, amountMinor: 100000);
      await fund(b, amountMinor: 100000);
      final instrument = await repository.createInstrument(
        name: 'Apple',
        kind: InstrumentKind.stock,
      );
      await repository.recordBuy(
        accountId: a,
        instrumentId: instrument.id,
        quantityScaled: 20000,
        unitPriceMinor: 10000,
        transactionDate: DateTime(2026, 1, 2),
        fundingSource: BuyFundingSource.cash,
      );
      await repository.recordBuy(
        accountId: b,
        instrumentId: instrument.id,
        quantityScaled: 10000,
        unitPriceMinor: 20000,
        transactionDate: DateTime(2026, 1, 2),
        fundingSource: BuyFundingSource.cash,
      );
      expect(
        (await repository.computeHoldingsForAccount(a)).single.quantityScaled,
        equals(20000),
      );
      expect(
        (await repository.computeHoldingsForAccount(b)).single.totalCostMinor,
        equals(20000),
      );
      await repository.renameInstrument(id: instrument.id, newName: 'AAPL Inc');
      expect(
        (await repository.computeHoldingsForAccount(a)).single.instrument.name,
        equals('AAPL Inc'),
      );
      expect(
        (await repository.computeHoldingsForAccount(b)).single.instrument.name,
        equals('AAPL Inc'),
      );
    });
  });

  group('lock-until', () {
    test('rejection message states the lock date', () async {
      final accountId = await createInvestmentAccount();
      await fund(accountId);
      final instrument = await repository.createInstrument(
        name: 'Vested',
        kind: InstrumentKind.stock,
      );
      await repository.recordBuy(
        accountId: accountId,
        instrumentId: instrument.id,
        quantityScaled: 10000,
        unitPriceMinor: 10000,
        transactionDate: DateTime(2026, 1, 2),
        fundingSource: BuyFundingSource.cash,
        lockedUntil: DateTime(2027, 6, 15),
      );
      final income = await incomeId();
      await expectLater(
        () => repository.recordSell(
          accountId: accountId,
          instrumentId: instrument.id,
          quantityScaled: 10000,
          unitPriceMinor: 12000,
          transactionDate: DateTime(2026, 2, 1),
          gainIncomeCategoryId: income,
        ),
        throwsA(
          isA<LockedQuantityException>().having(
            (e) => e.message,
            'message',
            contains('2027-06-15'),
          ),
        ),
      );
    });

    test('becomes sellable on the lock-until date', () async {
      final accountId = await createInvestmentAccount();
      await fund(accountId);
      final instrument = await repository.createInstrument(
        name: 'Vested',
        kind: InstrumentKind.stock,
      );
      await repository.recordBuy(
        accountId: accountId,
        instrumentId: instrument.id,
        quantityScaled: 10000,
        unitPriceMinor: 10000,
        transactionDate: DateTime(2026, 1, 2),
        fundingSource: BuyFundingSource.cash,
        lockedUntil: DateTime(2026, 6, 15),
      );
      await repository.recordSell(
        accountId: accountId,
        instrumentId: instrument.id,
        quantityScaled: 10000,
        unitPriceMinor: 12000,
        transactionDate: DateTime(2026, 6, 15),
        gainIncomeCategoryId: await incomeId(),
      );
      expect(await repository.computeHoldingsForAccount(accountId), isEmpty);
    });
  });

  group('dividend', () {
    test('increases cash, posts income, never changes inventory', () async {
      final accountId = await createInvestmentAccount();
      await fund(accountId, amountMinor: 50000);
      final instrument = await repository.createInstrument(
        name: 'Apple',
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
      await repository.recordDividend(
        accountId: accountId,
        instrumentId: instrument.id,
        amountMinor: 250,
        transactionDate: DateTime(2026, 3, 1),
        incomeCategoryId: await incomeId(),
      );
      expect(await repository.displayBalanceMinor(accountId), equals(40250));
      expect(
        (await repository.computeHoldingsForAccount(
          accountId,
        )).single.quantityScaled,
        equals(10000),
      );
    });

    test('posts for an instrument with zero current quantity', () async {
      final accountId = await createInvestmentAccount();
      await fund(accountId);
      final instrument = await repository.createInstrument(
        name: 'Apple',
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
      await repository.recordSell(
        accountId: accountId,
        instrumentId: instrument.id,
        quantityScaled: 10000,
        unitPriceMinor: 10000,
        transactionDate: DateTime(2026, 2, 1),
      );
      await repository.recordDividend(
        accountId: accountId,
        instrumentId: instrument.id,
        amountMinor: 100,
        transactionDate: DateTime(2026, 3, 1),
        incomeCategoryId: await incomeId(),
      );
      expect(await repository.computeHoldingsForAccount(accountId), isEmpty);
    });
  });

  group('sell', () {
    test('sell at a loss with brokerage', () async {
      final accountId = await createInvestmentAccount();
      await fund(accountId, amountMinor: 200000);
      final instrument = await repository.createInstrument(
        name: 'Loser',
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
      await repository.recordSell(
        accountId: accountId,
        instrumentId: instrument.id,
        quantityScaled: 10000,
        unitPriceMinor: 8000,
        transactionDate: DateTime(2026, 2, 1),
        lossExpenseCategoryId: await expenseId(),
        brokerageMinor: 100,
        brokerageExpenseCategoryId: await expenseId(),
      );
      expect(await repository.displayBalanceMinor(accountId), equals(197900));
    });

    test('over-sell and brokerage exceeding proceeds are rejected', () async {
      final accountId = await createInvestmentAccount();
      await fund(accountId);
      final instrument = await repository.createInstrument(
        name: 'Apple',
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
      final income = await incomeId();
      final expense = await expenseId();
      await expectLater(
        () => repository.recordSell(
          accountId: accountId,
          instrumentId: instrument.id,
          quantityScaled: 20000,
          unitPriceMinor: 12000,
          transactionDate: DateTime(2026, 2, 1),
          gainIncomeCategoryId: income,
        ),
        throwsA(isA<InsufficientQuantityException>()),
      );
      await expectLater(
        () => repository.recordSell(
          accountId: accountId,
          instrumentId: instrument.id,
          quantityScaled: 10000,
          unitPriceMinor: 50,
          transactionDate: DateTime(2026, 2, 1),
          brokerageMinor: 100,
          brokerageExpenseCategoryId: expense,
        ),
        throwsA(isA<InvestmentException>()),
      );
    });
  });

  group('backdated buy immutability', () {
    test(
      'already-posted sell gain is unchanged after a backdated buy',
      () async {
        final accountId = await createInvestmentAccount();
        await fund(accountId, amountMinor: 500000);
        final instrument = await repository.createInstrument(
          name: 'Apple',
          kind: InstrumentKind.stock,
        );
        await repository.recordBuy(
          accountId: accountId,
          instrumentId: instrument.id,
          quantityScaled: 10000,
          unitPriceMinor: 10000,
          transactionDate: DateTime(2026, 2, 1),
          fundingSource: BuyFundingSource.cash,
        );
        await repository.recordSell(
          accountId: accountId,
          instrumentId: instrument.id,
          quantityScaled: 10000,
          unitPriceMinor: 15000,
          transactionDate: DateTime(2026, 3, 1),
          gainIncomeCategoryId: await incomeId(),
        );
        final cashAfterSell = await repository.displayBalanceMinor(accountId);
        await repository.recordBuy(
          accountId: accountId,
          instrumentId: instrument.id,
          quantityScaled: 10000,
          unitPriceMinor: 5000,
          transactionDate: DateTime(2026, 1, 15),
          fundingSource: BuyFundingSource.cash,
        );
        // The posted sell still credited 15000 proceeds; cash change from
        // the backdated buy is only the new buy's cash outflow.
        expect(
          await repository.displayBalanceMinor(accountId),
          equals(cashAfterSell - 5000),
        );
      },
    );
  });

  group('reversal', () {
    test('reversing a buy with no later sell restores cash', () async {
      final accountId = await createInvestmentAccount();
      await fund(accountId, amountMinor: 50000);
      final instrument = await repository.createInstrument(
        name: 'Apple',
        kind: InstrumentKind.stock,
      );
      final buyId = await repository.recordBuy(
        accountId: accountId,
        instrumentId: instrument.id,
        quantityScaled: 10000,
        unitPriceMinor: 10000,
        transactionDate: DateTime(2026, 1, 2),
        fundingSource: BuyFundingSource.cash,
      );
      await repository.reverseEntry(buyId);
      expect(await repository.displayBalanceMinor(accountId), equals(50000));
      expect(await repository.computeHoldingsForAccount(accountId), isEmpty);
    });

    test('reversing a buy that a later sell relied on is rejected', () async {
      final accountId = await createInvestmentAccount();
      await fund(accountId);
      final instrument = await repository.createInstrument(
        name: 'Apple',
        kind: InstrumentKind.stock,
      );
      final buyId = await repository.recordBuy(
        accountId: accountId,
        instrumentId: instrument.id,
        quantityScaled: 10000,
        unitPriceMinor: 10000,
        transactionDate: DateTime(2026, 1, 2),
        fundingSource: BuyFundingSource.cash,
      );
      await repository.recordSell(
        accountId: accountId,
        instrumentId: instrument.id,
        quantityScaled: 10000,
        unitPriceMinor: 12000,
        transactionDate: DateTime(2026, 2, 1),
        gainIncomeCategoryId: await incomeId(),
      );
      await expectLater(
        () => repository.reverseEntry(buyId),
        throwsA(isA<InvestmentReversalBlockedException>()),
      );
    });

    test(
      'reversing a sell restores units and reversing a dividend does not',
      () async {
        final accountId = await createInvestmentAccount();
        await fund(accountId);
        final instrument = await repository.createInstrument(
          name: 'Apple',
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
        final sellId = await repository.recordSell(
          accountId: accountId,
          instrumentId: instrument.id,
          quantityScaled: 10000,
          unitPriceMinor: 12000,
          transactionDate: DateTime(2026, 2, 1),
          gainIncomeCategoryId: await incomeId(),
        );
        await repository.reverseEntry(sellId);
        expect(
          (await repository.computeHoldingsForAccount(
            accountId,
          )).single.quantityScaled,
          equals(10000),
        );
        final dividendId = await repository.recordDividend(
          accountId: accountId,
          instrumentId: instrument.id,
          amountMinor: 100,
          transactionDate: DateTime(2026, 3, 1),
          incomeCategoryId: await incomeId(),
        );
        await repository.reverseEntry(dividendId);
        expect(
          (await repository.computeHoldingsForAccount(
            accountId,
          )).single.quantityScaled,
          equals(10000),
        );
      },
    );
  });

  group('archive and closeout', () {
    test(
      'archive with cash, sell, and a second closeout all succeed',
      () async {
        final accountId = await createInvestmentAccount();
        await fund(accountId, amountMinor: 50000);
        final instrument = await repository.createInstrument(
          name: 'Apple',
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
        await accountRepository.archiveFinancialAccount(accountId);
        await expectLater(
          () => repository.recordBuy(
            accountId: accountId,
            instrumentId: instrument.id,
            quantityScaled: 10000,
            unitPriceMinor: 10000,
            transactionDate: DateTime(2026, 4, 1),
            fundingSource: BuyFundingSource.cash,
          ),
          throwsA(isA<AccountGroupException>()),
        );
        final dest = await cashAccountId();
        await accountRepository.recordArchivedAccountCloseoutTransfer(
          fromAccountId: accountId,
          toAccountId: dest,
          transactionDate: DateTime(2026, 4, 2),
        );
        expect(await repository.displayBalanceMinor(accountId), equals(0));
        await repository.recordSell(
          accountId: accountId,
          instrumentId: instrument.id,
          quantityScaled: 10000,
          unitPriceMinor: 12000,
          transactionDate: DateTime(2026, 4, 3),
          gainIncomeCategoryId: await incomeId(),
        );
        expect(await repository.displayBalanceMinor(accountId), greaterThan(0));
        await accountRepository.recordArchivedAccountCloseoutTransfer(
          fromAccountId: accountId,
          toAccountId: dest,
          transactionDate: DateTime(2026, 4, 4),
        );
        expect(await repository.displayBalanceMinor(accountId), equals(0));
        await repository.recordDividend(
          accountId: accountId,
          instrumentId: instrument.id,
          amountMinor: 50,
          transactionDate: DateTime(2026, 4, 5),
          incomeCategoryId: await incomeId(),
        );
      },
    );
  });

  group('quotes and unrealized', () {
    test('unrealized gain matches market minus book cost', () async {
      final accountId = await createInvestmentAccount();
      await fund(accountId);
      final instrument = await repository.createInstrument(
        name: 'Apple',
        kind: InstrumentKind.stock,
        ticker: 'AAPL',
      );
      await repository.recordBuy(
        accountId: accountId,
        instrumentId: instrument.id,
        quantityScaled: 10000,
        unitPriceMinor: 10000,
        transactionDate: DateTime(2026, 1, 2),
        fundingSource: BuyFundingSource.cash,
      );
      await repository.cacheInstrumentQuote(
        instrumentId: instrument.id,
        priceMinor: 12000,
        currency: 'USD',
      );
      final holding = (await repository.computeHoldingsForAccount(
        accountId,
      )).single;
      expect(holding.displayMarketValueMinor, equals(12000));
      expect(holding.displayUnrealizedMinor, equals(2000));
      expect(holding.quoteUse, equals(QuoteUse.live));
    });

    test('quote currency mismatch uses cost', () async {
      final accountId = await createInvestmentAccount();
      await fund(accountId);
      final instrument = await repository.createInstrument(
        name: 'Apple',
        kind: InstrumentKind.stock,
        ticker: 'AAPL',
      );
      await repository.recordBuy(
        accountId: accountId,
        instrumentId: instrument.id,
        quantityScaled: 10000,
        unitPriceMinor: 10000,
        transactionDate: DateTime(2026, 1, 2),
        fundingSource: BuyFundingSource.cash,
      );
      await repository.cacheInstrumentQuote(
        instrumentId: instrument.id,
        priceMinor: 12000,
        currency: 'EUR',
      );
      final holding = (await repository.computeHoldingsForAccount(
        accountId,
      )).single;
      expect(holding.displayMarketValueMinor, equals(10000));
      expect(holding.quoteUse, equals(QuoteUse.currencyMismatch));
    });

    test('home net position uses portfolio value', () async {
      final accountId = await createInvestmentAccount();
      await fund(accountId, amountMinor: 50000);
      final instrument = await repository.createInstrument(
        name: 'Apple',
        kind: InstrumentKind.stock,
        ticker: 'AAPL',
      );
      await repository.recordBuy(
        accountId: accountId,
        instrumentId: instrument.id,
        quantityScaled: 10000,
        unitPriceMinor: 10000,
        transactionDate: DateTime(2026, 1, 2),
        fundingSource: BuyFundingSource.cash,
      );
      await repository.cacheInstrumentQuote(
        instrumentId: instrument.id,
        priceMinor: 15000,
        currency: 'USD',
      );
      final overview = await repository.watchHomeOverview().first;
      final investment = overview.sections
          .expand((s) => s.accounts)
          .firstWhere((b) => b.account.id == accountId);
      // cash 40000 + market 15000
      expect(investment.displayBalanceMinor, equals(55000));
      expect(investment.isMarketEstimate, isTrue);
      expect(investment.bookValueMinor, equals(50000));
    });
  });
}
