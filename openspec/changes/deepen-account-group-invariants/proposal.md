## Why

`AccountManagementView` computes three real account/group invariants inline, in the widget layer, with no single owner:

- **Currency lock**: `_showRenameGroupDialog` (`account_management_view.dart:223-305`) computes `hasActiveAccounts` once (line 228) and checks it *twice* — to disable the currency `TextField` (line 247) and again as the save guard (line 288) — with nothing keeping the two checks in sync if one is edited without the other.
- **Type-scoped group list**: `_showCreateDialog` (lines 36-178) filters `viewModel.groups` to the `AccountGroupKind` matching the selected `AccountType`, and resets `groupId`/`isCreditCard`/`holdsInvestments` on type switch (lines 89-100) — "credit-card is liability-only, holdsInvestments is asset-only" expressed as widget-state resets.
- **Reassignment targets**: `_showReassignDialog` (lines 425-486) filters candidate groups to matching `kind` **and** `currency`, citing `multi-currency-support design.md`'s "moving an account to a different-currency group would retroactively reinterpret its historical balances" rule (lines 437-440) — a cross-feature domain rule expressed only as a `.where()` on a picker's item list.

`AccountManagementViewModel` is currently a clean pass-through (every method just calls `AccountRepository` and interprets exceptions) — none of these three rules has a unit-testable home; they're only reachable through `test/ui/features/account_management/views/account_management_view_test.dart`'s `testWidgets`.

## What Changes

- Add three pure functions to `AccountManagementViewModel`: `canChangeGroupCurrency(AccountGroup, List<Account>)`, `groupsAvailableForType(AccountType, List<AccountGroup>)`, `groupsAvailableForReassignment(Account, List<AccountGroup>)`.
- `_showRenameGroupDialog`'s currency `TextField.enabled` and its save guard both call `viewModel.canChangeGroupCurrency(...)` — one definition, not two.
- `_showCreateDialog`'s group picker and `_showReassignDialog`'s group picker call the corresponding view-model predicate instead of an inline `.where()`.
- Preserve existing create/rename/reassign behavior exactly — this is a locality change, not a product-behavior change.

## Capabilities

### New Capabilities
- `account-group-invariants`: unit-testable predicates for currency-lock, type-scoped group availability, and same-currency reassignment targets, owned by `AccountManagementViewModel`.

### Modified Capabilities
- (none — multi-account-support, multi-currency-support, and credit-card-household-flow product requirements unchanged)

## Impact

- `lib/ui/features/account_management/views/account_management_view.dart` (`_showCreateDialog`, `_showRenameGroupDialog`, `_showReassignDialog`)
- `lib/ui/features/account_management/view_models/account_management_view_model.dart`
- New unit tests on `AccountManagementViewModel` for the three predicates
- No Drift schema change; no ADR conflict
