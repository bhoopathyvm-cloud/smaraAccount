import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:smara_accounting/domain/models/account.dart';
import 'package:smara_accounting/domain/models/account_group.dart';
import 'package:smara_accounting/domain/models/home_overview.dart';
import 'package:smara_accounting/domain/models/pending_transfer.dart';
import 'package:smara_accounting/ui/features/home/view_models/home_view_model.dart';
import 'package:smara_accounting/ui/features/home/views/home_view.dart';

import '../../../../mocks.mocks.dart';

void main() {
  late MockLedgerRepository repository;

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

      final viewModel = HomeViewModel(ledgerRepository: repository);
      addTearDown(viewModel.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: HomeView(viewModel: viewModel, onAccountTap: (_) {}),
        ),
      );
      await tester.pump();

      expect(find.text('CASH & CASH EQUIVALENTS'), findsOneWidget);
      expect(find.text('Checking'), findsOneWidget);
      expect(find.textContaining('1500.00 USD'), findsWidgets);
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

    final viewModel = HomeViewModel(ledgerRepository: repository);
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

      final viewModel = HomeViewModel(ledgerRepository: repository);
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

      expect(find.text('PENDING TRANSFERS'), findsOneWidget);
      expect(find.text('Checking → Savings'), findsOneWidget);

      await tester.tap(find.text('Checking → Savings'));
      await tester.pump();

      expect(settledId, equals('pending-1'));
    },
  );
}
