## Purpose

One LedgerRepository method owning transfer ± optional fee composition, including the transfer-saved-fee-failed partial-failure story.

## Requirements

### Requirement: Transfer plus optional fee posts through one repository method
The system SHALL post a transfer and its optional source-account fee expense through a single `LedgerRepository` method. `TransferViewModel` MUST NOT call `recordTransfer` then `recordTransaction` separately for this flow.

#### Scenario: Fee failure after transfer still reports transfer-saved
- **WHEN** the transfer posts successfully and the fee expense fails
- **THEN** the method surfaces `validationTransferSavedFeeFailed` and does not roll back the transfer

#### Scenario: No fee posts only the transfer
- **WHEN** fee fields are absent
- **THEN** only the transfer is posted

### Requirement: Existing transfer fee behavior preserved
Composition extraction SHALL NOT change amounts, fee deduction, or error codes.

#### Scenario: Existing transfer ViewModel tests still pass
- **WHEN** `transfer_view_model_test.dart` runs after the migration
- **THEN** it passes, asserting the composed repository method
