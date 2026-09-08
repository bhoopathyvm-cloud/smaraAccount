## ADDED Requirements

### Requirement: Investment trade writes live behind a posting module
The system SHALL post buys, sells, and dividends through an `InvestmentTradePosting` module constructed by `InvestmentRepository`. Instrument/quote/holdings reads MAY remain on the repository facade; trade validation, legs, lot/sell rows, and brokerage follow-up MUST NOT remain inlined on the facade.

#### Scenario: Public buy/sell/dividend API unchanged
- **WHEN** callers invoke `InvestmentRepository.recordBuy` / `recordSell` / `recordDividend`
- **THEN** behavior matches the pre-extract implementation (including brokerage partial-failure codes)
