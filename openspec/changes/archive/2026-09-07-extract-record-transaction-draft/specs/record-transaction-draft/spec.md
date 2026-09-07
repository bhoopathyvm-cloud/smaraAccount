## ADDED Requirements

### Requirement: Record-transaction form rules live behind one draft module
The system SHALL determine split remainder, foreign-currency visibility, paid-from-card/bank financial-account picker filters, direction-scoped category filtering, payee suggestion matching, and single/split submit readiness through a Flutter-free draft module (`RecordTransactionDraft` with `SplitLine`). `RecordTransactionView` MUST continue to read those decisions via `RecordTransactionViewModel`, which forwards to the draft rather than branching on inlined form state.

#### Scenario: Split remainder is total minus allocated lines
- **WHEN** a `RecordTransactionDraft` has `amountMinor` 1000 and two split lines with amounts 400 and 600
- **THEN** `splitRemainderMinor` is 0

#### Scenario: Foreign currency visibility requires native ≠ account currency
- **WHEN** a draft's `nativeCurrency` is set and differs from the selected account's currency
- **THEN** `isForeignCurrency` is true; when native is null or equals the account currency, it is false

#### Scenario: Paid-from-card narrows picker options to credit cards
- **WHEN** `selectPaidFromCard` is active on a draft whose catalog includes card and non-card financial accounts
- **THEN** `financialAccountOptions` contains only credit-card accounts

#### Scenario: Draft readiness is unit-testable without a ChangeNotifier
- **WHEN** a test constructs a `RecordTransactionDraft` directly and sets its fields
- **THEN** `canSubmitSingle` / `canSubmitSplit` (and incomplete-line / nonzero-remainder checks) reflect the same missing-field rules the ViewModel enforces before calling the ledger, verifiable with `package:test` alone

### Requirement: Submission stays behind RecordTransactionViewModel
The draft module SHALL NOT call `LedgerRepository`, `PayeeRepository`, or Drift directly. `RecordTransactionViewModel` SHALL remain the only caller of `recordTransaction` / `recordSplitTransaction` / `recordPayeeUsage`, reading fields from the draft.

#### Scenario: ViewModel submits from draft fields
- **WHEN** the ViewModel's `submit` succeeds for a ready single-line draft
- **THEN** it calls `LedgerRepository.recordTransaction` with the draft's amount, direction, category, account, date, description, and foreign-currency fields, and surfaces the same failure codes as today on validation/ledger errors

### Requirement: Existing record-transaction behavior preserved
Extracting the draft SHALL NOT change which fields are visible, which validation error codes fire, or what gets posted for any existing single, split, credit-card-shortcut, or foreign-currency record flow.

#### Scenario: Existing ViewModel tests still pass
- **WHEN** `record_transaction_view_model_test.dart` runs after the migration
- **THEN** it passes without weakening assertions covering submit, payee usage, split collapse, and shortcut filtering
