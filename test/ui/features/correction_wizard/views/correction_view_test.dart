import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:smara_accounting/domain/models/account.dart';
import 'package:smara_accounting/domain/models/account_currency_catalog.dart';
import 'package:smara_accounting/domain/models/transaction_direction.dart';
import 'package:smara_accounting/ui/core/money_amount_field.dart';
import 'package:smara_accounting/ui/features/correction_wizard/view_models/correction_view_model.dart';
import 'package:smara_accounting/ui/features/correction_wizard/views/correction_view.dart';

import '../../../../mocks.mocks.dart';

void main() {
  late MockLedgerRepository repository;
  late MockAccountRepository accountRepository;
  late MockCategoryRepository categoryRepository;

  const yenAccount = Account(
    id: 'asset-1',
    name: 'Cash',
    type: AccountType.asset,
    archived: false,
    groupId: 'group-cash',
  );

  const groceries = Account(
    id: 'expense-groceries',
    name: 'Groceries',
    type: AccountType.expense,
    archived: false,
  );

  setUp(() {
    repository = MockLedgerRepository();
    accountRepository = MockAccountRepository();
    categoryRepository = MockCategoryRepository();
    when(
      accountRepository.watchFinancialAccounts(),
    ).thenAnswer((_) => Stream.value([yenAccount]));
    when(
      categoryRepository.watchCategories(),
    ).thenAnswer((_) => Stream.value([groceries]));
    when(
      accountRepository.watchAccountCurrencies(
        includeArchived: anyNamed('includeArchived'),
      ),
    ).thenAnswer(
      (_) => Stream.value(const AccountCurrencyCatalog({'asset-1': 'JPY'})),
    );
  });

  testWidgets(
    'prefills the amount using the account currency, not a hardcoded /100',
    (tester) async {
      final viewModel = CorrectionViewModel(
        ledgerRepository: repository,
        accountRepository: accountRepository,
        categoryRepository: categoryRepository,
        entryId: 'entry-1',
        initialAmountMinor: 10000,
        initialDirection: TransactionDirection.moneyOut,
        initialCategoryId: groceries.id,
        initialFinancialAccountId: yenAccount.id,
        initialTransactionDate: DateTime(2026, 1, 17),
      );
      addTearDown(viewModel.dispose);

      await tester.pumpWidget(
        MaterialApp(home: CorrectionView(viewModel: viewModel)),
      );
      await tester.pump();

      final field = tester.widget<TextField>(
        find.descendant(
          of: find.byType(MoneyAmountField),
          matching: find.byType(TextField),
        ),
      );
      expect(field.controller?.text, equals('10,000'));
      expect(find.text('100.00'), findsNothing);
    },
  );
}
