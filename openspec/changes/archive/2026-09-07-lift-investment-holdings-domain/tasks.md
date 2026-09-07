## 1. Domain module

- [x] 1.1 Move pure types/functions from `investment_holdings_logic.dart` to `lib/domain/investment/investment_holdings.dart`
- [x] 1.2 Unit tests: `multiplyScaledQuantityPrice`, replay buy/sell/lock, `valueHolding` / `quoteUseFor`
- [x] 1.3 Update `trade_order_draft.dart` to import domain only

## 2. Data adapters + call sites

- [x] 2.1 Slim `investment_holdings_logic.dart` to Drift loaders + `toInstrumentHolding`
- [x] 2.2 Update repository/UI/test imports for pure vs loader symbols

## 3. Verify

- [x] 3.1 `dart analyze` clean; domain + investment_holdings tests green
- [x] 3.2 Full acceptance suite on macOS
