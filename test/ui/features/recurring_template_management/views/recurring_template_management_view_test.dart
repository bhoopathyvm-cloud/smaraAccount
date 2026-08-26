import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:smara_accounting/domain/models/account.dart';
import 'package:smara_accounting/domain/models/account_currency_catalog.dart';
import 'package:smara_accounting/domain/models/recurring_template.dart';
import 'package:smara_accounting/domain/models/transaction_direction.dart';
import 'package:smara_accounting/ui/features/recurring_template_management/view_models/recurring_template_management_view_model.dart';
import 'package:smara_accounting/ui/features/recurring_template_management/views/recurring_template_management_view.dart';

import '../../../../mocks.mocks.dart';

void main() {
  late MockRecurringTemplateRepository repository;
  late MockAccountRepository accountRepository;
  late MockCategoryRepository categoryRepository;

  const checking = Account(
    id: 'account-1',
    name: 'Checking',
    type: AccountType.asset,
    archived: false,
    groupId: 'group-1',
  );
  const currencies = AccountCurrencyCatalog({'account-1': 'USD'});
  const groceries = Account(
    id: 'expense-1',
    name: 'Groceries',
    type: AccountType.expense,
    archived: false,
  );
  const rentTemplate = RecurringTemplate(
    id: 'template-1',
    name: 'Rent',
    direction: TransactionDirection.moneyOut,
    financialAccountId: 'account-1',
    categoryId: 'expense-1',
    amountMinor: 150000,
    dayOfMonth: 1,
  );

  setUp(() {
    repository = MockRecurringTemplateRepository();
    accountRepository = MockAccountRepository();
    categoryRepository = MockCategoryRepository();
    when(
      accountRepository.watchFinancialAccounts(),
    ).thenAnswer((_) => Stream.value(const [checking]));
    when(
      accountRepository.watchAccountCurrencies(
        includeArchived: anyNamed('includeArchived'),
      ),
    ).thenAnswer((_) => Stream.value(currencies));
    when(
      categoryRepository.watchCategories(),
    ).thenAnswer((_) => Stream.value(const [groceries]));
  });

  testWidgets('lists every template with its schedule and amount', (
    tester,
  ) async {
    when(
      repository.watchRecurringTemplates(),
    ).thenAnswer((_) => Stream.value(const [rentTemplate]));

    final viewModel = RecurringTemplateManagementViewModel(
      recurringTemplateRepository: repository,
      accountRepository: accountRepository,
      categoryRepository: categoryRepository,
    );
    addTearDown(viewModel.dispose);

    await tester.pumpWidget(
      MaterialApp(home: RecurringTemplateManagementView(viewModel: viewModel)),
    );
    await tester.pump();

    expect(find.text('Rent'), findsOneWidget);
    expect(find.textContaining('Day 1 of the month'), findsOneWidget);
    expect(find.textContaining('1,500.00 USD'), findsOneWidget);
  });

  testWidgets('adding a template fills in every field and calls through', (
    tester,
  ) async {
    when(
      repository.watchRecurringTemplates(),
    ).thenAnswer((_) => Stream.value(const []));
    when(
      repository.createRecurringTemplate(
        name: anyNamed('name'),
        direction: anyNamed('direction'),
        financialAccountId: anyNamed('financialAccountId'),
        categoryId: anyNamed('categoryId'),
        amountMinor: anyNamed('amountMinor'),
        dayOfMonth: anyNamed('dayOfMonth'),
      ),
    ).thenAnswer((_) async => rentTemplate);

    final viewModel = RecurringTemplateManagementViewModel(
      recurringTemplateRepository: repository,
      accountRepository: accountRepository,
      categoryRepository: categoryRepository,
    );
    addTearDown(viewModel.dispose);

    await tester.pumpWidget(
      MaterialApp(home: RecurringTemplateManagementView(viewModel: viewModel)),
    );
    await tester.pump();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextField, 'Name'), 'Rent');
    // Account defaults to the only one available; category needs picking.
    await tester.tap(
      find.widgetWithText(DropdownButtonFormField<String>, 'Category'),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Groceries').last);
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextField, 'Amount'), '1500.00');
    await tester.enterText(
      find.widgetWithText(TextField, 'Day of month (1-31)'),
      '1',
    );

    await tester.tap(find.widgetWithText(ElevatedButton, 'Add'));
    await tester.pumpAndSettle();

    verify(
      repository.createRecurringTemplate(
        name: 'Rent',
        direction: TransactionDirection.moneyOut,
        financialAccountId: 'account-1',
        categoryId: 'expense-1',
        amountMinor: 150000,
        dayOfMonth: 1,
      ),
    ).called(1);
  });

  testWidgets(
    'deleting a template confirms first, then calls through to the repository',
    (tester) async {
      when(
        repository.watchRecurringTemplates(),
      ).thenAnswer((_) => Stream.value(const [rentTemplate]));
      when(
        repository.deleteRecurringTemplate('template-1'),
      ).thenAnswer((_) async {});

      final viewModel = RecurringTemplateManagementViewModel(
        recurringTemplateRepository: repository,
        accountRepository: accountRepository,
        categoryRepository: categoryRepository,
      );
      addTearDown(viewModel.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: RecurringTemplateManagementView(viewModel: viewModel),
        ),
      );
      await tester.pump();

      await tester.tap(find.byType(IconButton).last);
      await tester.pumpAndSettle();

      expect(find.text('Delete recurring template?'), findsOneWidget);
      await tester.tap(find.widgetWithText(OutlinedButton, 'Delete'));
      await tester.pumpAndSettle();

      verify(repository.deleteRecurringTemplate('template-1')).called(1);
    },
  );
}
