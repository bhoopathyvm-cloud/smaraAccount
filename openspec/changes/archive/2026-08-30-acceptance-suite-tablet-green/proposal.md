## Why

The acceptance suite has only ever been run on macOS. The first Android run
(on a Galaxy Tab A9+, `SM X230`, Android 16, after `android-compile-sdk-37`
unblocked the build) passed 10 of 13 files. Two of the three failures are
acceptance-test defects, not product bugs, that a larger screen exposes:

1. **`currency_transfers_test.dart` — `_setUpCrossCurrencyTransfer` (line ~252).**
   After picking a group in the Create-account dialog it waits for
   `find.text('Euro Group').evaluate().length == 1`. On a phone-sized surface
   the dialog covers the Accounts list, so "Euro Group" appears once (the
   dropdown value). On a tablet the dialog floats over a still-visible Accounts
   list whose "Euro Group" group header is also on screen, so the count is 2
   and `tapReliably` never succeeds — both tests in the file fail deterministically.

2. **`home_and_lock_test.dart` — the relaunch simulation (~line 123-126).**
   `pumpWidget(SizedBox.shrink())` then `pumpWidget(SmaraAccountingApp())`
   races an in-flight `go_router` redirect: intermittently throws
   `GoException: Channel was closed before receiving a response` and a
   "guarded function conflict … you must use await" on `tester.pump()`. Flaky —
   a different test in the file fails on different runs.

(The third failure, `core_ledger_test.dart`, is a product bug tracked
separately in `register-viewmodel-stream-dispose-guard`.)

## What Changes

- `_setUpCrossCurrencyTransfer` scopes its group-picker finders to the
  Create-account dialog (`find.descendant(of: find.byType(AlertDialog), …)`)
  instead of counting matches across the whole screen.
- Audit the file's other `find.text(...)` success checks in dialog flows for
  the same whole-screen assumption and scope them the same way.
- The `home_and_lock` relaunch step drains pending microtasks/router redirects
  before and after swapping the root widget (await a settle, or tear down via
  the harness helper) so the go-router channel call is not cancelled
  mid-flight; fix the unawaited `pump()`.
- Add a shared harness helper for "simulate an app relaunch" so any future
  test does this the safe way once.

## Capabilities

### Modified Capabilities

- `acceptance-test-suite`: the suite passes on every supported target device
  class, tablets included; its helpers scope UI queries to the surface under
  test (the open dialog/sheet) rather than the whole screen, and its
  relaunch-simulation step is race-free.

## Impact

- `integration_test/acceptance/currency_transfers_test.dart`
- `integration_test/acceptance/home_and_lock_test.dart`
- `integration_test/acceptance/support/acceptance_harness.dart` (new relaunch helper; possibly a dialog-scoped finder helper)
- No product-code change.
