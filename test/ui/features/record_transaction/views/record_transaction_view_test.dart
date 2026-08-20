import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:smara_accounting/domain/models/account.dart';
import 'package:smara_accounting/domain/models/payee.dart';
import 'package:smara_accounting/domain/models/transaction_direction.dart';
import 'package:smara_accounting/ui/features/record_transaction/view_models/record_transaction_view_model.dart';
import 'package:smara_accounting/ui/features/record_transaction/views/record_transaction_view.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../mocks.mocks.dart';

// Mocks the Repository rather than using a real Drift database: see
// register_view_test.dart's file comment for why testWidgets + real
// native DB I/O hangs indefinitely instead of settling.
void main() {
  testWidgets('archived category does not appear in the category picker', (
    tester,
  ) async {
    // "Salary" was archived - watchCategories() (default: active only)
    // no longer includes it, matching what LedgerRepository.watchCategories
    // actually does after archiveCategory() (verified in
    // ledger_repository_test.dart's "archived category is excluded"
    // test).
    final repository = MockLedgerRepository();
    when(
      repository.watchCategories(includeArchived: anyNamed('includeArchived')),
    ).thenAnswer(
      (_) => Stream.value([
        const Account(
          id: 'income-2',
          name: 'Other Income',
          type: AccountType.income,
          archived: false,
        ),
      ]),
    );

    final viewModel = RecordTransactionViewModel(ledgerRepository: repository);
    addTearDown(viewModel.dispose);

    await tester.pumpWidget(
      MaterialApp(home: RecordTransactionView(viewModel: viewModel)),
    );
    await tester.pump();

    // Two dropdowns now exist (Account, then Category) - the category
    // picker is the last one.
    await tester.tap(find.byType(DropdownButtonFormField<String>).last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Salary'), findsNothing);
    expect(find.text('Other Income'), findsWidgets);
  });

  testWidgets('typing a payee name offers a suggestion; selecting it fills the '
      'description field and applies its default category', (tester) async {
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
    when(repository.watchPayees()).thenAnswer(
      (_) => Stream.value(const [
        Payee(id: 'payee-1', name: 'Starbucks', defaultCategoryId: 'income-1'),
      ]),
    );

    final viewModel = RecordTransactionViewModel(ledgerRepository: repository);
    addTearDown(viewModel.dispose);

    await tester.pumpWidget(
      MaterialApp(home: RecordTransactionView(viewModel: viewModel)),
    );
    await tester.pump();

    await tester.enterText(
      find.widgetWithText(TextField, 'Description (optional)'),
      'star',
    );
    await tester.pumpAndSettle();

    expect(find.text('Starbucks'), findsOneWidget);
    await tester.tap(find.text('Starbucks'));
    await tester.pumpAndSettle();

    expect(viewModel.description, equals('Starbucks'));
    expect(viewModel.categoryId, equals('income-1'));
  });

  group('split-transactions', () {
    MockLedgerRepository repositoryWithTwoExpenseCategories() {
      final repository = MockLedgerRepository();
      when(repository.watchFinancialAccounts()).thenAnswer(
        (_) => Stream.value(const [
          Account(
            id: 'account-1',
            name: 'Checking',
            type: AccountType.asset,
            archived: false,
          ),
        ]),
      );
      when(
        repository.watchCategories(
          includeArchived: anyNamed('includeArchived'),
        ),
      ).thenAnswer(
        (_) => Stream.value(const [
          Account(
            id: 'expense-1',
            name: 'Groceries',
            type: AccountType.expense,
            archived: false,
          ),
          Account(
            id: 'expense-2',
            name: 'Household',
            type: AccountType.expense,
            archived: false,
          ),
        ]),
      );
      return repository;
    }

    testWidgets('tapping "Split into multiple categories" replaces the single '
        'category picker with two category lines', (tester) async {
      final repository = repositoryWithTwoExpenseCategories();
      final viewModel = RecordTransactionViewModel(
        ledgerRepository: repository,
        initialDirection: TransactionDirection.moneyOut,
      );
      addTearDown(viewModel.dispose);

      await tester.pumpWidget(
        MaterialApp(home: RecordTransactionView(viewModel: viewModel)),
      );
      await tester.pump();

      expect(find.text('Category'), findsOneWidget);
      expect(find.text('Split into multiple categories'), findsOneWidget);

      await tester.tap(find.text('Split into multiple categories'));
      await tester.pump();

      expect(find.text('Category'), findsNothing);
      expect(find.text('Category 1'), findsOneWidget);
      expect(find.text('Category 2'), findsOneWidget);
    });

    testWidgets('the remainder updates as line amounts are entered; Save is '
        'disabled until it reaches zero, then posts a split', (tester) async {
      final repository = repositoryWithTwoExpenseCategories();
      when(
        repository.recordSplitTransaction(
          totalAmountMinor: anyNamed('totalAmountMinor'),
          splitLines: anyNamed('splitLines'),
          direction: anyNamed('direction'),
          financialAccountId: anyNamed('financialAccountId'),
          transactionDate: anyNamed('transactionDate'),
          description: anyNamed('description'),
        ),
      ).thenAnswer((_) async => 'entry-1');

      final viewModel = RecordTransactionViewModel(
        ledgerRepository: repository,
        initialDirection: TransactionDirection.moneyOut,
      );
      addTearDown(viewModel.dispose);
      var saved = false;

      await tester.pumpWidget(
        MaterialApp(
          home: RecordTransactionView(
            viewModel: viewModel,
            onSaved: () => saved = true,
          ),
        ),
      );
      await tester.pump();

      await tester.enterText(
        find.widgetWithText(TextField, 'Amount').first,
        '100.00',
      );
      await tester.tap(find.text('Split into multiple categories'));
      await tester.pump();

      final categoryPickers = find.byType(DropdownButtonFormField<String>);
      // Account picker, then Category 1, then Category 2.
      await tester.tap(categoryPickers.at(1));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Groceries').last);
      await tester.pumpAndSettle();
      await tester.tap(categoryPickers.at(2));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Household').last);
      await tester.pumpAndSettle();

      // The total "Amount" field is also labeled "Amount", so it's
      // index 0; the two split-line amount fields are indices 1 and 2.
      final amountFields = find.widgetWithText(TextField, 'Amount');
      await tester.enterText(amountFields.at(1), '60.00');
      await tester.pump();

      expect(find.textContaining('Remaining: 40.00'), findsOneWidget);
      expect(
        tester
            .widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Save'))
            .onPressed,
        isNull,
      );

      await tester.enterText(amountFields.at(2), '40.00');
      await tester.pump();

      expect(find.textContaining('Remaining: 0.00'), findsOneWidget);
      final saveButton = find.widgetWithText(ElevatedButton, 'Save');
      await tester.ensureVisible(saveButton);
      await tester.pump();
      await tester.tap(saveButton);
      await tester.pump();

      expect(saved, isTrue);
      verify(
        repository.recordSplitTransaction(
          totalAmountMinor: 10000,
          splitLines: [
            (categoryId: 'expense-1', amountMinor: 6000),
            (categoryId: 'expense-2', amountMinor: 4000),
          ],
          direction: TransactionDirection.moneyOut,
          financialAccountId: 'account-1',
          transactionDate: anyNamed('transactionDate'),
          description: null,
        ),
      ).called(1);
    });

    testWidgets(
      'removing a line down to one collapses back to the single category picker',
      (tester) async {
        final repository = repositoryWithTwoExpenseCategories();
        final viewModel = RecordTransactionViewModel(
          ledgerRepository: repository,
          initialDirection: TransactionDirection.moneyOut,
        );
        addTearDown(viewModel.dispose);

        await tester.pumpWidget(
          MaterialApp(home: RecordTransactionView(viewModel: viewModel)),
        );
        await tester.pump();

        await tester.tap(find.text('Split into multiple categories'));
        await tester.pump();
        expect(find.text('Category 2'), findsOneWidget);

        await tester.tap(find.byIcon(TablerIcons.trash).last);
        await tester.pump();

        expect(find.text('Category'), findsOneWidget);
        expect(find.text('Category 1'), findsNothing);
      },
    );
  });

  group('credit-card-household-flow', () {
    const checking = Account(
      id: 'account-1',
      name: 'Checking',
      type: AccountType.asset,
      archived: false,
    );
    const visaCard = Account(
      id: 'account-2',
      name: 'Visa',
      type: AccountType.liability,
      archived: false,
      isCreditCard: true,
    );

    testWidgets(
      'the shortcuts appear only for Spent with a card-flagged account, '
      'and narrow the Account picker',
      (tester) async {
        final repository = MockLedgerRepository();
        when(
          repository.watchFinancialAccounts(),
        ).thenAnswer((_) => Stream.value(const [checking, visaCard]));

        final viewModel = RecordTransactionViewModel(
          ledgerRepository: repository,
          initialDirection: TransactionDirection.moneyOut,
        );
        addTearDown(viewModel.dispose);

        await tester.pumpWidget(
          MaterialApp(home: RecordTransactionView(viewModel: viewModel)),
        );
        await tester.pump();

        expect(find.text('Paid from card'), findsOneWidget);
        expect(find.text('Paid from bank'), findsOneWidget);

        await tester.tap(find.text('Paid from card'));
        await tester.pump();

        expect(viewModel.financialAccountId, equals('account-2'));

        // Switching to Received hides the shortcuts entirely.
        await tester.tap(find.text('Received'));
        await tester.pump();

        expect(find.text('Paid from card'), findsNothing);
      },
    );

    testWidgets('no shortcuts when no account is flagged as a card', (
      tester,
    ) async {
      final repository = MockLedgerRepository();
      when(
        repository.watchFinancialAccounts(),
      ).thenAnswer((_) => Stream.value(const [checking]));

      final viewModel = RecordTransactionViewModel(
        ledgerRepository: repository,
        initialDirection: TransactionDirection.moneyOut,
      );
      addTearDown(viewModel.dispose);

      await tester.pumpWidget(
        MaterialApp(home: RecordTransactionView(viewModel: viewModel)),
      );
      await tester.pump();

      expect(find.text('Paid from card'), findsNothing);
    });
  });
}
