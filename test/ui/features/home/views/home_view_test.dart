import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:smara_accounting/domain/models/account.dart';
import 'package:smara_accounting/domain/models/account_group.dart';
import 'package:smara_accounting/domain/models/home_overview.dart';
import 'package:smara_accounting/domain/models/pending_transfer.dart';
import 'package:smara_accounting/domain/models/recurring_template.dart';
import 'package:smara_accounting/domain/models/summary.dart';
import 'package:smara_accounting/domain/models/transaction_direction.dart';
import 'package:smara_accounting/ui/features/home/view_models/home_view_model.dart';
import 'package:smara_accounting/ui/features/home/views/home_view.dart';

import '../../../../mocks.mocks.dart';

void main() {
  late MockLedgerRepository repository;
  late MockCategoryRepository categoryRepository;
  late MockRecurringTemplateRepository recurring;
  late MockInvestmentRepository investment;

  const cashGroup = AccountGroup(
    id: 'group-cash',
    name: 'Cash & cash equivalents',
    kind: AccountGroupKind.assetGroup,
    sortOrder: 0,
    isSystem: true,
    currency: 'USD',
    archived: false,
  );

  const checking = Account(
    id: 'asset-1',
    name: 'Checking',
    type: AccountType.asset,
    archived: false,
    groupId: 'group-cash',
  );

  setUp(() {
    repository = MockLedgerRepository();
    categoryRepository = MockCategoryRepository();
    recurring = MockRecurringTemplateRepository();
    investment = MockInvestmentRepository();
  });

  testWidgets(
    'renders per-currency net position, group totals, and account rows',
    (tester) async {
      when(repository.watchHomeOverview()).thenAnswer(
        (_) => Stream.value(
          const HomeOverview(
            sections: [
              AccountGroupSection(
                group: cashGroup,
                accounts: [
                  AccountBalance(
                    account: checking,
                    displayBalanceMinor: 150000,
                  ),
                ],
                totalDisplayBalanceMinor: 150000,
              ),
            ],
            netPositionsByCurrency: [
              CurrencyNetPosition(
                currency: 'USD',
                totalAssetsMinor: 150000,
                totalLiabilitiesMinor: 0,
              ),
            ],
            pendingTransfers: [],
          ),
        ),
      );

      final viewModel = HomeViewModel(
        ledgerRepository: repository,
        categoryRepository: categoryRepository,
        recurringTemplateRepository: recurring,
        investmentRepository: investment,
      );
      addTearDown(viewModel.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: HomeView(viewModel: viewModel, onAccountTap: (_) {}),
        ),
      );
      await tester.pump();

      expect(find.text('CASH & CASH EQUIVALENTS'), findsOneWidget);
      expect(find.text('Checking'), findsOneWidget);
      expect(find.textContaining('1,500.00 USD'), findsWidgets);
    },
  );

  testWidgets('tapping an account row invokes onAccountTap with its id', (
    tester,
  ) async {
    when(repository.watchHomeOverview()).thenAnswer(
      (_) => Stream.value(
        const HomeOverview(
          sections: [
            AccountGroupSection(
              group: cashGroup,
              accounts: [
                AccountBalance(account: checking, displayBalanceMinor: 0),
              ],
              totalDisplayBalanceMinor: 0,
            ),
          ],
          netPositionsByCurrency: [
            CurrencyNetPosition(
              currency: 'USD',
              totalAssetsMinor: 0,
              totalLiabilitiesMinor: 0,
            ),
          ],
          pendingTransfers: [],
        ),
      ),
    );

    final viewModel = HomeViewModel(
      ledgerRepository: repository,
      categoryRepository: categoryRepository,
      recurringTemplateRepository: recurring,
      investmentRepository: investment,
    );
    addTearDown(viewModel.dispose);
    String? tappedAccountId;

    await tester.pumpWidget(
      MaterialApp(
        home: HomeView(
          viewModel: viewModel,
          onAccountTap: (accountId) => tappedAccountId = accountId,
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Checking'));
    await tester.pump();

    expect(tappedAccountId, equals('asset-1'));
  });

  testWidgets(
    'renders a Pending Transfers section and taps invoke onSettlePendingTransfer',
    (tester) async {
      final pending = PendingTransfer(
        id: 'pending-1',
        kind: PendingTransferKind.transfer,
        sourceAccountId: 'asset-1',
        currency: 'USD',
        destinationAccountId: 'asset-2',
        provisionalEntryId: 'entry-1',
        status: PendingTransferStatus.pending,
        initiatedAt: DateTime(2026, 1, 15),
      );
      when(repository.watchHomeOverview()).thenAnswer(
        (_) => Stream.value(
          HomeOverview(
            sections: const [],
            netPositionsByCurrency: const [
              CurrencyNetPosition(
                currency: 'USD',
                totalAssetsMinor: 5000,
                totalLiabilitiesMinor: 0,
              ),
            ],
            pendingTransfers: [
              PendingTransferSummary(
                pendingTransfer: pending,
                sourceAccountName: 'Checking',
                destinationLabel: 'Savings',
                currency: 'USD',
                amountMinor: 5000,
              ),
            ],
          ),
        ),
      );

      final viewModel = HomeViewModel(
        ledgerRepository: repository,
        categoryRepository: categoryRepository,
        recurringTemplateRepository: recurring,
        investmentRepository: investment,
      );
      addTearDown(viewModel.dispose);
      String? settledId;

      await tester.pumpWidget(
        MaterialApp(
          home: HomeView(
            viewModel: viewModel,
            onAccountTap: (_) {},
            onSettlePendingTransfer: (id) => settledId = id,
          ),
        ),
      );
      await tester.pump();

      expect(find.text('MONEY IN TRANSIT'), findsOneWidget);
      expect(find.text('You sent 50.00 USD to Savings'), findsOneWidget);
      expect(find.text('Tap when you know what arrived'), findsOneWidget);

      await tester.tap(find.text('You sent 50.00 USD to Savings'));
      await tester.pump();

      expect(settledId, equals('pending-1'));
    },
  );

  testWidgets('the Add FAB opens a sheet; choosing Spent invokes onSpent', (
    tester,
  ) async {
    when(repository.watchHomeOverview()).thenAnswer(
      (_) => Stream.value(
        const HomeOverview(
          sections: [],
          netPositionsByCurrency: [],
          pendingTransfers: [],
        ),
      ),
    );

    final viewModel = HomeViewModel(
      ledgerRepository: repository,
      categoryRepository: categoryRepository,
      recurringTemplateRepository: recurring,
      investmentRepository: investment,
    );
    addTearDown(viewModel.dispose);
    var spentTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: HomeView(
          viewModel: viewModel,
          onAccountTap: (_) {},
          onSpent: () => spentTapped = true,
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.widgetWithText(FloatingActionButton, 'Add'));
    await tester.pumpAndSettle();
    expect(find.text('Spent'), findsOneWidget);
    expect(find.text('Received'), findsOneWidget);
    expect(find.text('Moved money'), findsOneWidget);
    expect(find.text('Import statement'), findsOneWidget);

    await tester.tap(find.text('Spent'));
    await tester.pumpAndSettle();

    expect(spentTapped, isTrue);
  });

  testWidgets('renders this month\'s Spent and Received category totals', (
    tester,
  ) async {
    when(repository.watchHomeOverview()).thenAnswer(
      (_) => Stream.value(
        const HomeOverview(
          sections: [],
          netPositionsByCurrency: [],
          pendingTransfers: [],
        ),
      ),
    );
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
      recurringTemplateRepository: recurring,
      investmentRepository: investment,
    );
    addTearDown(viewModel.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: HomeView(viewModel: viewModel, onAccountTap: (_) {}),
      ),
    );
    await tester.pump();

    expect(find.text('THIS MONTH'), findsOneWidget);
    expect(find.text('Groceries'), findsOneWidget);
    expect(find.text('Salary'), findsOneWidget);
  });

  testWidgets('no THIS MONTH section when there is no category activity', (
    tester,
  ) async {
    when(repository.watchHomeOverview()).thenAnswer(
      (_) => Stream.value(
        const HomeOverview(
          sections: [],
          netPositionsByCurrency: [],
          pendingTransfers: [],
        ),
      ),
    );
    when(
      categoryRepository.watchCategoryTotals(
        start: anyNamed('start'),
        end: anyNamed('end'),
      ),
    ).thenAnswer((_) => Stream.value(const []));

    final viewModel = HomeViewModel(
      ledgerRepository: repository,
      categoryRepository: categoryRepository,
      recurringTemplateRepository: recurring,
      investmentRepository: investment,
    );
    addTearDown(viewModel.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: HomeView(viewModel: viewModel, onAccountTap: (_) {}),
      ),
    );
    await tester.pump();

    expect(find.text('THIS MONTH'), findsNothing);
  });

  testWidgets(
    'renders a DUE TODAY section; tapping a due template records it',
    (tester) async {
      when(repository.watchHomeOverview()).thenAnswer(
        (_) => Stream.value(
          const HomeOverview(
            sections: [],
            netPositionsByCurrency: [],
            pendingTransfers: [],
          ),
        ),
      );
      const dueTemplate = RecurringTemplate(
        id: 'template-1',
        name: 'Rent',
        direction: TransactionDirection.moneyOut,
        financialAccountId: 'account-1',
        categoryId: 'category-1',
        amountMinor: 150000,
        dayOfMonth: 1,
      );
      when(recurring.watchDueRecurringTemplates()).thenAnswer(
        (_) => Stream.value(const [
          DueRecurringTemplate(
            template: dueTemplate,
            financialAccountName: 'Checking',
            categoryName: 'Rent/Mortgage',
            currency: 'USD',
          ),
        ]),
      );
      when(
        recurring.recordDueTemplate('template-1'),
      ).thenAnswer((_) async => 'entry-1');

      final viewModel = HomeViewModel(
        ledgerRepository: repository,
        categoryRepository: categoryRepository,
        recurringTemplateRepository: recurring,
        investmentRepository: investment,
      );
      addTearDown(viewModel.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: HomeView(viewModel: viewModel, onAccountTap: (_) {}),
        ),
      );
      await tester.pump();

      expect(find.text('DUE TODAY'), findsOneWidget);
      expect(find.text('Rent'), findsOneWidget);

      await tester.tap(find.text('Rent'));
      await tester.pump();

      verify(recurring.recordDueTemplate('template-1')).called(1);
    },
  );

  testWidgets('no DUE TODAY section when nothing is due', (tester) async {
    when(repository.watchHomeOverview()).thenAnswer(
      (_) => Stream.value(
        const HomeOverview(
          sections: [],
          netPositionsByCurrency: [],
          pendingTransfers: [],
        ),
      ),
    );
    when(
      recurring.watchDueRecurringTemplates(),
    ).thenAnswer((_) => Stream.value(const []));

    final viewModel = HomeViewModel(
      ledgerRepository: repository,
      categoryRepository: categoryRepository,
      recurringTemplateRepository: recurring,
      investmentRepository: investment,
    );
    addTearDown(viewModel.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: HomeView(viewModel: viewModel, onAccountTap: (_) {}),
      ),
    );
    await tester.pump();

    expect(find.text('DUE TODAY'), findsNothing);
  });

  testWidgets(
    'monthly-category-limits: a limited category in THIS MONTH shows the '
    'same progress indication as category management',
    (tester) async {
      when(repository.watchHomeOverview()).thenAnswer(
        (_) => Stream.value(
          const HomeOverview(
            sections: [],
            netPositionsByCurrency: [],
            pendingTransfers: [],
          ),
        ),
      );
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
            totalMinor: 12000,
          ),
        ]),
      );
      when(categoryRepository.watchCategories()).thenAnswer(
        (_) => Stream.value(const [
          Account(
            id: 'expense-1',
            name: 'Groceries',
            type: AccountType.expense,
            archived: false,
            monthlyLimitMinor: 15000,
          ),
        ]),
      );

      final viewModel = HomeViewModel(
        ledgerRepository: repository,
        categoryRepository: categoryRepository,
        recurringTemplateRepository: recurring,
        investmentRepository: investment,
      );
      addTearDown(viewModel.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: HomeView(viewModel: viewModel, onAccountTap: (_) {}),
        ),
      );
      await tester.pump();

      expect(find.textContaining('120.00 of 150.00'), findsOneWidget);
    },
  );
}
