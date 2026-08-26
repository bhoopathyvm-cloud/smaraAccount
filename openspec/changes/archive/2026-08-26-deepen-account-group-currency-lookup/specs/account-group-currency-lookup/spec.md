## ADDED Requirements

### Requirement: One account→group currency lookup seam
The system SHALL resolve an account's group currency through `AccountRepository` (or one catalog read model behind that package), not via duplicated joins of financial-account and account-group streams in feature view models.

#### Scenario: Transaction flows share the lookup
- **WHEN** record-transaction, register, transfer, settle-pending-transfer, or recurring-template management needs an account's currency
- **THEN** it obtains currency from the shared account→group currency lookup rather than a local `currencyFor` join copy

#### Scenario: Statement import uses the same lookup
- **WHEN** statement import needs the target account's group currency for preview checks
- **THEN** it uses the same repository/catalog lookup, not a separate `groupCurrencyFor` implementation

### Requirement: Cross-currency behavior preserved
Deepening the lookup SHALL NOT change when transfers or settlements treat currencies as matching or foreign.

#### Scenario: Existing transfer currency unit tests pass
- **WHEN** transfer and settle-pending view-model tests run after migration
- **THEN** they pass with construction updated to the shared lookup
