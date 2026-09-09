# financial-account-draft

## Purpose

Flutter-free create-financial-account form state (asset/liability type,
target group, opening balance, credit-card / holds-investments flags) that
owns the field coupling and selection upkeep, consuming the ViewModel's
existing type-filtered group list rather than re-implementing it.

## Requirements

### Requirement: Create-financial-account form state lives behind one draft module
The system SHALL hold create-financial-account form state (asset/liability type, target group, optional opening balance, credit-card and holds-investments flags) in a Flutter-free `FinancialAccountDraft`, which also keeps the group selection valid and resolves the selected group's currency given the ViewModel's type-filtered group list. `AccountManagementView`'s create dialog MUST read those decisions from the draft rather than from scattered dialog-local state, and MUST source the group list from `AccountManagementViewModel.groupsAvailableForType` so the type-filter rule keeps one owner.

#### Scenario: Switching type clears the flag that no longer applies
- **WHEN** a draft with `holdsInvestments` true switches to liability type
- **THEN** `holdsInvestments` becomes false and the group selection is cleared; switching back to asset likewise clears `isCreditCard`

#### Scenario: Selection upkeep is unit-testable without a widget
- **WHEN** a test constructs a `FinancialAccountDraft` and calls `ensureValidGroupSelection` with a group list
- **THEN** `groupId` defaults to the first entry (or null when the list is empty) and `selectedGroupCurrency` returns the chosen group's currency, verifiable with `package:test` alone

### Requirement: Account creation stays behind AccountManagementViewModel
The draft SHALL NOT call `AccountRepository` or Drift, and SHALL NOT re-implement group type-filtering. `AccountManagementViewModel` SHALL remain the only caller of `createFinancialAccount` and the owner of `groupsAvailableForType`.

#### Scenario: Existing account-management tests still pass
- **WHEN** the account-management widget and ViewModel tests run after the migration
- **THEN** they pass without weakening assertions covering create, credit-card flow, and type switching
