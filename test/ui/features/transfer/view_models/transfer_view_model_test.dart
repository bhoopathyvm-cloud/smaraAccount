import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:smara_accounting/domain/exceptions.dart';
import 'package:smara_accounting/domain/models/account.dart';
import 'package:smara_accounting/domain/models/account_group.dart';
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
  const usdGroup = AccountGroup(
    id: 'group-usd',
    name: 'Cash & cash equivalents',
    kind: AccountGroupKind.assetGroup,
    sortOrder: 0,
    isSystem: true,
    currency: 'USD',
    archived: false,
  );
  const eurGroup = AccountGroup(
    id: 'group-eur',
    name: 'Pension & retirement',
    kind: AccountGroupKind.assetGroup,
    sortOrder: 1,
    isSystem: true,
    currency: 'EUR',
    archived: false,
  );

  TransferViewModel buildViewModel() {
    return TransferViewModel(
      ledgerRepository: repository,
      exchangeRateService: exchangeRateService,
      settingsRepository: settingsRepository,
    );
  }

  setUp(() {
    repository = MockLedgerRepository();
    when(
      repository.watchFinancialAccounts(
        includeArchived: anyNamed('includeArchived'),
      ),
    ).thenAnswer((_) => Stream.value([checking, savings]));
    when(
      repository.watchAccountGroups(
        includeArchived: anyNamed('includeArchived'),
      ),
    ).thenAnswer((_) => Stream.value([usdGroup]));
    when(
      repository.watchCategories(),
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
        repository.watchFinancialAccounts(
          includeArchived: anyNamed('includeArchived'),
        ),
      ).thenAnswer((_) => Stream.value([checking, savings, eurSavings]));
      when(
        repository.watchAccountGroups(
          includeArchived: anyNamed('includeArchived'),
        ),
      ).thenAnswer((_) => Stream.value([usdGroup, eurGroup]));
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
        repository.watchFinancialAccounts(
          includeArchived: anyNamed('includeArchived'),
        ),
      ).thenAnswer((_) => Stream.value([checking, savings, eurSavings]));
      when(
        repository.watchAccountGroups(
          includeArchived: anyNamed('includeArchived'),
        ),
      ).thenAnswer((_) => Stream.value([usdGroup, eurGroup]));
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
}
