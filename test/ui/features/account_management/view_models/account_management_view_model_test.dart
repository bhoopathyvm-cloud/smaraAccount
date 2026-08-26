import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:smara_accounting/domain/models/account.dart';
import 'package:smara_accounting/domain/models/account_group.dart';
import 'package:smara_accounting/ui/features/account_management/view_models/account_management_view_model.dart';

import '../../../../mocks.mocks.dart';

void main() {
  late MockAccountRepository repository;
  late AccountManagementViewModel viewModel;

  const cashUsd = AccountGroup(
    id: 'group-cash',
    name: 'Cash',
    kind: AccountGroupKind.assetGroup,
    sortOrder: 0,
    isSystem: true,
    currency: 'USD',
    archived: false,
  );
  const creditUsd = AccountGroup(
    id: 'group-credit',
    name: 'Credit',
    kind: AccountGroupKind.liabilityGroup,
    sortOrder: 1,
    isSystem: true,
    currency: 'USD',
    archived: false,
  );
  const investmentsEur = AccountGroup(
    id: 'group-investments-eur',
    name: 'Investments EUR',
    kind: AccountGroupKind.assetGroup,
    sortOrder: 2,
    isSystem: false,
    currency: 'EUR',
    archived: false,
  );
  const archivedAsset = AccountGroup(
    id: 'group-archived',
    name: 'Old',
    kind: AccountGroupKind.assetGroup,
    sortOrder: 3,
    isSystem: false,
    currency: 'USD',
    archived: true,
  );

  const checking = Account(
    id: 'asset-1',
    name: 'Checking',
    type: AccountType.asset,
    archived: false,
    groupId: 'group-cash',
  );
  const archivedChecking = Account(
    id: 'asset-2',
    name: 'Old checking',
    type: AccountType.asset,
    archived: true,
    groupId: 'group-investments-eur',
  );
  const emptyGroupAccountAbsent = AccountGroup(
    id: 'group-empty',
    name: 'Empty',
    kind: AccountGroupKind.assetGroup,
    sortOrder: 4,
    isSystem: false,
    currency: 'USD',
    archived: false,
  );

  setUp(() async {
    repository = MockAccountRepository();
    when(
      repository.watchFinancialAccounts(
        includeArchived: anyNamed('includeArchived'),
      ),
    ).thenAnswer((_) => Stream.value([checking, archivedChecking]));
    when(
      repository.watchAccountGroups(
        includeArchived: anyNamed('includeArchived'),
      ),
    ).thenAnswer(
      (_) => Stream.value([
        cashUsd,
        creditUsd,
        investmentsEur,
        archivedAsset,
        emptyGroupAccountAbsent,
      ]),
    );
    viewModel = AccountManagementViewModel(accountRepository: repository);
    await Future<void>.delayed(Duration.zero);
  });

  tearDown(viewModel.dispose);

  group('canChangeGroupCurrency', () {
    test('is false when the group has an active account', () {
      expect(viewModel.canChangeGroupCurrency(cashUsd), isFalse);
    });

    test('is true when the group has only archived accounts', () {
      expect(viewModel.canChangeGroupCurrency(investmentsEur), isTrue);
    });

    test('is true when the group has no accounts', () {
      expect(viewModel.canChangeGroupCurrency(emptyGroupAccountAbsent), isTrue);
    });
  });

  group('groupsAvailableForType', () {
    test('offers only active asset groups for an asset account', () {
      final groups = viewModel.groupsAvailableForType(AccountType.asset);
      expect(groups.map((g) => g.id), [
        'group-cash',
        'group-investments-eur',
        'group-empty',
      ]);
    });

    test('offers only active liability groups for a liability account', () {
      final groups = viewModel.groupsAvailableForType(AccountType.liability);
      expect(groups.map((g) => g.id), ['group-credit']);
    });
  });

  group('groupsAvailableForReassignment', () {
    test('excludes a different-currency group', () {
      final groups = viewModel.groupsAvailableForReassignment(checking);
      expect(groups.map((g) => g.id), ['group-cash', 'group-empty']);
      expect(groups.any((g) => g.currency == 'EUR'), isFalse);
    });

    test('excludes a mismatched kind', () {
      final groups = viewModel.groupsAvailableForReassignment(checking);
      expect(
        groups.any((g) => g.kind == AccountGroupKind.liabilityGroup),
        isFalse,
      );
    });

    test('excludes archived groups', () {
      final groups = viewModel.groupsAvailableForReassignment(checking);
      expect(groups.any((g) => g.archived), isFalse);
    });
  });
}
