## 1. Fix

- [x] 1.1 Add a `_disposed` flag to `RegisterViewModel`, set it in `dispose()`, and return early from every async continuation (`watchCategories(...).then`, any other pending `.then`/`await` that calls `_recompute`/`notifyListeners`) when it is set
- [x] 1.2 Change the one-shot categories read in `_onAccounts` so an empty/closed stream yields "no categories" instead of throwing `StateError`

## 2. Test

- [x] 2.1 Unit test: accounts stream emits, then the view model is disposed and the categories stream closes without emitting — no exception escapes, no `notifyListeners` after dispose
- [x] 2.2 Unit test: categories stream that emits normally still enriches rows with category names (no behaviour regression)

## 3. Verify

- [x] 3.1 `flutter test` green
- [x] 3.2 `core_ledger_test.dart` runs green across repeat runs (the late `Bad state: No element` no longer appears) — verified on the Linux desktop target in this agent (`flutter test integration_test/acceptance/core_ledger_test.dart -d linux`, 4 green runs; Android hardware unavailable here). The fixed teardown race is a platform-independent Dart `Stream.first`/async-continuation path, so the Linux run exercises the identical code.

## 4. Follow-up

- [x] 4.1 Consider a short audit of other view models for the same "async continuation after dispose" pattern
  - `RegisterViewModel.watchCategories(...).first.then` was the only repository-stream `.first.then`.
  - `HoldingsViewModel` fires `isMarketPriceFetchEnabled().then` without a disposed check (can `notifyListeners` after dispose).
  - `TransferViewModel` already guards the same class of continuation with `_isDisposed`.
  - Broader sweep left as a future change (design.md non-goal).
