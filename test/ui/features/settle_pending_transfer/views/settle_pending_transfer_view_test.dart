import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:smara_accounting/domain/models/account.dart';
import 'package:smara_accounting/domain/models/account_group.dart';
import 'package:smara_accounting/domain/models/home_overview.dart';
import 'package:smara_accounting/domain/models/pending_transfer.dart';
import 'package:smara_accounting/ui/features/settle_pending_transfer/view_models/settle_pending_transfer_view_model.dart';
import 'package:smara_accounting/ui/features/settle_pending_transfer/views/settle_pending_transfer_view.dart';

import '../../../../mocks.mocks.dart';

void main() {
  late MockLedgerRepository repository;
  late MockAccountRepository accountRepository;

  const checking = Account(
    id: 'asset-1',
    name: 'Checking',
    type: AccountType.asset,
    archived: false,
    groupId: 'group-usd',
  );
  const euroSavings = Account(
    id: 'asset-2',
    name: 'Euro Savings',
    type: AccountType.asset,
    archived: false,
    groupId: 'group-eur',
  );
  const usdGroup = AccountGroup(
    id: 'group-usd',
    name: 'Cash & cash equivalents',
    kind: AccountGroupKind.assetGroup,
    sortOrder: 0,
    isSystem: true,
    currency: 'USD',
    archived: false,
  );
  const eurGroup = AccountGroup(
    id: 'group-eur',
    name: 'Pension & retirement',
    kind: AccountGroupKind.assetGroup,
    sortOrder: 1,
    isSystem: true,
    currency: 'EUR',
    archived: false,
  );
  const expenseCategory = Account(
    id: 'expense-1',
    name: 'Bank Fees',
    type: AccountType.expense,
    archived: false,
  );

  setUp(() {
    repository = MockLedgerRepository();
    accountRepository = MockAccountRepository();
    when(
      accountRepository.watchFinancialAccounts(
        includeArchived: anyNamed('includeArchived'),
      ),
    ).thenAnswer((_) => Stream.value([checking, euroSavings]));
    when(
      accountRepository.watchAccountGroups(
        includeArchived: anyNamed('includeArchived'),
      ),
    ).thenAnswer((_) => Stream.value([usdGroup, eurGroup]));
    when(
      repository.watchCategories(),
    ).thenAnswer((_) => Stream.value([expenseCategory]));
  });

  testWidgets(
    'transfer settling to destination: no radio-selected shortfall UI, submits with no fee',
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
      final summary = PendingTransferSummary(
        pendingTransfer: pending,
        sourceAccountName: 'Checking',
        destinationLabel: 'Euro Savings',
        currency: 'USD',
        amountMinor: 10000,
      );
      when(
        repository.settlePendingTransfer(
          pendingTransferId: anyNamed('pendingTransferId'),
          settledToAccountId: anyNamed('settledToAccountId'),
          settledAmountMinor: anyNamed('settledAmountMinor'),
          feeCategoryId: anyNamed('feeCategoryId'),
        ),
      ).thenAnswer((_) async {});

      final viewModel = SettlePendingTransferViewModel(
        ledgerRepository: repository,
        accountRepository: accountRepository,
        summary: summary,
      );
      addTearDown(viewModel.dispose);
      var saved = false;

      await tester.pumpWidget(
        MaterialApp(
          home: SettlePendingTransferView(
            viewModel: viewModel,
            onSaved: () => saved = true,
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Delivered to Euro Savings'), findsOneWidget);
      expect(find.text('Returned to Checking'), findsOneWidget);

      // Before either radio is selected, settledAmountCurrency resolves to
      // the destination account's own currency (Euro Savings, EUR) - a
      // comma decimal is EUR's own convention (localized-money-formatting),
      // not a period.
      await tester.enterText(find.byType(TextField).first, '92,00');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Settle'));
      await tester.pump();
      await tester.pump();

      expect(saved, isTrue);
      verify(
        repository.settlePendingTransfer(
          pendingTransferId: 'pending-1',
          settledToAccountId: 'asset-2',
          settledAmountMinor: 9200,
          feeCategoryId: null,
        ),
      ).called(1);
    },
  );

  testWidgets(
    'transfer settling back to source with a shortfall requires a fee category',
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
      final summary = PendingTransferSummary(
        pendingTransfer: pending,
        sourceAccountName: 'Checking',
        destinationLabel: 'Euro Savings',
        currency: 'USD',
        amountMinor: 10000,
      );
      when(
        repository.settlePendingTransfer(
          pendingTransferId: anyNamed('pendingTransferId'),
          settledToAccountId: anyNamed('settledToAccountId'),
          settledAmountMinor: anyNamed('settledAmountMinor'),
          feeCategoryId: anyNamed('feeCategoryId'),
        ),
      ).thenAnswer((_) async {});

      final viewModel = SettlePendingTransferViewModel(
        ledgerRepository: repository,
        accountRepository: accountRepository,
        summary: summary,
      );
      addTearDown(viewModel.dispose);

      await tester.pumpWidget(
        MaterialApp(home: SettlePendingTransferView(viewModel: viewModel)),
      );
      await tester.pump();

      await tester.tap(find.text('Returned to Checking'));
      await tester.pump();
      await tester.enterText(find.byType(TextField).first, '90.00');
      await tester.pump();

      expect(find.textContaining('less than expected'), findsOneWidget);
      expect(find.text('Fee / loss category'), findsOneWidget);

      await tester.tap(
        find.widgetWithText(
          DropdownButtonFormField<String>,
          'Fee / loss category',
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Bank Fees').last);
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Settle'));
      await tester.pump();
      await tester.pump();

      verify(
        repository.settlePendingTransfer(
          pendingTransferId: 'pending-1',
          settledToAccountId: 'asset-1',
          settledAmountMinor: 9000,
          feeCategoryId: 'expense-1',
        ),
      ).called(1);
    },
  );

  testWidgets(
    'foreignTransaction: no destination radio choices, always settles to its own source',
    (tester) async {
      final pending = PendingTransfer(
        id: 'pending-2',
        kind: PendingTransferKind.foreignTransaction,
        sourceAccountId: 'asset-1',
        currency: 'EUR',
        categoryId: 'expense-1',
        provisionalEntryId: 'entry-2',
        status: PendingTransferStatus.pending,
        initiatedAt: DateTime(2026, 1, 15),
      );
      final summary = PendingTransferSummary(
        pendingTransfer: pending,
        sourceAccountName: 'Checking',
        destinationLabel: 'Bank Fees',
        currency: 'EUR',
        amountMinor: 5000,
      );
      when(
        repository.settlePendingTransfer(
          pendingTransferId: anyNamed('pendingTransferId'),
          settledToAccountId: anyNamed('settledToAccountId'),
          settledAmountMinor: anyNamed('settledAmountMinor'),
          feeCategoryId: anyNamed('feeCategoryId'),
        ),
      ).thenAnswer((_) async {});

      final viewModel = SettlePendingTransferViewModel(
        ledgerRepository: repository,
        accountRepository: accountRepository,
        summary: summary,
      );
      addTearDown(viewModel.dispose);

      await tester.pumpWidget(
        MaterialApp(home: SettlePendingTransferView(viewModel: viewModel)),
      );
      await tester.pump();

      expect(find.textContaining('Delivered to'), findsNothing);
      expect(find.textContaining('Returned to'), findsNothing);

      await tester.enterText(find.byType(TextField).first, '54.00');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Settle'));
      await tester.pump();
      await tester.pump();

      verify(
        repository.settlePendingTransfer(
          pendingTransferId: 'pending-2',
          settledToAccountId: 'asset-1',
          settledAmountMinor: 5400,
          feeCategoryId: null,
        ),
      ).called(1);
    },
  );
}
