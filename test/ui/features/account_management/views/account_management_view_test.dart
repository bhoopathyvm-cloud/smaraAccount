import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:smara_accounting/domain/exceptions.dart';
import 'package:smara_accounting/domain/models/account.dart';
import 'package:smara_accounting/domain/models/account_group.dart';
import 'package:smara_accounting/ui/features/account_management/view_models/account_management_view_model.dart';
import 'package:smara_accounting/ui/features/account_management/views/account_management_view.dart';

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
  const creditGroup = AccountGroup(
    id: 'group-credit',
    name: 'Credit & short-term debt',
    kind: AccountGroupKind.liabilityGroup,
    sortOrder: 1,
    isSystem: true,
  );

  const checking = Account(
    id: 'asset-1',
    name: 'Checking',
    type: AccountType.asset,
    archived: false,
    groupId: 'group-cash',
  );
  const savings = Account(
    id: 'asset-2',
    name: 'Savings',
    type: AccountType.asset,
    archived: false,
    groupId: 'group-cash',
  );

  setUp(() {
    repository = MockLedgerRepository();
    when(
      repository.watchFinancialAccounts(
        includeArchived: anyNamed('includeArchived'),
      ),
    ).thenAnswer((_) => Stream.value([checking, savings]));
    when(
      repository.watchAccountGroups(),
    ).thenAnswer((_) => Stream.value([cashGroup, creditGroup]));
  });

  testWidgets('lists accounts grouped under their account group', (
    tester,
  ) async {
    final viewModel = AccountManagementViewModel(ledgerRepository: repository);
    addTearDown(viewModel.dispose);

    await tester.pumpWidget(
      MaterialApp(home: AccountManagementView(viewModel: viewModel)),
    );
    await tester.pump();

    expect(find.text('Cash & cash equivalents'), findsOneWidget);
    expect(find.text('Credit & short-term debt'), findsOneWidget);
    expect(find.text('Checking'), findsOneWidget);
    expect(find.text('Savings'), findsOneWidget);
    expect(find.text('No accounts'), findsOneWidget);
  });

  testWidgets(
    'archiving the last active account shows the Repository error message',
    (tester) async {
      when(repository.archiveFinancialAccount(any)).thenThrow(
        LastActiveAccountException('cannot archive the last account'),
      );

      final viewModel = AccountManagementViewModel(
        ledgerRepository: repository,
      );
      addTearDown(viewModel.dispose);

      await tester.pumpWidget(
        MaterialApp(home: AccountManagementView(viewModel: viewModel)),
      );
      await tester.pump();

      await tester.tap(find.byIcon(Icons.more_vert).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Archive'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(OutlinedButton, 'Archive'));
      await tester.pumpAndSettle();

      expect(find.text('cannot archive the last account'), findsOneWidget);
    },
  );
}
