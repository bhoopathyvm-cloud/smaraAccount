## Why

`lib/domain/investment/trade_order_draft.dart` imports `data/repositories/investment_holdings_logic.dart` for `BuyFundingSource` and `multiplyScaledQuantityPrice` — clear seam leakage. That data file mixes pure lot replay / valuation with Drift loaders. Architecture review cycle 3: lift the pure module into domain so Home/Holdings/drafts share one leaf without domain→data dependency.

## What Changes

- Move pure types and functions (`BuyFundingSource`, replay types, `multiplyScaledQuantityPrice`, `replayInvestmentHistory`, quote valuation helpers, quantity format/parse, `InvestmentHoldingMetrics`) to `lib/domain/investment/investment_holdings.dart`.
- Keep Drift loaders (`loadInvestmentReplayEvents`, `computeInstrumentHoldingsForAccount`, `quotesByInstrumentId`, `reversedOriginalEntryIds`) and `toInstrumentHolding` (needs `InstrumentRow`) in `lib/data/repositories/investment_holdings_logic.dart`, importing the domain module.
- Update `trade_order_draft.dart` and other callers to import domain for pure symbols.
- Add `package:test` unit tests for replay and valuation.

## Capabilities

### New Capabilities
- `investment-holdings-domain`: Flutter- and Drift-free investment lot replay, scaled-price math, and quote valuation module.

### Modified Capabilities
- (none — holdings product behavior unchanged)

## Impact

- `lib/domain/investment/investment_holdings.dart` (new)
- `lib/domain/investment/trade_order_draft.dart`
- `lib/data/repositories/investment_holdings_logic.dart`
- Call sites importing `BuyFundingSource` / pure helpers
- New `test/domain/investment/investment_holdings_test.dart`
- ADR 0002: data loaders remain cycle-free leaves on `AppDatabase`
