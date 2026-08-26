import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:smara_accounting/domain/models/account.dart';
import 'package:smara_accounting/domain/models/account_currency_catalog.dart';
import 'package:smara_accounting/domain/models/home_overview.dart';
import 'package:smara_accounting/domain/models/pending_transfer.dart';
import 'package:smara_accounting/l10n/l10n.dart';
import 'package:smara_accounting/ui/features/settle_pending_transfer/views/settle_pending_transfer_route.dart';

import '../../../../mocks.mocks.dart';

void main() {
  late MockLedgerRepository repository;
  late MockAccountRepository accountRepository;
  late MockCategoryRepository categoryRepository;

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
  const currencies = AccountCurrencyCatalog({
    'asset-1': 'USD',
    'asset-2': 'EUR',
  });
  const expenseCategory = Account(
    id: 'expense-1',
    name: 'Bank Fees',
    type: AccountType.expense,
    archived: false,
  );

  setUp(() {
    repository = MockLedgerRepository();
    accountRepository = MockAccountRepository();
    categoryRepository = MockCategoryRepository();
    when(
      accountRepository.watchFinancialAccounts(
        includeArchived: anyNamed('includeArchived'),
      ),
    ).thenAnswer((_) => Stream.value([checking, euroSavings]));
    when(
      accountRepository.watchAccountCurrencies(
        includeArchived: anyNamed('includeArchived'),
      ),
    ).thenAnswer((_) => Stream.value(currencies));
    when(
      categoryRepository.watchCategories(),
    ).thenAnswer((_) => Stream.value([expenseCategory]));
  });

  Widget app(Widget home) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: supportedAppLocales,
      home: home,
    );
  }

  testWidgets('loads summary by id without Home overview', (tester) async {
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
    when(repository.pendingTransferSummary('pending-1')).thenAnswer(
      (_) async => PendingTransferSummary(
        pendingTransfer: pending,
        sourceAccountName: 'Checking',
        destinationLabel: 'Euro Savings',
        currency: 'USD',
        amountMinor: 10000,
      ),
    );

    await tester.pumpWidget(
      app(
        SettlePendingTransferRoute(
          pendingTransferId: 'pending-1',
          ledgerRepository: repository,
          accountRepository: accountRepository,
          categoryRepository: categoryRepository,
        ),
      ),
    );
    await tester.pumpAndSettle();

    verify(repository.pendingTransferSummary('pending-1')).called(1);
    verifyNever(repository.watchHomeOverview());
    expect(find.text('Delivered to Euro Savings'), findsOneWidget);
  });

  testWidgets('unknown id shows already settled', (tester) async {
    when(
      repository.pendingTransferSummary('gone'),
    ).thenAnswer((_) async => null);

    await tester.pumpWidget(
      app(
        SettlePendingTransferRoute(
          pendingTransferId: 'gone',
          ledgerRepository: repository,
          accountRepository: accountRepository,
          categoryRepository: categoryRepository,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Already settled.'), findsOneWidget);
  });
}
