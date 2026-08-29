## 1. Guard HoldingsViewModel

- [x] 1.1 Add `bool _disposed = false;` to `HoldingsViewModel` and set it as the first statement of `dispose()` (`lib/ui/features/holdings/view_models/holdings_view_model.dart`)
- [x] 1.2 In the `async` `_holdingsSub` listener, after `await _ledgerRepository.displayBalanceMinor(...)` and after `await _refreshQuotes()`, `if (_disposed) return;` before assigning state / calling `notifyListeners`
- [x] 1.3 Wrap the awaited `displayBalanceMinor` (and the `_refreshQuotes` body) in `try/catch` that rethrows only when `!_disposed`
- [x] 1.4 Add `_ignoreError` and pass it as `onError:` to all six `listen(...)` calls (`_accountsSub`, `_holdingsSub`, `_instrumentsSub`, `_heldInstrumentsSub`, `_categoriesSub`, `_currenciesSub`). Note: per this change's spec scenario "Errors while the view model is alive still surface" (and task 2.2), `_ignoreError` no-ops only when `_disposed` and otherwise rethrows — the pure-`{}` form sketched in design.md would swallow live errors, so the rethrow-when-alive form is used.

## 2. Test

- [x] 2.1 Unit test: a controllable future for `displayBalanceMinor`; emit on the holdings stream, call `dispose()`, then complete the future — assert no exception escapes and no `notifyListeners` after dispose (`test/ui/features/holdings/view_models/holdings_view_model_test.dart`; confirmed to fail without the guard via a negative control)
- [x] 2.2 Unit test: a stream error delivered while the view model is alive still propagates (is not swallowed)
- [x] 2.3 Existing holdings view/view-model tests still pass unchanged (`holdings_view_test.dart` — no `holdings_view_model_test.dart` existed before this change; it is added here)

## 3. Verify

- [x] 3.1 `flutter analyze` clean; `flutter test` green (Flutter 3.47.1)
- [x] 3.2 `investment_holdings_test.dart` / `investment_research_test.dart` acceptance files green — run on the Linux desktop target in this agent (`flutter test <file> -d linux`; macOS/Android hardware unavailable here). Both pass (investment_holdings 12/12, investment_research 2/2) with the change applied; the teardown race no longer logs an unhandled error between tests.
