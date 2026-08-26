## Why

`HoldingsView` (862 lines) owns the trade-entry rules for buy/sell/dividend as local variables and branches inside `StatefulBuilder` closures, not behind any interface a test can call directly:

- `_showBuyDialog` (`holdings_view.dart:234-487`) toggles brokerage vs. income-category fields on `funding == BuyFundingSource.nonCash`, and chains "create instrument, then buy" as two sequential calls.
- `_showSellDialog` (`holdings_view.dart:489-670`) recomputes `viewModel.sellGainLossMinor` on every keystroke and shows the income- or expense-category picker based on the sign of the result.
- `_showDividendDialog` sources instruments from `heldInstruments` rather than the global instrument list — a real domain rule ("only instruments this account has ever bought are dividend-eligible") expressed only as which list a picker widget is given.

`InvestmentRepository.recordBuy`/`recordSell` (`investment_repository.dart:234-267`) re-validate the same funding-source and category rules server-side, but the two definitions can drift: the dialog decides what to *show*, the repository decides what to *accept*, and nothing keeps them in sync.

`test/ui/features/holdings/views/holdings_view_test.dart` (214 lines) never opens the Buy or Sell dialog. The funding-source and gain/loss-sign branching has zero test coverage, direct or indirect.

## What Changes

- Add a Flutter-free `lib/domain/investment/trade_order_draft.dart` with `BuyOrderDraft`, `SellOrderDraft`, and `DividendOrderDraft` — mutable draft classes (same shape as `lib/domain/statement_import/statement_import_session.dart`'s `CsvMappingDraft`) holding the fields a trade dialog currently keeps as local `var`s, plus computed `requiresIncomeCategory`, `requiresBrokerageCategory`, `gainLossMinor`, `canSubmit`.
- `HoldingsViewModel` owns one draft instance per open dialog (created via a `newBuyDraft()` / `newSellDraft()` / `newDividendDraft()` factory that seeds the same defaults the dialogs use today — e.g. `holding = viewModel.holdings.first`), exposes it read-only, and forwards a `submitBuy(draft)` / `submitSell(draft)` / `submitDividend(draft)` that call the existing `_investmentRepository.recordBuy`/`recordSell`/`recordDividend` with the draft's fields.
- `HoldingsView`'s dialogs bind text controllers to draft field setters and use the draft's `requiresIncomeCategory` / `requiresBrokerageCategory` / `gainLossMinor` getters for field visibility, instead of local `var funding` / `var quantityScaled` / inline sign checks.
- Preserve existing field visibility, validation, and error behavior — this is a locality change, not a product-behavior change.

## Capabilities

### New Capabilities
- `holdings-trade-order`: a Flutter-free draft module for the buy/sell/dividend order fields, funding-source and gain/loss-sign visibility rules, and submit readiness — testable with `package:test`, without pumping a widget tree.

### Modified Capabilities
- (none — investment-holdings and investment-research-enablement product behavior unchanged)

## Impact

- `lib/ui/features/holdings/views/holdings_view.dart` (`_showBuyDialog`, `_showSellDialog`, `_showDividendDialog`)
- `lib/ui/features/holdings/view_models/holdings_view_model.dart` (`recordBuy`, `recordSell`, `recordDividend`, `sellGainLossMinor`)
- New `lib/domain/investment/trade_order_draft.dart`
- New `test/domain/investment/trade_order_draft_test.dart`
- `test/ui/features/holdings/views/holdings_view_test.dart` (dialog interaction still exercised through widget tests; branching logic itself now also unit-tested)
- No Drift schema change; no ADR conflict
