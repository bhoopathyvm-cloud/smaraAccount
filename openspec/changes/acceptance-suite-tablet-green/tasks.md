## 1. Harness helpers

- [ ] 1.1 Add `inDialog(Finder inner)` to `acceptance_harness.dart` — `find.descendant(of: find.byType(AlertDialog), matching: inner)`
- [ ] 1.2 Add `simulateRelaunch(WidgetTester tester)` — bounded `pumpAndSettle`, swap root to `SizedBox.shrink()`, swap back to `SmaraAccountingApp()`, `pump`, all awaited

## 2. currency_transfers_test.dart

- [ ] 2.1 In `_setUpCrossCurrencyTransfer`, scope the group-picker `tapReliably` success checks (`find.text('Euro Group') …`) with `inDialog(...)` so a still-visible Accounts list behind the dialog does not inflate the match count
- [ ] 2.2 Scan the rest of the file for other in-dialog `find.text(...)`/count assertions that assume the dialog occludes the screen; scope them too

## 3. home_and_lock_test.dart

- [ ] 3.1 Replace the inline root-widget swap with `simulateRelaunch(tester)`
- [ ] 3.2 Ensure every `tester.pump()` / `pumpWidget()` in the file is awaited (fixes the "guarded function conflict" at ~line 125)

## 4. Verify

- [ ] 4.1 `currency_transfers_test.dart` and `home_and_lock_test.dart` each pass 3× in a row on a real Android tablet
- [ ] 4.2 Full `tool/run_acceptance_tests.sh -d macos` still green (no regression on the platform the suite is usually run on)
- [ ] 4.3 Full `tool/run_acceptance_tests.sh -d <android-tablet>` green except for anything owned by `register-viewmodel-stream-dispose-guard`
