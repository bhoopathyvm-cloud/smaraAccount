import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:smara_accounting/domain/exceptions.dart';
import 'package:smara_accounting/domain/models/account.dart';
import 'package:smara_accounting/domain/models/summary.dart';
import 'package:smara_accounting/ui/features/category_management/view_models/category_management_view_model.dart';

import '../../../../mocks.mocks.dart';

void main() {
  late MockLedgerRepository repository;

  const salary = Account(
    id: 'income-1',
    name: 'Salary',
    type: AccountType.income,
    archived: false,
  );

  setUp(() {
    repository = MockLedgerRepository();
    when(
      repository.watchCategories(includeArchived: anyNamed('includeArchived')),
    ).thenAnswer((_) => Stream.value([salary]));
  });

  test(
    'exposes categories from watchCategories(includeArchived: true)',
    () async {
      final viewModel = CategoryManagementViewModel(
        ledgerRepository: repository,
      );
      addTearDown(viewModel.dispose);
      // Stream.value(...) emits asynchronously (via a microtask), not
      // synchronously on listen - let it deliver before asserting.
      await Future<void>.delayed(Duration.zero);

      expect(viewModel.categories, equals([salary]));
      verify(repository.watchCategories(includeArchived: true)).called(1);
    },
  );

  test('addCategory delegates to the Repository', () async {
    when(
      repository.addCategory(name: anyNamed('name'), type: anyNamed('type')),
    ).thenAnswer((_) async {});
    final viewModel = CategoryManagementViewModel(ledgerRepository: repository);
    addTearDown(viewModel.dispose);

    await viewModel.addCategory(name: 'Freelance', type: AccountType.income);

    verify(
      repository.addCategory(name: 'Freelance', type: AccountType.income),
    ).called(1);
    expect(viewModel.errorMessage, isNull);
  });

  test('addCategory surfaces ArgumentError as errorMessage', () async {
    when(
      repository.addCategory(name: anyNamed('name'), type: anyNamed('type')),
    ).thenThrow(ArgumentError('must be income or expense'));
    final viewModel = CategoryManagementViewModel(ledgerRepository: repository);
    addTearDown(viewModel.dispose);

    await viewModel.addCategory(name: 'Nope', type: AccountType.asset);

    expect(viewModel.errorMessage, isNotNull);
  });

  test(
    'renameCategory and archiveCategory delegate to the Repository',
    () async {
      when(
        repository.renameCategory(
          id: anyNamed('id'),
          newName: anyNamed('newName'),
        ),
      ).thenAnswer((_) async {});
      when(repository.archiveCategory(any)).thenAnswer((_) async {});
      final viewModel = CategoryManagementViewModel(
        ledgerRepository: repository,
      );
      addTearDown(viewModel.dispose);

      await viewModel.renameCategory(id: 'income-1', newName: 'Freelance');
      await viewModel.archiveCategory('income-1');

      verify(
        repository.renameCategory(id: 'income-1', newName: 'Freelance'),
      ).called(1);
      verify(repository.archiveCategory('income-1')).called(1);
    },
  );

  group('monthly-category-limits', () {
    test('monthToDateSpentFor reads from watchCategoryTotals', () async {
      when(
        repository.watchCategoryTotals(
          start: anyNamed('start'),
          end: anyNamed('end'),
        ),
      ).thenAnswer(
        (_) => Stream.value(const [
          CategoryTotal(
            categoryId: 'expense-1',
            categoryName: 'Groceries',
            isIncome: false,
            totalMinor: 12000,
          ),
        ]),
      );

      final viewModel = CategoryManagementViewModel(
        ledgerRepository: repository,
      );
      addTearDown(viewModel.dispose);
      await Future<void>.delayed(Duration.zero);

      expect(viewModel.monthToDateSpentFor('expense-1'), equals(12000));
      expect(viewModel.monthToDateSpentFor('expense-2'), equals(0));
    });

    test(
      'setCategoryMonthlyLimit calls through and returns true on success',
      () async {
        when(
          repository.setCategoryMonthlyLimit(
            id: anyNamed('id'),
            monthlyLimitMinor: anyNamed('monthlyLimitMinor'),
          ),
        ).thenAnswer((_) async {});
        final viewModel = CategoryManagementViewModel(
          ledgerRepository: repository,
        );
        addTearDown(viewModel.dispose);

        final ok = await viewModel.setCategoryMonthlyLimit(
          id: 'expense-1',
          monthlyLimitMinor: 15000,
        );

        expect(ok, isTrue);
        expect(viewModel.errorMessage, isNull);
        verify(
          repository.setCategoryMonthlyLimit(
            id: 'expense-1',
            monthlyLimitMinor: 15000,
          ),
        ).called(1);
      },
    );

    test('setCategoryMonthlyLimit surfaces InvalidTransactionAmountException '
        'as errorMessage', () async {
      when(
        repository.setCategoryMonthlyLimit(
          id: anyNamed('id'),
          monthlyLimitMinor: anyNamed('monthlyLimitMinor'),
        ),
      ).thenThrow(InvalidTransactionAmountException('must be positive'));
      final viewModel = CategoryManagementViewModel(
        ledgerRepository: repository,
      );
      addTearDown(viewModel.dispose);

      final ok = await viewModel.setCategoryMonthlyLimit(
        id: 'expense-1',
        monthlyLimitMinor: 0,
      );

      expect(ok, isFalse);
      expect(viewModel.errorMessage, equals('Amount must be positive.'));
    });

    test('setCategoryMonthlyLimit surfaces ArgumentError with a plain-language '
        'message', () async {
      when(
        repository.setCategoryMonthlyLimit(
          id: anyNamed('id'),
          monthlyLimitMinor: anyNamed('monthlyLimitMinor'),
        ),
      ).thenThrow(ArgumentError('wrong type'));
      final viewModel = CategoryManagementViewModel(
        ledgerRepository: repository,
      );
      addTearDown(viewModel.dispose);

      final ok = await viewModel.setCategoryMonthlyLimit(
        id: 'income-1',
        monthlyLimitMinor: 15000,
      );

      expect(ok, isFalse);
      expect(viewModel.errorMessage, isNotNull);
    });
  });
}
