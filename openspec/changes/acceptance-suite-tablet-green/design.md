## Context

`android-compile-sdk-37` made the Android acceptance build work for the first
time. Running the full suite on a Galaxy Tab A9+ (`SM X230`, Android 16):

| Result | Files |
| --- | --- |
| Pass | account_currency, csv_import, group_archive, identity_restore, investment_holdings, investment_research, ledger_backup, ofx_import, onboarding, organization |
| Fail | core_ledger (product bug — see `register-viewmodel-stream-dispose-guard`), currency_transfers, home_and_lock |

This change covers the two test-side failures.

## Goals / Non-Goals

**Goals:**
- `currency_transfers` and `home_and_lock` pass on a tablet as reliably as on
  macOS.
- The fix is structural (helpers), so the next tablet-sensitive test does not
  re-learn it.

**Non-Goals:**
- Fixing `core_ledger` (separate change).
- A device-matrix CI for the acceptance tier — it stays manual (per
  `CONTRIBUTING.md`); this only makes a manual tablet run trustworthy.
- Pixel-level responsive assertions — the suite checks behaviour, not layout.

## Decisions

### 1. Scope dialog-flow finders to the dialog, not the screen

`_setUpCrossCurrencyTransfer` asserts on `find.text('Euro Group').length == 1`.
That is only true when the dialog occludes everything behind it — a
phone/desktop-window assumption. Fix: every success check inside an open
`AlertDialog` / bottom sheet uses
`find.descendant(of: find.byType(AlertDialog), matching: <finder>)` (or a
small `inDialog(finder)` helper in the harness). "Is the dialog gone yet"
checks stay as `find.byType(AlertDialog).evaluate().isEmpty`.

### 2. Make the relaunch simulation race-free, and give it a helper

`home_and_lock` swaps the root widget to simulate a cold start while a
`go_router` redirect (which calls a platform channel — app-lock / secure
storage) is still in flight; tearing the tree down cancels the channel call →
`GoException: Channel was closed`. The relaunch step SHALL quiesce first:
`await tester.pumpAndSettle()` (bounded) before `pumpWidget(SizedBox.shrink())`,
and `await tester.pump()` / `pumpUntilFound` after, with every `pump` awaited.
Wrap this in `acceptance_harness.dart`'s existing helper set as
`simulateRelaunch(tester)` so other files reuse it.

### 3. Keep `tapReliably` / `pumpUntilFound` as-is

They already retry; the failures are wrong *success predicates* and an
unawaited call, not helper deficiencies. No change to the retry primitives.

## Risks / Trade-offs

- **[Risk]** Dialog-scoped finders miss a legitimately screen-level element →
  **Mitigation:** only the in-dialog interaction checks are scoped; navigation
  and post-dialog assertions stay screen-level.
- **[Risk]** `pumpAndSettle` in the relaunch step hangs on a never-settling
  animation → **Mitigation:** bounded timeout, fall back to a fixed
  `pump(Duration)` count as the rest of the harness does.
- **[Trade-off]** A little more harness surface (`inDialog`,
  `simulateRelaunch`); both are reused immediately.

## Migration Plan

1. Add `inDialog(...)` and `simulateRelaunch(tester)` to
   `integration_test/acceptance/support/acceptance_harness.dart`.
2. Rewrite `_setUpCrossCurrencyTransfer`'s group-picker checks with `inDialog`.
3. Replace `home_and_lock`'s inline relaunch with `simulateRelaunch`; await
   every `pump`.
4. Run both files on a tablet several times; then the full suite on macOS to
   confirm no regression there.
5. Rollback = revert the two test files and the harness additions.

## Open Questions

- Should `simulateRelaunch` also reset in-memory singletons the way a true
  cold start would? For these tests the router redirect is the only thing
  under test; a fuller reset can come with the next test that needs it.
