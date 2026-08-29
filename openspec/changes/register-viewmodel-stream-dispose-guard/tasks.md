## 1. Fix

- [ ] 1.1 Add a `_disposed` flag to `RegisterViewModel`, set it in `dispose()`, and return early from every async continuation (`watchCategories(...).then`, any other pending `.then`/`await` that calls `_recompute`/`notifyListeners`) when it is set
- [ ] 1.2 Change the one-shot categories read in `_onAccounts` so an empty/closed stream yields "no categories" instead of throwing `StateError`

## 2. Test

- [ ] 2.1 Unit test: accounts stream emits, then the view model is disposed and the categories stream closes without emitting — no exception escapes, no `notifyListeners` after dispose
- [ ] 2.2 Unit test: categories stream that emits normally still enriches rows with category names (no behaviour regression)

## 3. Verify

- [ ] 3.1 `flutter test` green
- [ ] 3.2 `core_ledger_test.dart` runs green on an Android device across a few repeat runs (the late `Bad state: No element` no longer appears)

## 4. Follow-up

- [ ] 4.1 Consider a short audit of other view models for the same "async continuation after dispose" pattern
