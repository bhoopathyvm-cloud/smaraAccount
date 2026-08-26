# account-group-invariants

## Purpose

TBD

## Requirements

### Requirement: Currency-lock has one definition
The system SHALL determine whether an account group's currency can change through a single `AccountManagementViewModel.canChangeGroupCurrency` predicate. `AccountManagementView` MUST use that predicate both to enable/disable the currency field and to guard the save action — no inline duplicate of the active-accounts check.

#### Scenario: Currency field and save guard agree
- **WHEN** an account group has at least one active (non-archived) account
- **THEN** `canChangeGroupCurrency` returns false, and both the rename-group dialog's currency field and its save action are disabled for the same reason

### Requirement: Group availability is type- and currency-scoped through one seam
The system SHALL expose `groupsAvailableForType` (asset groups for asset accounts, liability groups for liability accounts) and `groupsAvailableForReassignment` (same `kind` and same `currency` as the account's current group) as `AccountManagementViewModel` predicates. `AccountManagementView`'s create and reassign dialogs MUST use them instead of inline `.where()` filters.

#### Scenario: Create dialog only offers matching-kind groups
- **WHEN** the create-account dialog's type is set to Liability
- **THEN** `groupsAvailableForType(AccountType.liability)` returns only liability groups, matching what the dialog's group picker shows

#### Scenario: Reassignment never offers a different-currency group
- **WHEN** an account's current group has currency `USD`
- **THEN** `groupsAvailableForReassignment` excludes any group with a different currency, preserving the no-retroactive-reinterpretation rule from `multi-currency-support`

### Requirement: Existing create/rename/reassign behavior preserved
Extracting these predicates SHALL NOT change which groups are offered or when currency edits are allowed, for any existing account-management flow.

#### Scenario: Widget tests still pass
- **WHEN** `account_management_view_test.dart` runs after the migration
- **THEN** it passes without weakening any assertion
