## Why

`HoldingsViewModel` subscribes to six repository streams, and its
`_holdingsSub` listener is `async` — it `await`s
`_ledgerRepository.displayBalanceMinor(accountId)` and then `_refreshQuotes()`
partway through the callback. Cancelling a `StreamSubscription` in `dispose()`
does not abort an invocation of its listener that is already running, so a
value emitted just before teardown can finish `await`ing against a
database connection that has since closed — the view's own disposal, or, in
the acceptance suite, the next test's fresh-device reset. None of the six
subscriptions has an `onError` handler either, so a query in flight when the
connection closes surfaces as an unhandled asynchronous error rather than
anything a caller can catch. This is the same defect class as
`register-viewmodel-stream-dispose-guard` (whose design flagged "audit other
view models for this pattern" as a follow-up); it was seen in practice on a
closed PR's investment-holdings acceptance work.

## What Changes

- `HoldingsViewModel` tracks a `_disposed` flag, set at the top of `dispose()`,
  and its `async` `_holdingsSub` listener and `_refreshQuotes` return early
  (or swallow-if-disposed) after each `await` instead of touching state or a
  possibly-closed database.
- Every repository-stream subscription in `HoldingsViewModel` is given an
  `onError` handler that no-ops once the view model is disposed and otherwise
  rethrows, so teardown-time query errors do not become unhandled async
  errors.
- A unit test covers "holdings stream emits, then `dispose()` runs before the
  awaited balance read completes" and asserts nothing is thrown and no
  `notifyListeners` fires afterward.
- No product behaviour change in normal operation; no new dependency; no
  change to the investment-holdings domain model.

Note: the closed PR also carried a home-overview stream-reactivity fix for
opening-balance-free accounts. `main` already ticks `watchHomeOverview` on
`watchFinancialAccounts`, so a new account already refreshes Home — that item
needs no change and is not included here.

## Capabilities

### Modified Capabilities

- `internal-architecture`: the existing lifecycle/teardown rules gain one for
  view models — a `ChangeNotifier` view model with `async` stream listeners
  must not raise, notify, or read a closed resource after `dispose()`.

## Impact

- `lib/ui/features/holdings/view_models/holdings_view_model.dart`
- `test/ui/features/holdings/view_models/holdings_view_model_test.dart`
- Complements `register-viewmodel-stream-dispose-guard`; no overlap of files.
