import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:smara_accounting/domain/exceptions.dart';
import 'package:smara_accounting/domain/models/account.dart';
import 'package:smara_accounting/domain/models/transaction_direction.dart';
import 'package:smara_accounting/ui/features/correction_wizard/view_models/correction_view_model.dart';

import '../../../../mocks.mocks.dart';

void main() {
  late MockLedgerRepository repository;

  const asset = Account(
    id: 'asset-1',
    name: 'Cash & Bank',
    type: AccountType.asset,
    archived: false,
  );
  const groceries = Account(
    id: 'expense-groceries',
    name: 'Groceries',
    type: AccountType.expense,
    archived: false,
  );
  const salary = Account(
    id: 'income-salary',
    name: 'Salary',
    type: AccountType.income,
    archived: false,
  );

  CorrectionViewModel buildViewModel() {
    when(
      repository.watchFinancialAccounts(),
    ).thenAnswer((_) => Stream.value([asset]));
    when(
      repository.watchCategories(),
    ).thenAnswer((_) => Stream.value([groceries, salary]));
    return CorrectionViewModel(
      ledgerRepository: repository,
      entryId: 'entry-1',
      initialAmountMinor: 4500,
      initialDirection: TransactionDirection.moneyOut,
      initialCategoryId: groceries.id,
      initialFinancialAccountId: asset.id,
      initialTransactionDate: DateTime(2026, 1, 17),
      initialDescription: 'Corner store',
    );
  }

  setUp(() {
    repository = MockLedgerRepository();
  });

  test('prefills every field from the original entry', () {
    final viewModel = buildViewModel();
    addTearDown(viewModel.dispose);

    expect(viewModel.amountMinor, equals(4500));
    expect(viewModel.direction, equals(TransactionDirection.moneyOut));
    expect(viewModel.categoryId, equals(groceries.id));
    expect(viewModel.financialAccountId, equals(asset.id));
    expect(viewModel.transactionDate, equals(DateTime(2026, 1, 17)));
    expect(viewModel.description, equals('Corner store'));
  });

  test('changing direction clears the now-mismatched category', () {
    final viewModel = buildViewModel();
    addTearDown(viewModel.dispose);

    viewModel.setDirection(TransactionDirection.moneyIn);

    expect(viewModel.categoryId, isNull);
  });

  test(
    'fix() posts reversal and replacement through one repository call',
    () async {
      final viewModel = buildViewModel();
      addTearDown(viewModel.dispose);

      when(
        repository.fixPostedTransaction(
          entryId: anyNamed('entryId'),
          amountMinor: anyNamed('amountMinor'),
          direction: anyNamed('direction'),
          categoryId: anyNamed('categoryId'),
          financialAccountId: anyNamed('financialAccountId'),
          transactionDate: anyNamed('transactionDate'),
          description: anyNamed('description'),
        ),
      ).thenAnswer((_) async => 'entry-2');

      viewModel.setAmountMinor(5000);
      final ok = await viewModel.fix();

      expect(ok, isTrue);
      expect(viewModel.isSubmitting, isFalse);
      verify(
        repository.fixPostedTransaction(
          entryId: 'entry-1',
          amountMinor: 5000,
          direction: TransactionDirection.moneyOut,
          categoryId: groceries.id,
          financialAccountId: asset.id,
          transactionDate: DateTime(2026, 1, 17),
          description: 'Corner store',
        ),
      ).called(1);
    },
  );

  test(
    'fix() surfaces a domain exception without throwing, and unsticks submit',
    () async {
      final viewModel = buildViewModel();
      addTearDown(viewModel.dispose);

      when(
        repository.fixPostedTransaction(
          entryId: anyNamed('entryId'),
          amountMinor: anyNamed('amountMinor'),
          direction: anyNamed('direction'),
          categoryId: anyNamed('categoryId'),
          financialAccountId: anyNamed('financialAccountId'),
          transactionDate: anyNamed('transactionDate'),
          description: anyNamed('description'),
        ),
      ).thenThrow(
        InvalidTransactionAmountException('Amount must be positive.'),
      );

      final ok = await viewModel.fix();

      expect(ok, isFalse);
      expect(viewModel.isSubmitting, isFalse);
      expect(viewModel.errorMessage, equals('Amount must be positive.'));
    },
  );

  test('fix() surfaces AlreadyReversedException and unsticks submit', () async {
    final viewModel = buildViewModel();
    addTearDown(viewModel.dispose);

    when(
      repository.fixPostedTransaction(
        entryId: anyNamed('entryId'),
        amountMinor: anyNamed('amountMinor'),
        direction: anyNamed('direction'),
        categoryId: anyNamed('categoryId'),
        financialAccountId: anyNamed('financialAccountId'),
        transactionDate: anyNamed('transactionDate'),
        description: anyNamed('description'),
      ),
    ).thenThrow(
      AlreadyReversedException('This entry has already been corrected.'),
    );

    final ok = await viewModel.fix();

    expect(ok, isFalse);
    expect(viewModel.isSubmitting, isFalse);
    expect(
      viewModel.errorMessage,
      equals('This entry has already been corrected.'),
    );
  });
}
