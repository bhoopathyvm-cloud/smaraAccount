## ADDED Requirements

### Requirement: Investment holdings pure logic lives in domain
The system SHALL implement lot replay, scaled quantity×price math, quote usability/valuation, and buy-funding-source typing in a Flutter- and Drift-free domain module. Domain modules (including trade-order drafts) MUST NOT import `data/repositories` for these rules.

#### Scenario: Domain draft imports domain only
- **WHEN** `trade_order_draft.dart` references `BuyFundingSource` or `multiplyScaledQuantityPrice`
- **THEN** those symbols resolve from `lib/domain/investment/`, not from a data repository file

#### Scenario: Replay is unit-testable without Drift
- **WHEN** a test constructs `InvestmentReplayEvent`s and calls `replayInvestmentHistory`
- **THEN** metrics (quantity, cost, sellable/locked) are asserted with `package:test` alone

### Requirement: Drift loaders remain data adapters
Loading lots/sells/quotes from `AppDatabase` and mapping `InstrumentRow` into holdings SHALL remain in the data module, calling domain replay/valuation.

#### Scenario: Holdings computation still uses shared loaders
- **WHEN** `InvestmentRepository` or `LedgerRepository` computes holdings for an account
- **THEN** they continue to use the shared data loaders (ADR 0002 leaf), which call domain `replayInvestmentHistory` / `valueHolding`

### Requirement: Holdings behavior preserved
Lifting the pure module SHALL NOT change buy/sell/lock/quote valuation outcomes.

#### Scenario: Existing investment holdings repository tests still pass
- **WHEN** `investment_holdings_test.dart` runs after the migration
- **THEN** it passes without weakening assertions
