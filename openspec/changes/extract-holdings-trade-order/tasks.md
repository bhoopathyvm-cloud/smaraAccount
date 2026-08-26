## 1. Draft module

- [ ] 1.1 Inventory every local `var`/branch in `_showBuyDialog`, `_showSellDialog`, `_showDividendDialog` that encodes a domain rule (funding-source visibility, gain/loss-sign category, create-then-buy chaining, held-instrument filtering)
- [ ] 1.2 Add `lib/domain/investment/trade_order_draft.dart` with `BuyOrderDraft`, `SellOrderDraft`, `DividendOrderDraft`
- [ ] 1.3 Unit tests (`test/domain/investment/trade_order_draft_test.dart`): funding-source visibility, gain/loss sign → category requirement (positive/negative/zero), `canSubmit` for each missing-field case

## 2. Wire HoldingsViewModel

- [ ] 2.1 Add `newBuyDraft()` / `newSellDraft()` / `newDividendDraft()` factories seeding today's dialog defaults
- [ ] 2.2 Add `submitBuy(BuyOrderDraft)` / `submitSell(SellOrderDraft)` / `submitDividend(DividendOrderDraft)`, calling the existing `_investmentRepository.record*` methods and reusing `_run`'s error handling
- [ ] 2.3 Keep `recordBuy`/`recordSell`/`recordDividend`/`sellGainLossMinor` only as long as `holdings_view.dart` still calls them; delete once step 3 removes the last caller

## 3. Migrate the View

- [ ] 3.1 `_showBuyDialog` binds controllers/toggles to a `BuyOrderDraft`; delete its local `var`s
- [ ] 3.2 `_showSellDialog` binds to a `SellOrderDraft`; delete its local `var`s and inline gain/loss branching
- [ ] 3.3 `_showDividendDialog` binds to a `DividendOrderDraft`; delete its local `var`s
- [ ] 3.4 Delete `HoldingsViewModel.recordBuy`/`recordSell`/`recordDividend`/`sellGainLossMinor` once no longer called

## 4. Verify

- [ ] 4.1 `dart analyze` clean; new draft unit tests green
- [ ] 4.2 Existing `holdings_view_test.dart` widget tests still green; add a widget test that opens the Buy dialog and asserts brokerage fields hide for non-cash funding (closes the current coverage gap)
- [ ] 4.3 Spot-check acceptance-investment-holdings on macOS
