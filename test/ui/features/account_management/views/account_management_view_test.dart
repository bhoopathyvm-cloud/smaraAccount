import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:smara_accounting/domain/exceptions.dart';
import 'package:smara_accounting/domain/models/account.dart';
import 'package:smara_accounting/domain/models/account_group.dart';
import 'package:smara_accounting/ui/features/account_management/view_models/account_management_view_model.dart';
import 'package:smara_accounting/ui/features/account_management/views/account_management_view.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

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
      await tester.tap(find.text('Hide'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(OutlinedButton, 'Hide'));
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
    'Create group dialog creates a new group with name, kind, and currency, '
    'and closes cleanly through the exit animation',
    (tester) async {
      when(
        repository.createAccountGroup(
          name: anyNamed('name'),
          kind: anyNamed('kind'),
          currency: anyNamed('currency'),
        ),
      ).thenAnswer((_) async => businessGroup);

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
      // Regression guard: pumpAndSettle runs every frame of the dialog's
      // exit transition. If the controllers backing its TextFields were
      // disposed before that transition finishes, one of those frames
      // throws "A TextEditingController was used after being disposed."
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      verify(
        repository.createAccountGroup(
          name: 'Business',
          kind: AccountGroupKind.liabilityGroup,
          currency: 'EUR',
        ),
      ).called(1);
      expect(find.text('Create group'), findsNothing);
    },
  );

  testWidgets('Create account dialog creates a new account and closes cleanly '
      'through the exit animation', (tester) async {
    when(
      repository.createFinancialAccount(
        name: anyNamed('name'),
        type: anyNamed('type'),
        groupId: anyNamed('groupId'),
        openingBalanceMinor: anyNamed('openingBalanceMinor'),
      ),
    ).thenAnswer(
      (_) async => const Account(
        id: 'asset-3',
        name: 'Brokerage',
        type: AccountType.asset,
        archived: false,
        groupId: 'group-cash',
      ),
    );

    final viewModel = AccountManagementViewModel(ledgerRepository: repository);
    addTearDown(viewModel.dispose);

    await tester.pumpWidget(
      MaterialApp(home: AccountManagementView(viewModel: viewModel)),
    );
    await tester.pump();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'Brokerage');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Create'));
    // Regression guard: pumpAndSettle runs every frame of the dialog's
    // exit transition. If the controllers backing its TextFields were
    // disposed before that transition finishes, one of those frames
    // throws "A TextEditingController was used after being disposed."
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    verify(
      repository.createFinancialAccount(
        name: 'Brokerage',
        type: AccountType.asset,
        groupId: 'group-cash',
        openingBalanceMinor: null,
      ),
    ).called(1);
    expect(find.text('Create account'), findsNothing);
  });

  testWidgets(
    'Rename account dialog renames and closes cleanly through the exit '
    'animation',
    (tester) async {
      when(
        repository.renameFinancialAccount(
          id: anyNamed('id'),
          newName: anyNamed('newName'),
        ),
      ).thenAnswer((_) async {});

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
      await tester.tap(find.text('Rename'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).last, 'Main Checking');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
      // Regression guard: pumpAndSettle runs every frame of the dialog's
      // exit transition. If the controller backing its TextField were
      // disposed before that transition finishes, one of those frames
      // throws "A TextEditingController was used after being disposed."
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      verify(
        repository.renameFinancialAccount(
          id: 'asset-1',
          newName: 'Main Checking',
        ),
      ).called(1);
      expect(find.text('Rename account'), findsNothing);
    },
  );

  testWidgets(
    'Rename (edit) group dialog renames and closes cleanly through the exit '
    'animation',
    (tester) async {
      when(
        repository.renameAccountGroup(
          id: anyNamed('id'),
          newName: anyNamed('newName'),
        ),
      ).thenAnswer((_) async {});

      final viewModel = AccountManagementViewModel(
        ledgerRepository: repository,
      );
      addTearDown(viewModel.dispose);

      await tester.pumpWidget(
        MaterialApp(home: AccountManagementView(viewModel: viewModel)),
      );
      await tester.pump();

      await tester.tap(find.byTooltip('Edit group').first);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'Everyday Cash');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
      // Same dispose-after-dismissal regression guard as the account
      // rename dialog above.
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      verify(
        repository.renameAccountGroup(
          id: 'group-cash',
          newName: 'Everyday Cash',
        ),
      ).called(1);
      expect(find.text('Edit group'), findsNothing);
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
    await tester.tap(find.text('Hide'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(OutlinedButton, 'Hide'));
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
      await tester.tap(find.text('Hide'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(OutlinedButton, 'Hide'));
      await tester.pumpAndSettle();

      expect(
        find.text('Cannot archive a group with active financial accounts.'),
        findsOneWidget,
      );
    },
  );

  group('unarchive-accounts-categories', () {
    const archivedAccount = Account(
      id: 'asset-3',
      name: 'Old Checking',
      type: AccountType.asset,
      archived: true,
      groupId: 'group-cash',
    );
    const archivedGroup = AccountGroup(
      id: 'group-business',
      name: 'Business',
      kind: AccountGroupKind.assetGroup,
      sortOrder: 4,
      isSystem: false,
      currency: 'USD',
      archived: true,
    );

    testWidgets(
      'an archived account shows Restore instead of the action menu, and '
      'tapping it calls through',
      (tester) async {
        when(
          repository.watchFinancialAccounts(
            includeArchived: anyNamed('includeArchived'),
          ),
        ).thenAnswer((_) => Stream.value([checking, savings, archivedAccount]));
        when(
          repository.unarchiveFinancialAccount('asset-3'),
        ).thenAnswer((_) async {});

        final viewModel = AccountManagementViewModel(
          ledgerRepository: repository,
        );
        addTearDown(viewModel.dispose);

        await tester.pumpWidget(
          MaterialApp(home: AccountManagementView(viewModel: viewModel)),
        );
        await tester.pump();

        expect(
          find.descendant(
            of: find.widgetWithText(ListTile, 'Old Checking'),
            matching: find.text('Restore'),
          ),
          findsOneWidget,
        );

        await tester.tap(
          find.descendant(
            of: find.widgetWithText(ListTile, 'Old Checking'),
            matching: find.text('Restore'),
          ),
        );
        await tester.pump();

        verify(repository.unarchiveFinancialAccount('asset-3')).called(1);
      },
    );

    testWidgets(
      'an archived user-created group shows Restore, and tapping it calls '
      'through',
      (tester) async {
        when(
          repository.watchAccountGroups(
            includeArchived: anyNamed('includeArchived'),
          ),
        ).thenAnswer(
          (_) => Stream.value([cashGroup, creditGroup, archivedGroup]),
        );
        when(
          repository.unarchiveAccountGroup('group-business'),
        ).thenAnswer((_) async {});

        final viewModel = AccountManagementViewModel(
          ledgerRepository: repository,
        );
        addTearDown(viewModel.dispose);

        await tester.pumpWidget(
          MaterialApp(home: AccountManagementView(viewModel: viewModel)),
        );
        await tester.pump();

        expect(
          find.descendant(
            of: find.widgetWithText(ListTile, 'Business'),
            matching: find.text('Restore'),
          ),
          findsOneWidget,
        );

        await tester.tap(
          find.descendant(
            of: find.widgetWithText(ListTile, 'Business'),
            matching: find.text('Restore'),
          ),
        );
        await tester.pump();

        verify(repository.unarchiveAccountGroup('group-business')).called(1);
      },
    );
  });

  group('credit-card-household-flow', () {
    testWidgets(
      'the credit-card checkbox only appears for Liability, and its value '
      'is passed through on Create',
      (tester) async {
        when(
          repository.createFinancialAccount(
            name: anyNamed('name'),
            type: anyNamed('type'),
            groupId: anyNamed('groupId'),
            openingBalanceMinor: anyNamed('openingBalanceMinor'),
            isCreditCard: anyNamed('isCreditCard'),
          ),
        ).thenAnswer(
          (_) async => const Account(
            id: 'liability-2',
            name: 'Visa',
            type: AccountType.liability,
            archived: false,
            isCreditCard: true,
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

        await tester.tap(find.byIcon(TablerIcons.plus));
        await tester.pumpAndSettle();

        expect(find.text('This is a credit card'), findsNothing);

        await tester.tap(find.text('Liability'));
        await tester.pump();

        expect(find.text('This is a credit card'), findsOneWidget);

        await tester.enterText(find.widgetWithText(TextField, 'Name'), 'Visa');
        await tester.tap(find.text('This is a credit card'));
        await tester.pump();
        await tester.tap(find.widgetWithText(ElevatedButton, 'Create'));
        await tester.pumpAndSettle();

        verify(
          repository.createFinancialAccount(
            name: 'Visa',
            type: AccountType.liability,
            groupId: anyNamed('groupId'),
            openingBalanceMinor: null,
            isCreditCard: true,
          ),
        ).called(1);
      },
    );

    testWidgets('switching back to Asset clears the credit-card choice', (
      tester,
    ) async {
      final viewModel = AccountManagementViewModel(
        ledgerRepository: repository,
      );
      addTearDown(viewModel.dispose);

      await tester.pumpWidget(
        MaterialApp(home: AccountManagementView(viewModel: viewModel)),
      );
      await tester.pump();

      await tester.tap(find.byIcon(TablerIcons.plus));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Liability'));
      await tester.pump();
      await tester.tap(find.text('This is a credit card'));
      await tester.pump();
      await tester.tap(find.text('Asset'));
      await tester.pump();

      expect(find.text('This is a credit card'), findsNothing);
    });
  });
}
