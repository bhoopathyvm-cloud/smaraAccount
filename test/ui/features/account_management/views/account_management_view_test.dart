import 'dart:async';

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
    currency: 'USD',
    archived: false,
  );
  const creditGroup = AccountGroup(
    id: 'group-credit',
    name: 'Credit & short-term debt',
    kind: AccountGroupKind.liabilityGroup,
    sortOrder: 1,
    isSystem: true,
    currency: 'USD',
    archived: false,
  );

  const businessGroup = AccountGroup(
    id: 'group-business',
    name: 'Business',
    kind: AccountGroupKind.assetGroup,
    sortOrder: 4,
    isSystem: false,
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
      repository.watchAccountGroups(
        includeArchived: anyNamed('includeArchived'),
      ),
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

  testWidgets('system groups have no archive action, only an edit icon', (
    tester,
  ) async {
    final viewModel = AccountManagementViewModel(ledgerRepository: repository);
    addTearDown(viewModel.dispose);

    await tester.pumpWidget(
      MaterialApp(home: AccountManagementView(viewModel: viewModel)),
    );
    await tester.pump();

    // Checking and Savings each have their own popup; both cashGroup and
    // creditGroup are system groups, so neither contributes one.
    expect(find.byIcon(Icons.more_vert), findsNWidgets(2));
    expect(find.byTooltip('Edit group'), findsNWidgets(2));
  });

  testWidgets(
    'Create group dialog creates a new group with name, kind, and currency',
    (tester) async {
      // The repository call's Future is left uncompleted deliberately: the
      // dialog disposes its TextEditingControllers as soon as that Future
      // resolves and the dialog pops, and rendering any further frame
      // against an already-disposed controller mid-exit-transition is a
      // pre-existing dispose-timing quirk this dialog shares with the
      // "Create account" one (not something introduced here). Never
      // completing the Future keeps the dialog open, which is enough to
      // verify the submission call was made with the right arguments.
      final neverCompletes = Completer<AccountGroup>();
      when(
        repository.createAccountGroup(
          name: anyNamed('name'),
          kind: anyNamed('kind'),
          currency: anyNamed('currency'),
        ),
      ).thenAnswer((_) => neverCompletes.future);

      final viewModel = AccountManagementViewModel(
        ledgerRepository: repository,
      );
      addTearDown(viewModel.dispose);

      await tester.pumpWidget(
        MaterialApp(home: AccountManagementView(viewModel: viewModel)),
      );
      await tester.pump();

      await tester.tap(find.byTooltip('Create group'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'Business');
      await tester.tap(find.text('Liability'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ChoiceChip, 'EUR'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Create'));
      await tester.pump();

      verify(
        repository.createAccountGroup(
          name: 'Business',
          kind: AccountGroupKind.liabilityGroup,
          currency: 'EUR',
        ),
      ).called(1);
    },
  );

  testWidgets(
    'Create group dialog disables Create until the currency is a valid 3-letter code',
    (tester) async {
      final viewModel = AccountManagementViewModel(
        ledgerRepository: repository,
      );
      addTearDown(viewModel.dispose);

      await tester.pumpWidget(
        MaterialApp(home: AccountManagementView(viewModel: viewModel)),
      );
      await tester.pump();

      await tester.tap(find.byTooltip('Create group'));
      await tester.pumpAndSettle();

      final currencyField = find.widgetWithText(
        TextField,
        'Currency (ISO 4217, e.g. USD)',
      );
      await tester.enterText(currencyField, '1');
      await tester.pumpAndSettle();

      final createButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Create'),
      );
      expect(createButton.onPressed, isNull);
    },
  );

  testWidgets('Archive group action archives an empty user-created group', (
    tester,
  ) async {
    when(
      repository.watchAccountGroups(
        includeArchived: anyNamed('includeArchived'),
      ),
    ).thenAnswer((_) => Stream.value([cashGroup, creditGroup, businessGroup]));
    when(
      repository.archiveAccountGroup(businessGroup.id),
    ).thenAnswer((_) async {});

    final viewModel = AccountManagementViewModel(ledgerRepository: repository);
    addTearDown(viewModel.dispose);

    await tester.pumpWidget(
      MaterialApp(home: AccountManagementView(viewModel: viewModel)),
    );
    await tester.pump();

    // Checking + Savings popups, plus Business's own group-level popup
    // (it has no member accounts) - the group popup renders last.
    await tester.tap(find.byIcon(Icons.more_vert).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Archive'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(OutlinedButton, 'Archive'));
    await tester.pumpAndSettle();

    verify(repository.archiveAccountGroup(businessGroup.id)).called(1);
  });

  testWidgets(
    'Archive group action surfaces a rejected-with-active-accounts error',
    (tester) async {
      when(
        repository.watchAccountGroups(
          includeArchived: anyNamed('includeArchived'),
        ),
      ).thenAnswer(
        (_) => Stream.value([cashGroup, creditGroup, businessGroup]),
      );
      when(repository.archiveAccountGroup(businessGroup.id)).thenThrow(
        AccountGroupException(
          'Cannot archive a group with active financial accounts.',
        ),
      );

      final viewModel = AccountManagementViewModel(
        ledgerRepository: repository,
      );
      addTearDown(viewModel.dispose);

      await tester.pumpWidget(
        MaterialApp(home: AccountManagementView(viewModel: viewModel)),
      );
      await tester.pump();

      await tester.tap(find.byIcon(Icons.more_vert).last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Archive'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(OutlinedButton, 'Archive'));
      await tester.pumpAndSettle();

      expect(
        find.text('Cannot archive a group with active financial accounts.'),
        findsOneWidget,
      );
    },
  );
}
