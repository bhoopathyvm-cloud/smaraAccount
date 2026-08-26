## 1. Add predicates

- [ ] 1.1 `AccountManagementViewModel.canChangeGroupCurrency(AccountGroup group)` — ports `hasActiveAccounts` from `_showRenameGroupDialog`, reading `accounts`
- [ ] 1.2 `AccountManagementViewModel.groupsAvailableForType(AccountType type)` — ports the `kind`-filtered `.where()` from `_showCreateDialog`
- [ ] 1.3 `AccountManagementViewModel.groupsAvailableForReassignment(Account account)` — ports the `kind` + `currency` filter from `_showReassignDialog`
- [ ] 1.4 Unit tests for all three: currency-lock with/without active accounts, type filter for asset vs. liability, reassignment filter across mismatched kind/currency/archived groups

## 2. Migrate the View

- [ ] 2.1 `_showRenameGroupDialog`: replace both `hasActiveAccounts` checks with `viewModel.canChangeGroupCurrency(group)`
- [ ] 2.2 `_showCreateDialog`: replace the inline group filter with `viewModel.groupsAvailableForType(type)`
- [ ] 2.3 `_showReassignDialog`: replace the inline group filter with `viewModel.groupsAvailableForReassignment(account)`

## 3. Verify

- [ ] 3.1 `dart analyze` clean; new ViewModel unit tests green
- [ ] 3.2 Existing `account_management_view_test.dart` widget tests still green, no assertions weakened
