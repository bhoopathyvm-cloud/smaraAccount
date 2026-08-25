import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:smara_accounting/domain/models/account.dart';
import 'package:smara_accounting/domain/models/home_overview.dart';
import 'package:smara_accounting/domain/models/recurring_template.dart';
import 'package:smara_accounting/domain/models/summary.dart';
import 'package:smara_accounting/domain/models/transaction_direction.dart';
import 'package:smara_accounting/ui/features/home/view_models/home_view_model.dart';

import '../../../../mocks.mocks.dart';

void main() {
  late MockLedgerRepository repository;
  late MockCategoryRepository categoryRepository;

  setUp(() {
    repository = MockLedgerRepository();
    categoryRepository = MockCategoryRepository();
    when(repository.watchHomeOverview()).thenAnswer(
      (_) => Stream.value(
        const HomeOverview(
          sections: [],
          netPositionsByCurrency: [],
          pendingTransfers: [],
        ),
      ),
    );
  });

  test('splits category totals into expense (Spent) and income (Received), '
      'each sorted highest total first', () async {
    when(
      categoryRepository.watchCategoryTotals(
        start: anyNamed('start'),
        end: anyNamed('end'),
      ),
    ).thenAnswer(
      (_) => Stream.value(const [
        CategoryTotal(
          categoryId: 'expense-1',
          categoryName: 'Groceries',
          isIncome: false,
          totalMinor: 5000,
        ),
        CategoryTotal(
          categoryId: 'expense-2',
          categoryName: 'Rent',
          isIncome: false,
          totalMinor: 150000,
        ),
        CategoryTotal(
          categoryId: 'income-1',
          categoryName: 'Salary',
          isIncome: true,
          totalMinor: 300000,
        ),
      ]),
    );

    final viewModel = HomeViewModel(
      ledgerRepository: repository,
      categoryRepository: categoryRepository,
    );
    addTearDown(viewModel.dispose);
    await Future<void>.delayed(Duration.zero);

    expect(
      viewModel.thisMonthExpenseTotals.map((t) => t.categoryName),
      equals(['Rent', 'Groceries']),
    );
    expect(
      viewModel.thisMonthIncomeTotals.map((t) => t.categoryName),
      equals(['Salary']),
    );
  });

  test('watchCategoryTotals is called with the current calendar month\'s '
      'first and last day', () async {
    DateTime? capturedStart;
    DateTime? capturedEnd;
    when(
      categoryRepository.watchCategoryTotals(
        start: anyNamed('start'),
        end: anyNamed('end'),
      ),
    ).thenAnswer((invocation) {
      capturedStart = invocation.namedArguments[#start] as DateTime;
      capturedEnd = invocation.namedArguments[#end] as DateTime;
      return Stream.value(const []);
    });

    final viewModel = HomeViewModel(
      ledgerRepository: repository,
      categoryRepository: categoryRepository,
    );
    addTearDown(viewModel.dispose);
    await Future<void>.delayed(Duration.zero);

    final now = DateTime.now();
    expect(capturedStart, equals(DateTime(now.year, now.month, 1)));
    expect(capturedEnd, equals(DateTime(now.year, now.month + 1, 0)));
  });

  test(
    'no categories with activity this month means both lists are empty',
    () async {
      when(
        categoryRepository.watchCategoryTotals(
          start: anyNamed('start'),
          end: anyNamed('end'),
        ),
      ).thenAnswer((_) => Stream.value(const []));

      final viewModel = HomeViewModel(
        ledgerRepository: repository,
        categoryRepository: categoryRepository,
      );
      addTearDown(viewModel.dispose);
      await Future<void>.delayed(Duration.zero);

      expect(viewModel.thisMonthExpenseTotals, isEmpty);
      expect(viewModel.thisMonthIncomeTotals, isEmpty);
    },
  );

  group('recurring-templates', () {
    const dueTemplate = RecurringTemplate(
      id: 'template-1',
      name: 'Rent',
      direction: TransactionDirection.moneyOut,
      financialAccountId: 'account-1',
      categoryId: 'category-1',
      amountMinor: 150000,
      dayOfMonth: 1,
    );
    const due = DueRecurringTemplate(
      template: dueTemplate,
      financialAccountName: 'Checking',
      categoryName: 'Rent/Mortgage',
      currency: 'USD',
    );

    test('exposes due templates from the repository', () async {
      when(
        categoryRepository.watchCategoryTotals(
          start: anyNamed('start'),
          end: anyNamed('end'),
        ),
      ).thenAnswer((_) => Stream.value(const []));
      when(
        repository.watchDueRecurringTemplates(),
      ).thenAnswer((_) => Stream.value(const [due]));

      final viewModel = HomeViewModel(
        ledgerRepository: repository,
        categoryRepository: categoryRepository,
      );
      addTearDown(viewModel.dispose);
      await Future<void>.delayed(Duration.zero);

      expect(viewModel.dueTemplates, hasLength(1));
      expect(viewModel.dueTemplates.single.template.name, equals('Rent'));
    });

    test('recordDueTemplate delegates to the Repository', () async {
      when(
        categoryRepository.watchCategoryTotals(
          start: anyNamed('start'),
          end: anyNamed('end'),
        ),
      ).thenAnswer((_) => Stream.value(const []));
      when(
        repository.watchDueRecurringTemplates(),
      ).thenAnswer((_) => Stream.value(const []));
      when(
        repository.recordDueTemplate('template-1'),
      ).thenAnswer((_) async => 'entry-1');

      final viewModel = HomeViewModel(
        ledgerRepository: repository,
        categoryRepository: categoryRepository,
      );
      addTearDown(viewModel.dispose);

      await viewModel.recordDueTemplate('template-1');

      verify(repository.recordDueTemplate('template-1')).called(1);
    });
  });

  group('monthly-category-limits', () {
    test('monthlyLimitFor reads a limited Expense category\'s limit', () async {
      when(
        categoryRepository.watchCategoryTotals(
          start: anyNamed('start'),
          end: anyNamed('end'),
        ),
      ).thenAnswer((_) => Stream.value(const []));
      when(categoryRepository.watchCategories()).thenAnswer(
        (_) => Stream.value(const [
          Account(
            id: 'expense-1',
            name: 'Groceries',
            type: AccountType.expense,
            archived: false,
            monthlyLimitMinor: 15000,
          ),
          Account(
            id: 'expense-2',
            name: 'Transport',
            type: AccountType.expense,
            archived: false,
          ),
        ]),
      );

      final viewModel = HomeViewModel(
        ledgerRepository: repository,
        categoryRepository: categoryRepository,
      );
      addTearDown(viewModel.dispose);
      await Future<void>.delayed(Duration.zero);

      expect(viewModel.monthlyLimitFor('expense-1'), equals(15000));
      expect(viewModel.monthlyLimitFor('expense-2'), isNull);
    });
  });
}
