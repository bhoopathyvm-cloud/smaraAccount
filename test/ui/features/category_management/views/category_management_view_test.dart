import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:smara_accounting/domain/models/account.dart';
import 'package:smara_accounting/domain/models/summary.dart';
import 'package:smara_accounting/ui/features/category_management/view_models/category_management_view_model.dart';
import 'package:smara_accounting/ui/features/category_management/views/category_management_view.dart';

import '../../../../mocks.mocks.dart';

// Mocks the Repository rather than using a real Drift database: see
// register_view_test.dart's file comment for why testWidgets + real
// native DB I/O hangs indefinitely instead of settling.
void main() {
  testWidgets(
    'archived categories stay visible without rename/archive actions',
    (tester) async {
      final repository = MockLedgerRepository();
      when(
        repository.watchCategories(
          includeArchived: anyNamed('includeArchived'),
        ),
      ).thenAnswer(
        (_) => Stream.value(const [
          Account(
            id: 'income-1',
            name: 'Salary',
            type: AccountType.income,
            archived: false,
          ),
          Account(
            id: 'income-2',
            name: 'Other Income',
            type: AccountType.income,
            archived: true,
          ),
        ]),
      );

      final viewModel = CategoryManagementViewModel(
        ledgerRepository: repository,
      );
      addTearDown(viewModel.dispose);

      await tester.pumpWidget(
        MaterialApp(home: CategoryManagementView(viewModel: viewModel)),
      );
      await tester.pump();

      expect(find.text('Salary'), findsOneWidget);
      expect(find.text('Other Income'), findsOneWidget);
      expect(
        find.descendant(
          of: find.widgetWithText(Card, 'Salary'),
          matching: find.text('Hide'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.widgetWithText(Card, 'Other Income'),
          matching: find.text('Hide'),
        ),
        findsNothing,
      );
    },
  );

  testWidgets('cancelling the archive confirmation does not archive', (
    tester,
  ) async {
    final repository = MockLedgerRepository();
    when(
      repository.watchCategories(includeArchived: anyNamed('includeArchived')),
    ).thenAnswer(
      (_) => Stream.value(const [
        Account(
          id: 'income-1',
          name: 'Salary',
          type: AccountType.income,
          archived: false,
        ),
      ]),
    );

    final viewModel = CategoryManagementViewModel(ledgerRepository: repository);
    addTearDown(viewModel.dispose);

    await tester.pumpWidget(
      MaterialApp(home: CategoryManagementView(viewModel: viewModel)),
    );
    await tester.pump();

    await tester.tap(find.widgetWithText(OutlinedButton, 'Hide'));
    await tester.pumpAndSettle();

    expect(find.text('Hide category from new entries?'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    verifyNever(repository.archiveCategory(any));
  });

  testWidgets('confirming the archive confirmation archives the category', (
    tester,
  ) async {
    final repository = MockLedgerRepository();
    when(
      repository.watchCategories(includeArchived: anyNamed('includeArchived')),
    ).thenAnswer(
      (_) => Stream.value(const [
        Account(
          id: 'income-1',
          name: 'Salary',
          type: AccountType.income,
          archived: false,
        ),
      ]),
    );
    when(repository.archiveCategory('income-1')).thenAnswer((_) async {});

    final viewModel = CategoryManagementViewModel(ledgerRepository: repository);
    addTearDown(viewModel.dispose);

    await tester.pumpWidget(
      MaterialApp(home: CategoryManagementView(viewModel: viewModel)),
    );
    await tester.pump();

    await tester.tap(find.widgetWithText(OutlinedButton, 'Hide'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(OutlinedButton, 'Hide').last);
    await tester.pumpAndSettle();

    verify(repository.archiveCategory('income-1')).called(1);
  });

  group('monthly-category-limits', () {
    const groceriesWithLimit = Account(
      id: 'expense-1',
      name: 'Groceries',
      type: AccountType.expense,
      archived: false,
      monthlyLimitMinor: 15000,
    );
    const groceries = Account(
      id: 'expense-1',
      name: 'Groceries',
      type: AccountType.expense,
      archived: false,
    );

    testWidgets(
      'a limited category shows month-to-date progress; an unlimited one '
      'shows none',
      (tester) async {
        final repository = MockLedgerRepository();
        when(
          repository.watchCategories(
            includeArchived: anyNamed('includeArchived'),
          ),
        ).thenAnswer(
          (_) => Stream.value(const [
            groceriesWithLimit,
            Account(
              id: 'expense-2',
              name: 'Transport',
              type: AccountType.expense,
              archived: false,
            ),
          ]),
        );
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

        await tester.pumpWidget(
          MaterialApp(home: CategoryManagementView(viewModel: viewModel)),
        );
        await tester.pump();

        expect(find.textContaining('120.00 of 150.00'), findsOneWidget);
        expect(find.text('Over limit'), findsNothing);
      },
    );

    testWidgets('spending past the limit shows a calm over-limit indication', (
      tester,
    ) async {
      final repository = MockLedgerRepository();
      when(
        repository.watchCategories(
          includeArchived: anyNamed('includeArchived'),
        ),
      ).thenAnswer((_) => Stream.value(const [groceriesWithLimit]));
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
            totalMinor: 20000,
          ),
        ]),
      );

      final viewModel = CategoryManagementViewModel(
        ledgerRepository: repository,
      );
      addTearDown(viewModel.dispose);

      await tester.pumpWidget(
        MaterialApp(home: CategoryManagementView(viewModel: viewModel)),
      );
      await tester.pump();

      expect(find.text('Over limit'), findsOneWidget);
    });

    testWidgets(
      'setting a limit through the dialog calls through to the repository',
      (tester) async {
        final repository = MockLedgerRepository();
        when(
          repository.watchCategories(
            includeArchived: anyNamed('includeArchived'),
          ),
        ).thenAnswer((_) => Stream.value(const [groceries]));
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

        await tester.pumpWidget(
          MaterialApp(home: CategoryManagementView(viewModel: viewModel)),
        );
        await tester.pump();

        await tester.tap(find.byTooltip('Monthly limit'));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField), '150.00');
        await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
        await tester.pumpAndSettle();

        verify(
          repository.setCategoryMonthlyLimit(
            id: 'expense-1',
            monthlyLimitMinor: 15000,
          ),
        ).called(1);
      },
    );

    testWidgets('an Income category is never offered the limit action', (
      tester,
    ) async {
      final repository = MockLedgerRepository();
      when(
        repository.watchCategories(
          includeArchived: anyNamed('includeArchived'),
        ),
      ).thenAnswer(
        (_) => Stream.value(const [
          Account(
            id: 'income-1',
            name: 'Salary',
            type: AccountType.income,
            archived: false,
          ),
        ]),
      );

      final viewModel = CategoryManagementViewModel(
        ledgerRepository: repository,
      );
      addTearDown(viewModel.dispose);

      await tester.pumpWidget(
        MaterialApp(home: CategoryManagementView(viewModel: viewModel)),
      );
      await tester.pump();

      expect(find.byTooltip('Monthly limit'), findsNothing);
    });
  });

  group('unarchive-accounts-categories', () {
    testWidgets(
      'an archived category shows Restore, which calls through to the '
      'repository',
      (tester) async {
        final repository = MockLedgerRepository();
        when(
          repository.watchCategories(
            includeArchived: anyNamed('includeArchived'),
          ),
        ).thenAnswer(
          (_) => Stream.value(const [
            Account(
              id: 'income-2',
              name: 'Other Income',
              type: AccountType.income,
              archived: true,
            ),
          ]),
        );
        when(repository.unarchiveCategory('income-2')).thenAnswer((_) async {});

        final viewModel = CategoryManagementViewModel(
          ledgerRepository: repository,
        );
        addTearDown(viewModel.dispose);

        await tester.pumpWidget(
          MaterialApp(home: CategoryManagementView(viewModel: viewModel)),
        );
        await tester.pump();

        expect(find.text('Restore'), findsOneWidget);
        await tester.tap(find.text('Restore'));
        await tester.pump();

        verify(repository.unarchiveCategory('income-2')).called(1);
      },
    );
  });
}
