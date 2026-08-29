## 1. Guard HoldingsViewModel

- [ ] 1.1 Add `bool _disposed = false;` to `HoldingsViewModel` and set it as the first statement of `dispose()` (`lib/ui/features/holdings/view_models/holdings_view_model.dart`)
- [ ] 1.2 In the `async` `_holdingsSub` listener, after `await _ledgerRepository.displayBalanceMinor(...)` and after `await _refreshQuotes()`, `if (_disposed) return;` before assigning state / calling `notifyListeners`
- [ ] 1.3 Wrap the awaited `displayBalanceMinor` (and the `_refreshQuotes` body) in `try/catch` that rethrows only when `!_disposed`
- [ ] 1.4 Add `void _ignoreError(Object error, [StackTrace? stackTrace]) {}` and pass it as `onError:` to all six `listen(...)` calls (`_accountsSub`, `_holdingsSub`, `_instrumentsSub`, `_heldInstrumentsSub`, `_categoriesSub`, `_currenciesSub`)

## 2. Test

- [ ] 2.1 Unit test: a controllable future for `displayBalanceMinor`; emit on the holdings stream, call `dispose()`, then complete the future — assert no exception escapes and no `notifyListeners` after dispose
- [ ] 2.2 Unit test: a stream error delivered while the view model is alive still propagates (is not swallowed)
- [ ] 2.3 Existing `holdings_view_model_test.dart` cases still pass unchanged

## 3. Verify

- [ ] 3.1 `flutter analyze` clean; `flutter test` green
- [ ] 3.2 `investment_holdings_test.dart` / `investment_research_test.dart` acceptance files still green on macOS (the teardown race no longer logs an unhandled error between tests)
