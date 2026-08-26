import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:smara_accounting/domain/exceptions.dart';
import 'package:smara_accounting/domain/models/account.dart';
import 'package:smara_accounting/domain/models/account_currency_catalog.dart';
import 'package:smara_accounting/domain/models/exchange_rate_provider.dart';
import 'package:smara_accounting/domain/models/transaction_direction.dart';
import 'package:smara_accounting/ui/features/transfer/view_models/transfer_view_model.dart';

import '../../../../mocks.mocks.dart';

// Plain unit tests against the ViewModel (no widgets needed): the fee
// orchestration in submit() - validate, recordTransfer, then recordTransaction
// - is pure ViewModel logic, distinct from the rendering covered by
// transfer_view_test.dart.
void main() {
  late MockLedgerRepository repository;
  late MockAccountRepository accountRepository;
  late MockCategoryRepository categoryRepository;
  late MockExchangeRateService exchangeRateService;
  late MockSettingsRepository settingsRepository;

  const checking = Account(
    id: 'asset-1',
    name: 'Checking',
    type: AccountType.asset,
    archived: false,
    groupId: 'group-usd',
  );
  const savings = Account(
    id: 'asset-2',
    name: 'Savings',
    type: AccountType.asset,
    archived: false,
    groupId: 'group-usd',
  );
  const bankFees = Account(
    id: 'expense-1',
    name: 'Bank Fees',
    type: AccountType.expense,
    archived: false,
  );
  const eurSavings = Account(
    id: 'asset-3',
    name: 'Euro Savings',
    type: AccountType.asset,
    archived: false,
    groupId: 'group-eur',
  );
  const jpySavings = Account(
    id: 'asset-4',
    name: 'Yen Savings',
    type: AccountType.asset,
    archived: false,
    groupId: 'group-jpy',
  );

  const usdCatalog = AccountCurrencyCatalog({
    'asset-1': 'USD',
    'asset-2': 'USD',
  });
  const usdEurCatalog = AccountCurrencyCatalog({
    'asset-1': 'USD',
    'asset-2': 'USD',
    'asset-3': 'EUR',
  });
  const usdJpyCatalog = AccountCurrencyCatalog({
    'asset-1': 'USD',
    'asset-2': 'USD',
    'asset-4': 'JPY',
  });

  TransferViewModel buildViewModel() {
    return TransferViewModel(
      ledgerRepository: repository,
      accountRepository: accountRepository,
      categoryRepository: categoryRepository,
      exchangeRateService: exchangeRateService,
      settingsRepository: settingsRepository,
    );
  }

  setUp(() {
    repository = MockLedgerRepository();
    accountRepository = MockAccountRepository();
    categoryRepository = MockCategoryRepository();
    when(
      accountRepository.watchFinancialAccounts(
        includeArchived: anyNamed('includeArchived'),
      ),
    ).thenAnswer((_) => Stream.value([checking, savings]));
    when(
      accountRepository.watchAccountCurrencies(
        includeArchived: anyNamed('includeArchived'),
      ),
    ).thenAnswer((_) => Stream.value(usdCatalog));
    when(
      categoryRepository.watchCategories(),
    ).thenAnswer((_) => Stream.value([bankFees]));

    exchangeRateService = MockExchangeRateService();
    settingsRepository = MockSettingsRepository();
    when(
      settingsRepository.isReferenceRateLookupEnabled(),
    ).thenAnswer((_) async => false);
    when(
      settingsRepository.selectedProvider(),
    ).thenAnswer((_) async => ExchangeRateProvider.values.first);
  });

  test(
    'submit with a valid fee calls recordTransfer then recordTransaction with the expected amounts/category',
    () async {
      when(
        repository.recordTransfer(
          fromAccountId: anyNamed('fromAccountId'),
          toAccountId: anyNamed('toAccountId'),
          amountMinor: anyNamed('amountMinor'),
          transactionDate: anyNamed('transactionDate'),
          description: anyNamed('description'),
          destinationAmountMinor: anyNamed('destinationAmountMinor'),
        ),
      ).thenAnswer((_) async {});
      when(
        repository.recordTransaction(
          amountMinor: anyNamed('amountMinor'),
          direction: anyNamed('direction'),
          categoryId: anyNamed('categoryId'),
          financialAccountId: anyNamed('financialAccountId'),
          transactionDate: anyNamed('transactionDate'),
          description: anyNamed('description'),
        ),
      ).thenAnswer((_) async => 'entry-fee');

      final viewModel = buildViewModel();
      addTearDown(viewModel.dispose);
      await Future<void>.delayed(Duration.zero);

      viewModel.setAmountMinor(10000);
      viewModel.setFeeAmountMinor(500);
      viewModel.setFeeCategoryId('expense-1');

      final result = await viewModel.submit();

      expect(result, isTrue);
      verifyInOrder([
        repository.recordTransfer(
          fromAccountId: 'asset-1',
          toAccountId: 'asset-2',
          amountMinor: 10000,
          transactionDate: anyNamed('transactionDate'),
          description: anyNamed('description'),
          destinationAmountMinor: null,
        ),
        repository.recordTransaction(
          amountMinor: 500,
          direction: TransactionDirection.moneyOut,
          categoryId: 'expense-1',
          financialAccountId: 'asset-1',
          transactionDate: anyNamed('transactionDate'),
          description: anyNamed('description'),
        ),
      ]);
    },
  );

  test('submit without a fee calls only recordTransfer', () async {
    when(
      repository.recordTransfer(
        fromAccountId: anyNamed('fromAccountId'),
        toAccountId: anyNamed('toAccountId'),
        amountMinor: anyNamed('amountMinor'),
        transactionDate: anyNamed('transactionDate'),
        description: anyNamed('description'),
        destinationAmountMinor: anyNamed('destinationAmountMinor'),
      ),
    ).thenAnswer((_) async {});

    final viewModel = buildViewModel();
    addTearDown(viewModel.dispose);
    await Future<void>.delayed(Duration.zero);

    viewModel.setAmountMinor(10000);

    final result = await viewModel.submit();

    expect(result, isTrue);
    verify(
      repository.recordTransfer(
        fromAccountId: 'asset-1',
        toAccountId: 'asset-2',
        amountMinor: 10000,
        transactionDate: anyNamed('transactionDate'),
        description: anyNamed('description'),
        destinationAmountMinor: null,
      ),
    ).called(1);
    verifyNever(
      repository.recordTransaction(
        amountMinor: anyNamed('amountMinor'),
        direction: anyNamed('direction'),
        categoryId: anyNamed('categoryId'),
        financialAccountId: anyNamed('financialAccountId'),
        transactionDate: anyNamed('transactionDate'),
        description: anyNamed('description'),
      ),
    );
  });

  test(
    'a fee missing its category does not call recordTransfer or recordTransaction',
    () async {
      final viewModel = buildViewModel();
      addTearDown(viewModel.dispose);
      await Future<void>.delayed(Duration.zero);

      viewModel.setAmountMinor(10000);
      viewModel.setFeeAmountMinor(500);
      // No fee category selected.

      final result = await viewModel.submit();

      expect(result, isFalse);
      expect(viewModel.errorMessage, isNotNull);
      verifyNever(
        repository.recordTransfer(
          fromAccountId: anyNamed('fromAccountId'),
          toAccountId: anyNamed('toAccountId'),
          amountMinor: anyNamed('amountMinor'),
          transactionDate: anyNamed('transactionDate'),
          description: anyNamed('description'),
          destinationAmountMinor: anyNamed('destinationAmountMinor'),
        ),
      );
      verifyNever(
        repository.recordTransaction(
          amountMinor: anyNamed('amountMinor'),
          direction: anyNamed('direction'),
          categoryId: anyNamed('categoryId'),
          financialAccountId: anyNamed('financialAccountId'),
          transactionDate: anyNamed('transactionDate'),
          description: anyNamed('description'),
        ),
      );
    },
  );

  test(
    'a non-positive fee amount does not call recordTransfer or recordTransaction',
    () async {
      final viewModel = buildViewModel();
      addTearDown(viewModel.dispose);
      await Future<void>.delayed(Duration.zero);

      viewModel.setAmountMinor(10000);
      viewModel.setFeeAmountMinor(0);
      viewModel.setFeeCategoryId('expense-1');

      final result = await viewModel.submit();

      expect(result, isFalse);
      expect(viewModel.errorMessage, isNotNull);
      verifyNever(
        repository.recordTransfer(
          fromAccountId: anyNamed('fromAccountId'),
          toAccountId: anyNamed('toAccountId'),
          amountMinor: anyNamed('amountMinor'),
          transactionDate: anyNamed('transactionDate'),
          description: anyNamed('description'),
          destinationAmountMinor: anyNamed('destinationAmountMinor'),
        ),
      );
      verifyNever(
        repository.recordTransaction(
          amountMinor: anyNamed('amountMinor'),
          direction: anyNamed('direction'),
          categoryId: anyNamed('categoryId'),
          financialAccountId: anyNamed('financialAccountId'),
          transactionDate: anyNamed('transactionDate'),
          description: anyNamed('description'),
        ),
      );
    },
  );

  test(
    'when recordTransfer succeeds and recordTransaction fails, the error indicates the transfer was saved and the fee failed',
    () async {
      when(
        repository.recordTransfer(
          fromAccountId: anyNamed('fromAccountId'),
          toAccountId: anyNamed('toAccountId'),
          amountMinor: anyNamed('amountMinor'),
          transactionDate: anyNamed('transactionDate'),
          description: anyNamed('description'),
          destinationAmountMinor: anyNamed('destinationAmountMinor'),
        ),
      ).thenAnswer((_) async {});
      when(
        repository.recordTransaction(
          amountMinor: anyNamed('amountMinor'),
          direction: anyNamed('direction'),
          categoryId: anyNamed('categoryId'),
          financialAccountId: anyNamed('financialAccountId'),
          transactionDate: anyNamed('transactionDate'),
          description: anyNamed('description'),
        ),
      ).thenThrow(InvalidTransactionAmountException('amount must be positive'));

      final viewModel = buildViewModel();
      addTearDown(viewModel.dispose);
      await Future<void>.delayed(Duration.zero);

      viewModel.setAmountMinor(10000);
      viewModel.setFeeAmountMinor(500);
      viewModel.setFeeCategoryId('expense-1');

      final result = await viewModel.submit();

      expect(result, isFalse);
      verify(
        repository.recordTransfer(
          fromAccountId: anyNamed('fromAccountId'),
          toAccountId: anyNamed('toAccountId'),
          amountMinor: anyNamed('amountMinor'),
          transactionDate: anyNamed('transactionDate'),
          description: anyNamed('description'),
          destinationAmountMinor: anyNamed('destinationAmountMinor'),
        ),
      ).called(1);
      expect(viewModel.errorMessage, contains('Transfer saved'));
      expect(viewModel.errorMessage, contains('fee'));
    },
  );

  test(
    'when the reference-rate lookup setting is disabled, fetchRate is never called for a cross-currency pair',
    () async {
      when(
        accountRepository.watchFinancialAccounts(
          includeArchived: anyNamed('includeArchived'),
        ),
      ).thenAnswer((_) => Stream.value([checking, savings, eurSavings]));
      when(
        accountRepository.watchAccountCurrencies(
          includeArchived: anyNamed('includeArchived'),
        ),
      ).thenAnswer((_) => Stream.value(usdEurCatalog));
      // isReferenceRateLookupEnabled already stubbed to false in setUp.

      final viewModel = buildViewModel();
      addTearDown(viewModel.dispose);
      await Future<void>.delayed(Duration.zero);

      viewModel.setFromAccountId('asset-1');
      viewModel.setToAccountId('asset-3');
      await Future<void>.delayed(Duration.zero);

      expect(viewModel.isCrossCurrency, isTrue);
      expect(viewModel.referenceRate, isNull);
      verifyZeroInteractions(exchangeRateService);
    },
  );

  test(
    'deducted-fee mode posts recordTransfer for amount minus fee, and recordTransaction for the entered fee',
    () async {
      when(
        repository.recordTransfer(
          fromAccountId: anyNamed('fromAccountId'),
          toAccountId: anyNamed('toAccountId'),
          amountMinor: anyNamed('amountMinor'),
          transactionDate: anyNamed('transactionDate'),
          description: anyNamed('description'),
          destinationAmountMinor: anyNamed('destinationAmountMinor'),
        ),
      ).thenAnswer((_) async {});
      when(
        repository.recordTransaction(
          amountMinor: anyNamed('amountMinor'),
          direction: anyNamed('direction'),
          categoryId: anyNamed('categoryId'),
          financialAccountId: anyNamed('financialAccountId'),
          transactionDate: anyNamed('transactionDate'),
          description: anyNamed('description'),
        ),
      ).thenAnswer((_) async => 'entry-fee');

      final viewModel = buildViewModel();
      addTearDown(viewModel.dispose);
      await Future<void>.delayed(Duration.zero);

      // 100.00 sent, 1.62 fee, deducted: the transfer itself should move
      // 98.38, but the total debited (98.38 + 1.62) still equals 100.00.
      viewModel.setAmountMinor(10000);
      viewModel.setFeeAmountMinor(162);
      viewModel.setFeeCategoryId('expense-1');
      viewModel.setFeeDeductedFromAmount(true);

      final result = await viewModel.submit();

      expect(result, isTrue);
      verify(
        repository.recordTransfer(
          fromAccountId: 'asset-1',
          toAccountId: 'asset-2',
          amountMinor: 9838,
          transactionDate: anyNamed('transactionDate'),
          description: anyNamed('description'),
          destinationAmountMinor: null,
        ),
      ).called(1);
      verify(
        repository.recordTransaction(
          amountMinor: 162,
          direction: TransactionDirection.moneyOut,
          categoryId: 'expense-1',
          financialAccountId: 'asset-1',
          transactionDate: anyNamed('transactionDate'),
          description: anyNamed('description'),
        ),
      ).called(1);
    },
  );

  test(
    'deducted-fee mode reduces the source-side amount but leaves a known destination amount untouched',
    () async {
      when(
        accountRepository.watchFinancialAccounts(
          includeArchived: anyNamed('includeArchived'),
        ),
      ).thenAnswer((_) => Stream.value([checking, savings, eurSavings]));
      when(
        accountRepository.watchAccountCurrencies(
          includeArchived: anyNamed('includeArchived'),
        ),
      ).thenAnswer((_) => Stream.value(usdEurCatalog));
      when(
        repository.recordTransfer(
          fromAccountId: anyNamed('fromAccountId'),
          toAccountId: anyNamed('toAccountId'),
          amountMinor: anyNamed('amountMinor'),
          transactionDate: anyNamed('transactionDate'),
          description: anyNamed('description'),
          destinationAmountMinor: anyNamed('destinationAmountMinor'),
        ),
      ).thenAnswer((_) async {});
      when(
        repository.recordTransaction(
          amountMinor: anyNamed('amountMinor'),
          direction: anyNamed('direction'),
          categoryId: anyNamed('categoryId'),
          financialAccountId: anyNamed('financialAccountId'),
          transactionDate: anyNamed('transactionDate'),
          description: anyNamed('description'),
        ),
      ).thenAnswer((_) async => 'entry-fee');

      final viewModel = buildViewModel();
      addTearDown(viewModel.dispose);
      await Future<void>.delayed(Duration.zero);

      viewModel.setFromAccountId('asset-1');
      viewModel.setToAccountId('asset-3');
      viewModel.setAmountMinor(10000);
      viewModel.setDestinationAmountMinor(9114);
      viewModel.setFeeAmountMinor(162);
      viewModel.setFeeCategoryId('expense-1');
      viewModel.setFeeDeductedFromAmount(true);

      final result = await viewModel.submit();

      expect(result, isTrue);
      verify(
        repository.recordTransfer(
          fromAccountId: 'asset-1',
          toAccountId: 'asset-3',
          amountMinor: 9838,
          transactionDate: anyNamed('transactionDate'),
          description: anyNamed('description'),
          destinationAmountMinor: 9114,
        ),
      ).called(1);
    },
  );

  test(
    'deducted-fee mode rejects a fee greater than or equal to the amount before any repository call',
    () async {
      final viewModel = buildViewModel();
      addTearDown(viewModel.dispose);
      await Future<void>.delayed(Duration.zero);

      viewModel.setAmountMinor(10000);
      viewModel.setFeeAmountMinor(10000);
      viewModel.setFeeCategoryId('expense-1');
      viewModel.setFeeDeductedFromAmount(true);

      final result = await viewModel.submit();

      expect(result, isFalse);
      expect(viewModel.errorMessage, contains('fee'));
      verifyNever(
        repository.recordTransfer(
          fromAccountId: anyNamed('fromAccountId'),
          toAccountId: anyNamed('toAccountId'),
          amountMinor: anyNamed('amountMinor'),
          transactionDate: anyNamed('transactionDate'),
          description: anyNamed('description'),
          destinationAmountMinor: anyNamed('destinationAmountMinor'),
        ),
      );
      verifyNever(
        repository.recordTransaction(
          amountMinor: anyNamed('amountMinor'),
          direction: anyNamed('direction'),
          categoryId: anyNamed('categoryId'),
          financialAccountId: anyNamed('financialAccountId'),
          transactionDate: anyNamed('transactionDate'),
          description: anyNamed('description'),
        ),
      );
    },
  );

  group('impliedRate', () {
    Future<TransferViewModel> buildCrossCurrencyViewModel() async {
      when(
        accountRepository.watchFinancialAccounts(
          includeArchived: anyNamed('includeArchived'),
        ),
      ).thenAnswer((_) => Stream.value([checking, savings, eurSavings]));
      when(
        accountRepository.watchAccountCurrencies(
          includeArchived: anyNamed('includeArchived'),
        ),
      ).thenAnswer((_) => Stream.value(usdEurCatalog));

      final viewModel = buildViewModel();
      await Future<void>.delayed(Duration.zero);
      viewModel.setFromAccountId('asset-1');
      viewModel.setToAccountId('asset-3');
      return viewModel;
    }

    test(
      'with no fee, is the destination amount divided by the full amount',
      () async {
        final viewModel = await buildCrossCurrencyViewModel();
        addTearDown(viewModel.dispose);

        viewModel.setAmountMinor(10000);
        viewModel.setDestinationAmountMinor(9114);

        expect(viewModel.impliedRate, closeTo(0.9114, 1e-9));
      },
    );

    test('with a fee that is charged on top of the amount (not deducted), '
        'is unaffected by the fee', () async {
      final viewModel = await buildCrossCurrencyViewModel();
      addTearDown(viewModel.dispose);

      viewModel.setAmountMinor(10000);
      viewModel.setDestinationAmountMinor(9114);
      viewModel.setFeeAmountMinor(162);
      viewModel.setFeeCategoryId('expense-1');
      // feeDeductedFromAmount left at its default of false.

      expect(viewModel.impliedRate, closeTo(0.9114, 1e-9));
    });

    test(
      'with a deducted fee, is the destination amount divided by the '
      'amount actually converted (amount minus fee), not the full amount',
      () async {
        final viewModel = await buildCrossCurrencyViewModel();
        addTearDown(viewModel.dispose);

        // 100.00 sent, 1.62 fee carved out before conversion, 91.14
        // received: the user's real rate is 91.14 / 98.38, not 91.14 / 100.
        viewModel.setAmountMinor(10000);
        viewModel.setDestinationAmountMinor(9114);
        viewModel.setFeeAmountMinor(162);
        viewModel.setFeeCategoryId('expense-1');
        viewModel.setFeeDeductedFromAmount(true);

        expect(viewModel.impliedRate, closeTo(9114 / 9838, 1e-9));
        expect(viewModel.impliedRate, isNot(closeTo(0.9114, 1e-9)));
      },
    );

    test('with a deducted fee greater than or equal to the amount, is null '
        'rather than dividing by zero or a negative amount', () async {
      final viewModel = await buildCrossCurrencyViewModel();
      addTearDown(viewModel.dispose);

      viewModel.setAmountMinor(10000);
      viewModel.setDestinationAmountMinor(9114);
      viewModel.setFeeAmountMinor(10000);
      viewModel.setFeeCategoryId('expense-1');
      viewModel.setFeeDeductedFromAmount(true);

      expect(viewModel.impliedRate, isNull);
    });

    test('converts each side to its own major units first, so a pair with '
        'different minor-unit digit counts (USD, 2 decimals; JPY, 0) still '
        'computes the true rate, not the raw minor-unit ratio', () async {
      when(
        accountRepository.watchFinancialAccounts(
          includeArchived: anyNamed('includeArchived'),
        ),
      ).thenAnswer((_) => Stream.value([checking, savings, jpySavings]));
      when(
        accountRepository.watchAccountCurrencies(
          includeArchived: anyNamed('includeArchived'),
        ),
      ).thenAnswer((_) => Stream.value(usdJpyCatalog));

      final viewModel = buildViewModel();
      addTearDown(viewModel.dispose);
      await Future<void>.delayed(Duration.zero);
      viewModel.setFromAccountId('asset-1');
      viewModel.setToAccountId('asset-4');

      // $100.00 sent (10000 minor units, 2 decimals), ¥15,000 received
      // (15000 minor units, 0 decimals - JPY's minor unit IS its major
      // unit). True rate: 15000 JPY / 100 USD = 150. The raw minor-unit
      // ratio (15000 / 10000 = 1.5) would be wrong by a factor of 100.
      viewModel.setAmountMinor(10000);
      viewModel.setDestinationAmountMinor(15000);

      expect(viewModel.impliedRate, closeTo(150.0, 1e-9));
    });
  });

  group(
    'credit-card-household-flow: initialToAccountId ("Pay card" pre-fill)',
    () {
      const visaCard = Account(
        id: 'liability-1',
        name: 'Visa',
        type: AccountType.liability,
        archived: false,
        groupId: 'group-usd',
        isCreditCard: true,
      );

      test('pre-selects the requested card as the destination', () async {
        when(
          accountRepository.watchFinancialAccounts(
            includeArchived: anyNamed('includeArchived'),
          ),
        ).thenAnswer((_) => Stream.value([checking, savings, visaCard]));

        final viewModel = TransferViewModel(
          ledgerRepository: repository,
          accountRepository: accountRepository,
          categoryRepository: categoryRepository,
          exchangeRateService: exchangeRateService,
          settingsRepository: settingsRepository,
          initialToAccountId: 'liability-1',
        );
        addTearDown(viewModel.dispose);
        await Future<void>.delayed(Duration.zero);

        expect(viewModel.toAccountId, equals('liability-1'));
        // The source is still whatever the ordinary default logic
        // picks - "Pay card" only pre-fills the destination.
        expect(viewModel.fromAccountId, isNot(equals('liability-1')));
      });

      test('falls back to the ordinary first-other-account default when the '
          'requested card no longer exists', () async {
        when(
          accountRepository.watchFinancialAccounts(
            includeArchived: anyNamed('includeArchived'),
          ),
        ).thenAnswer((_) => Stream.value([checking, savings]));

        final viewModel = TransferViewModel(
          ledgerRepository: repository,
          accountRepository: accountRepository,
          categoryRepository: categoryRepository,
          exchangeRateService: exchangeRateService,
          settingsRepository: settingsRepository,
          initialToAccountId: 'no-such-account',
        );
        addTearDown(viewModel.dispose);
        await Future<void>.delayed(Duration.zero);

        expect(viewModel.toAccountId, equals('asset-2'));
      });
    },
  );
}
