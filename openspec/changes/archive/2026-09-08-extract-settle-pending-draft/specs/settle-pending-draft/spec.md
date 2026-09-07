## ADDED Requirements

### Requirement: Settle-pending form rules live behind one draft module
The system SHALL determine shortfall comparability, shortfall amount, and settled-amount currency through a Flutter-free `SettlePendingDraft`. The ViewModel MUST forward those decisions.

#### Scenario: Shortfall comparable only when transfer settles to source
- **WHEN** a transfer's settled-to account is its source account
- **THEN** `isShortfallComparable` is true and `shortfallMinor` is max(0, provisional - settled)

#### Scenario: Draft readiness is unit-testable without a ChangeNotifier
- **WHEN** a test constructs a `SettlePendingDraft` from a summary
- **THEN** shortfall and currency getters are asserted with `package:test` alone

### Requirement: Existing settle behavior preserved
Extracting the draft SHALL NOT change validation or posting.

#### Scenario: Existing settle ViewModel tests still pass
- **WHEN** settle ViewModel tests run after the migration
- **THEN** they pass without weakening assertions
