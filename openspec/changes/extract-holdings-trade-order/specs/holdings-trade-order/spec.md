## ADDED Requirements

### Requirement: Trade-draft visibility and readiness rules live behind one module
The system SHALL determine buy/sell/dividend field visibility (income-category field for non-cash buys, brokerage fields for cash buys, gain-category vs. loss-category for a sell, held-instrument list for a dividend) and submit readiness through a Flutter-free draft module (`BuyOrderDraft` / `SellOrderDraft` / `DividendOrderDraft`). `HoldingsView` MUST read those decisions from the draft rather than branching on local dialog state.

#### Scenario: Buy draft hides brokerage for non-cash funding
- **WHEN** a `BuyOrderDraft`'s funding source is non-cash
- **THEN** `requiresIncomeCategory` is true and `requiresBrokerageCategory` is false, matching what the dialog shows

#### Scenario: Sell draft requires a category matching the gain/loss sign
- **WHEN** a `SellOrderDraft`'s computed gain/loss is positive
- **THEN** `requiresIncomeCategory` is true and `requiresExpenseCategory` is false; the reverse holds for a negative gain/loss, and neither is required at zero

#### Scenario: Draft readiness is unit-testable without a widget tree
- **WHEN** a test constructs a `BuyOrderDraft`/`SellOrderDraft`/`DividendOrderDraft` directly and sets its fields
- **THEN** `canSubmit` reflects the same missing-field rules `HoldingsView`'s submit button currently enforces, verifiable with `package:test` alone

### Requirement: Trade submission stays behind HoldingsViewModel
The draft module SHALL NOT call `InvestmentRepository` or Drift directly. `HoldingsViewModel` SHALL remain the only caller of `InvestmentRepository.recordBuy`/`recordSell`/`recordDividend`, now taking a draft's fields as input.

#### Scenario: ViewModel submits from a draft
- **WHEN** `HoldingsView` calls `viewModel.submitBuy(draft)` with a ready `BuyOrderDraft`
- **THEN** `HoldingsViewModel` calls `InvestmentRepository.recordBuy` with the draft's fields and surfaces any `InvestmentException` the same way `recordBuy` does today

### Requirement: Existing trade behavior preserved
Extracting the draft SHALL NOT change which fields are visible, which categories are required, or what gets posted for any existing buy/sell/dividend flow.

#### Scenario: Widget tests still pass
- **WHEN** `holdings_view_test.dart` runs after the migration
- **THEN** it passes without weakening any assertion, and gains at least one new case covering funding-source field visibility
