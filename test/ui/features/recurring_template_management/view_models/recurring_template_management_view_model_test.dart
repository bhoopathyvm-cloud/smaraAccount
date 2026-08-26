import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:smara_accounting/domain/exceptions.dart';
import 'package:smara_accounting/domain/models/account.dart';
import 'package:smara_accounting/domain/models/account_currency_catalog.dart';
import 'package:smara_accounting/domain/models/recurring_template.dart';
import 'package:smara_accounting/domain/models/transaction_direction.dart';
import 'package:smara_accounting/ui/features/recurring_template_management/view_models/recurring_template_management_view_model.dart';

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
  const salary = Account(
    id: 'income-1',
    name: 'Salary',
    type: AccountType.income,
    archived: false,
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
    ).thenAnswer((_) => Stream.value(const [groceries, salary]));
  });

  Future<RecurringTemplateManagementViewModel> viewModelAfterLoad() async {
    final viewModel = RecurringTemplateManagementViewModel(
      recurringTemplateRepository: repository,
      accountRepository: accountRepository,
      categoryRepository: categoryRepository,
    );
    await Future<void>.delayed(Duration.zero);
    return viewModel;
  }

  test('categoriesFor filters by direction, active only', () async {
    final viewModel = await viewModelAfterLoad();
    addTearDown(viewModel.dispose);

    expect(
      viewModel.categoriesFor(TransactionDirection.moneyOut).map((c) => c.id),
      ['expense-1'],
    );
    expect(
      viewModel.categoriesFor(TransactionDirection.moneyIn).map((c) => c.id),
      ['income-1'],
    );
  });

  test('currencyFor resolves the account\'s group currency', () async {
    final viewModel = await viewModelAfterLoad();
    addTearDown(viewModel.dispose);

    expect(viewModel.currencyFor('account-1'), equals('USD'));
    expect(viewModel.currencyFor('missing'), isNull);
  });

  test('createTemplate calls through to the Repository on success', () async {
    final viewModel = await viewModelAfterLoad();
    addTearDown(viewModel.dispose);
    when(
      repository.createRecurringTemplate(
        name: anyNamed('name'),
        direction: anyNamed('direction'),
        financialAccountId: anyNamed('financialAccountId'),
        categoryId: anyNamed('categoryId'),
        amountMinor: anyNamed('amountMinor'),
        dayOfMonth: anyNamed('dayOfMonth'),
      ),
    ).thenAnswer(
      (_) async => const RecurringTemplate(
        id: 'template-1',
        name: 'Rent',
        direction: TransactionDirection.moneyOut,
        financialAccountId: 'account-1',
        categoryId: 'expense-1',
        amountMinor: 150000,
        dayOfMonth: 1,
      ),
    );

    final ok = await viewModel.createTemplate(
      name: 'Rent',
      direction: TransactionDirection.moneyOut,
      financialAccountId: 'account-1',
      categoryId: 'expense-1',
      amountMinor: 150000,
      dayOfMonth: 1,
    );

    expect(ok, isTrue);
    expect(viewModel.errorMessage, isNull);
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

  test(
    'createTemplate surfaces InvalidTransactionAmountException as errorMessage',
    () async {
      final viewModel = await viewModelAfterLoad();
      addTearDown(viewModel.dispose);
      when(
        repository.createRecurringTemplate(
          name: anyNamed('name'),
          direction: anyNamed('direction'),
          financialAccountId: anyNamed('financialAccountId'),
          categoryId: anyNamed('categoryId'),
          amountMinor: anyNamed('amountMinor'),
          dayOfMonth: anyNamed('dayOfMonth'),
        ),
      ).thenThrow(InvalidTransactionAmountException('must be positive'));

      final ok = await viewModel.createTemplate(
        name: 'Rent',
        direction: TransactionDirection.moneyOut,
        financialAccountId: 'account-1',
        categoryId: 'expense-1',
        amountMinor: 0,
        dayOfMonth: 1,
      );

      expect(ok, isFalse);
      expect(viewModel.errorMessage, equals('Amount must be positive.'));
    },
  );

  test('deleteTemplate delegates to the Repository', () async {
    final viewModel = await viewModelAfterLoad();
    addTearDown(viewModel.dispose);
    when(
      repository.deleteRecurringTemplate('template-1'),
    ).thenAnswer((_) async {});

    await viewModel.deleteTemplate('template-1');

    verify(repository.deleteRecurringTemplate('template-1')).called(1);
  });
}
