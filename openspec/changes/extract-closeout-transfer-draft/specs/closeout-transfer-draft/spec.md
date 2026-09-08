## ADDED Requirements

### Requirement: Archived-account closeout form rules live behind one draft module
The system SHALL hold archived-account closeout form state (destination account and its currency, transaction date, description, and destination amount) in a Flutter-free `CloseoutTransferDraft`, which derives whether the move is cross-currency and which destination amount to submit. `RegisterView`'s closeout dialog MUST read those decisions from the draft rather than from scattered dialog-local state, and `RegisterViewModel` MUST keep `closeoutSelectedAccount` orchestration.

#### Scenario: Same-currency closeout submits no destination amount
- **WHEN** the source and destination accounts share a currency
- **THEN** `isCrossCurrency` is false and `destinationAmountForSubmit` is null even if an amount was entered, matching the full-balance move today

#### Scenario: Cross-currency closeout submits the entered destination amount
- **WHEN** the destination account has a different currency and an amount is entered
- **THEN** `isCrossCurrency` is true and `destinationAmountForSubmit` returns that amount

#### Scenario: Changing the destination account clears a stale amount
- **WHEN** the destination account changes
- **THEN** `setDestinationAccount` records the new account and currency and clears any destination amount entered for the previous pick

### Requirement: Closeout posting stays behind AccountRepository
The draft SHALL NOT call `AccountRepository` or Drift. The cross-currency "a known destination amount is required" rule SHALL remain enforced by `AccountRepository.recordArchivedAccountCloseoutTransfer` (error code `closeoutRequiresDestinationAmount`), unchanged by the extraction.

#### Scenario: Existing register tests still pass
- **WHEN** the register widget and ViewModel tests run after the migration
- **THEN** they pass without weakening assertions covering when closeout is offered and closeout success/failure surfacing
