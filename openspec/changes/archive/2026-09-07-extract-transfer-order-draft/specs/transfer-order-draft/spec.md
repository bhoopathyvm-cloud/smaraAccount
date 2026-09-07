## ADDED Requirements

### Requirement: Transfer form rules live behind one draft module
The system SHALL determine cross-currency visibility, fee-deducted transfer amount, implied rate, and transfer submit readiness through a Flutter-free `TransferOrderDraft`. `TransferView` MUST continue to read those decisions via `TransferViewModel`, which forwards to the draft.

#### Scenario: Fee deducted from amount reduces transfer amount
- **WHEN** a draft has `amountMinor` 10000, `feeAmountMinor` 162, and `feeDeductedFromAmount` true
- **THEN** `transferAmountMinor` is 9838

#### Scenario: Implied rate uses converted amount after fee deduction
- **WHEN** a cross-currency draft has fee deducted from amount and both amounts set
- **THEN** `impliedRate` divides destination major units by `(amount - fee)` major units, not the full amount

#### Scenario: Draft readiness is unit-testable without a ChangeNotifier
- **WHEN** a test constructs a `TransferOrderDraft` and sets fields
- **THEN** readiness helpers reflect the same missing-field and fee rules the ViewModel enforces before calling the ledger

### Requirement: Submission and reference-rate fetch stay behind TransferViewModel
The draft SHALL NOT call `LedgerRepository`, `ExchangeRateService`, or Drift. `TransferViewModel` SHALL remain the only caller of `recordTransfer` / fee `recordTransaction`, and SHALL own reference-rate fetch I/O.

#### Scenario: Transfer-then-fee partial failure unchanged
- **WHEN** `recordTransfer` succeeds and fee `recordTransaction` fails
- **THEN** the ViewModel surfaces `validationTransferSavedFeeFailed` and does not roll back the transfer, same as today

### Requirement: Existing transfer behavior preserved
Extracting the draft SHALL NOT change validation error codes or what gets posted for same-currency, cross-currency, or fee transfer flows.

#### Scenario: Existing ViewModel tests still pass
- **WHEN** `transfer_view_model_test.dart` runs after the migration
- **THEN** it passes without weakening assertions
