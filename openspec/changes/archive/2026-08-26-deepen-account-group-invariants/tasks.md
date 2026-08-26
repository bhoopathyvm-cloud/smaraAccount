## 1. Add predicates

- [x] 1.1 `AccountManagementViewModel.canChangeGroupCurrency(AccountGroup group)` — ports `hasActiveAccounts` from `_showRenameGroupDialog`, reading `accounts`
- [x] 1.2 `AccountManagementViewModel.groupsAvailableForType(AccountType type)` — ports the `kind`-filtered `.where()` from `_showCreateDialog`
- [x] 1.3 `AccountManagementViewModel.groupsAvailableForReassignment(Account account)` — ports the `kind` + `currency` filter from `_showReassignDialog`
- [x] 1.4 Unit tests for all three: currency-lock with/without active accounts, type filter for asset vs. liability, reassignment filter across mismatched kind/currency/archived groups

## 2. Migrate the View

- [x] 2.1 `_showRenameGroupDialog`: replace both `hasActiveAccounts` checks with `viewModel.canChangeGroupCurrency(group)`
- [x] 2.2 `_showCreateDialog`: replace the inline group filter with `viewModel.groupsAvailableForType(type)`
- [x] 2.3 `_showReassignDialog`: replace the inline group filter with `viewModel.groupsAvailableForReassignment(account)`

## 3. Verify

- [x] 3.1 `dart analyze` clean; new ViewModel unit tests green
- [x] 3.2 Existing `account_management_view_test.dart` widget tests still green, no assertions weakened
