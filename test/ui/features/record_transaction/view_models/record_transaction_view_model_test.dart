import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:smara_accounting/domain/exceptions.dart';
import 'package:smara_accounting/domain/models/transaction_direction.dart';
import 'package:smara_accounting/ui/features/record_transaction/view_models/record_transaction_view_model.dart';

import '../../../../mocks.mocks.dart';

void main() {
  late MockLedgerRepository repository;
  late RecordTransactionViewModel viewModel;

  setUp(() {
    repository = MockLedgerRepository();
    viewModel = RecordTransactionViewModel(ledgerRepository: repository);
  });

  test('setters update exposed state', () {
    viewModel.setAmountMinor(500);
    viewModel.setDirection(TransactionDirection.moneyOut);
    viewModel.setCategoryId('cat-1');
    viewModel.setDescription('lunch');
    final date = DateTime(2026, 3, 1);
    viewModel.setTransactionDate(date);

    expect(viewModel.amountMinor, equals(500));
    expect(viewModel.direction, equals(TransactionDirection.moneyOut));
    expect(viewModel.categoryId, equals('cat-1'));
    expect(viewModel.description, equals('lunch'));
    expect(viewModel.transactionDate, equals(date));
  });

  test(
    'submit fails with an errorMessage when amount or category missing',
    () async {
      viewModel.setCategoryId(null);
      viewModel.setAmountMinor(null);

      final result = await viewModel.submit();

      expect(result, isFalse);
      expect(viewModel.errorMessage, isNotNull);
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

  test('submit calls recordTransaction and returns true on success', () async {
    viewModel.setAmountMinor(1000);
    viewModel.setCategoryId('cat-1');
    viewModel.setFinancialAccountId('account-1');
    when(
      repository.recordTransaction(
        amountMinor: anyNamed('amountMinor'),
        direction: anyNamed('direction'),
        categoryId: anyNamed('categoryId'),
        financialAccountId: anyNamed('financialAccountId'),
        transactionDate: anyNamed('transactionDate'),
        description: anyNamed('description'),
      ),
    ).thenAnswer((_) async {});

    final result = await viewModel.submit();

    expect(result, isTrue);
    expect(viewModel.errorMessage, isNull);
    expect(viewModel.isSubmitting, isFalse);
  });

  test(
    'submit surfaces InvalidTransactionAmountException as errorMessage, never rethrows',
    () async {
      viewModel.setAmountMinor(0);
      viewModel.setCategoryId('cat-1');
      viewModel.setFinancialAccountId('account-1');
      when(
        repository.recordTransaction(
          amountMinor: anyNamed('amountMinor'),
          direction: anyNamed('direction'),
          categoryId: anyNamed('categoryId'),
          financialAccountId: anyNamed('financialAccountId'),
          transactionDate: anyNamed('transactionDate'),
          description: anyNamed('description'),
        ),
      ).thenThrow(InvalidTransactionAmountException('must be positive'));

      final result = await viewModel.submit();

      expect(result, isFalse);
      expect(viewModel.errorMessage, equals('must be positive'));
    },
  );
}
