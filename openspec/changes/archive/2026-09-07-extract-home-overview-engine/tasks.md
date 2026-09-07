## 1. Engine

- [x] 1.1 Add `lib/domain/home/home_overview_engine.dart` with `investmentPortfolioTotals` and `buildHomeOverview`
- [x] 1.2 Unit tests for sections, pending quarantine exclusion, investment portfolio display

## 2. Wire callers

- [x] 2.1 `LedgerRepository._buildHomeOverview` uses the engine
- [x] 2.2 `HoldingsViewModel` uses `investmentPortfolioTotals`

## 3. Verify

- [x] 3.1 analyze + unit tests green
- [x] 3.2 Full macOS acceptance
