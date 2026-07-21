import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:smara_accounting/domain/models/account.dart';
import 'package:smara_accounting/domain/models/account_group.dart';
import 'package:smara_accounting/domain/models/home_overview.dart';
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

  testWidgets('renders net position, group totals, and account rows', (
    tester,
  ) async {
    when(repository.watchHomeOverview()).thenAnswer(
      (_) => Stream.value(
        const HomeOverview(
          sections: [
            AccountGroupSection(
              group: cashGroup,
              accounts: [
                AccountBalance(account: checking, displayBalanceMinor: 150000),
              ],
              totalDisplayBalanceMinor: 150000,
            ),
          ],
          netPositionMinor: 150000,
          totalAssetsMinor: 150000,
          totalLiabilitiesMinor: 0,
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
    expect(find.text('1500.00'), findsWidgets);
  });

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
          netPositionMinor: 0,
          totalAssetsMinor: 0,
          totalLiabilitiesMinor: 0,
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
}
