# financial-account-draft

## Purpose

Flutter-free create-financial-account form state (asset/liability type,
target group, opening balance, credit-card / holds-investments flags) with
type-scoped group filtering and selection upkeep, owned by the create
dialog.

## Requirements

### Requirement: Create-financial-account form rules live behind one draft module
The system SHALL hold create-financial-account form state (asset/liability type, target group, optional opening balance, credit-card and holds-investments flags) in a Flutter-free `FinancialAccountDraft`, which also derives the groups valid for the current type, the selected group's currency, and keeps the selection valid as the type changes. `AccountManagementView`'s create dialog MUST read those decisions from the draft rather than from scattered dialog-local state.

#### Scenario: Groups are filtered to the current account type
- **WHEN** a draft's `type` is asset
- **THEN** `groupsForType` lists only active asset groups (and only active liability groups when the type is liability)

#### Scenario: Switching type clears the flag that no longer applies
- **WHEN** a draft with `holdsInvestments` true switches to liability type
- **THEN** `holdsInvestments` becomes false and the group selection is cleared; switching back to asset likewise clears `isCreditCard`

#### Scenario: Draft readiness is unit-testable without a widget
- **WHEN** a test constructs a `FinancialAccountDraft`, supplies a group snapshot, and calls `ensureValidGroupSelection`
- **THEN** `hasSelectedGroup` and `selectedGroupCurrency` reflect the same auto-selection the dialog relied on inline, verifiable with `package:test` alone

### Requirement: Account creation stays behind AccountManagementViewModel
The draft SHALL NOT call `AccountRepository` or Drift. `AccountManagementViewModel` SHALL remain the only caller of `createFinancialAccount`, reading fields from the draft.

#### Scenario: Existing account-management tests still pass
- **WHEN** the account-management widget and ViewModel tests run after the migration
- **THEN** they pass without weakening assertions covering create, credit-card flow, and type switching
