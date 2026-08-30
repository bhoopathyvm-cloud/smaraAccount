## Context

`HoldingsViewModel` (`lib/ui/features/holdings/view_models/holdings_view_model.dart`)
opens six repository-stream subscriptions in its constructor:
`_accountsSub`, `_holdingsSub`, `_instrumentsSub`, `_heldInstrumentsSub`,
`_categoriesSub`, `_currenciesSub`, plus a periodic 5-minute quote timer.
`dispose()` cancels all of them. Two gaps:

- `_holdingsSub`'s listener is `async`: it `await`s
  `_ledgerRepository.displayBalanceMinor(accountId)` then `await _refreshQuotes()`.
  A `cancel()` in `dispose()` stops *future* deliveries but cannot unwind an
  invocation already suspended at an `await`. So an emission that lands just
  before disposal can resume afterward and call `displayBalanceMinor` against a
  closed Drift connection (real teardown, or the acceptance harness's
  per-test device reset), then `notifyListeners()` on a dead `ChangeNotifier`.
- None of the six `listen(...)` calls passes `onError`. When the connection
  closes under an in-flight query the failure arrives as a *stream error*, not
  a value, so even a `try/catch` inside the data callback would not see it — it
  becomes an unhandled async error.

`register-viewmodel-stream-dispose-guard` fixed the identical shape in
`RegisterViewModel` and explicitly listed "audit other view models" as
follow-up. This is that follow-up for the one other view model with an `async`
stream listener.

## Goals / Non-Goals

**Goals:**
- No unhandled exception, no `notifyListeners`, no closed-resource read after
  `HoldingsViewModel.dispose()`.
- Match the pattern `RegisterViewModel` now uses, so the two read the same.

**Non-Goals:**
- A framework-level "safe view model base class" — two hand-applied guards is
  enough; a base class is a larger design question.
- Any change to the investment-holdings domain model, quote refresh cadence,
  or repository APIs.
- The closed PR's `debugResearchLaunchInterceptor` test hook — `main` observes
  the research-launch path differently; not carried over.

## Decisions

### 1. `_disposed` flag checked after every `await` in the async listener

Set `_disposed = true` as the first line of `dispose()`. In `_holdingsSub`'s
listener and in `_refreshQuotes`, after each `await`, `if (_disposed) return;`
before assigning state or notifying. For the awaited calls that can throw
against a closed connection, wrap in `try/catch` that rethrows only when
`!_disposed` (a genuine error while alive still surfaces; a teardown-race error
is swallowed).

### 2. A shared `onError` no-op-if-disposed handler on all six subscriptions

One private `void _ignoreError(Object e, [StackTrace? st]) {}` passed as
`onError:` to every `listen(...)`. Rationale: a torn-down view model has
nothing to do with a stream error except not crash the zone. Keeping it a
single named method (not inline) documents the intent once.

**Alternative considered:** only guard `_holdingsSub` (the only async one).
Rejected — the synchronous listeners still `notifyListeners()` and their
streams can still error on connection close; the cost of `onError:` on all six
is one argument each.

### 3. Unit test drives the race directly

Fake/mocked repositories where `displayBalanceMinor` returns a `Completer`
future the test controls: emit on the holdings stream, call `dispose()`, then
complete the future — assert no throw and no `notifyListeners` after dispose.
Mirrors the register change's test.

## Risks / Trade-offs

- **[Risk]** Swallowing errors while `_disposed` hides a real bug. →
  **Mitigation:** the swallow is gated strictly on `_disposed`; anything thrown
  while the view model is alive still rethrows.
- **[Trade-off]** Six near-identical `onError: _ignoreError` arguments. Minor,
  and matches how teardown-safety reads elsewhere once `RegisterViewModel`
  lands.

## Migration Plan

1. Add `_disposed` + `_ignoreError` to `HoldingsViewModel`; guard the async
   listener and `_refreshQuotes`; attach `onError:` to all six subscriptions.
2. Add the dispose-race unit test.
3. `flutter test` green; `flutter analyze` clean.
4. Rollback = revert the file.

## Open Questions

- None. Whether to generalise into a base class is deliberately deferred.
