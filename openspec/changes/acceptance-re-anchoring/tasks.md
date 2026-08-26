## 1. Reproduce and diagnose

- [x] 1.1 Re-run the existing tamper-detection acceptance path on macOS up to the post-restart lock-badge assertion; confirm it still passes in isolation
- [x] 1.2 Attempt the re-anchoring half (tap Register FAB / record second entry); capture failure evidence (finder diagnostics, visible texts, current route)
- [x] 1.3 Determine root cause: FAB not in tree vs wrong finder vs navigation/shell state after quarantine restart — **Register’s search `TextField` sat earlier in the tree than the capture form’s amount field; `find.byType(TextField).first` during re-anchoring typed into search (filtering the tampered Salary row off-screen) instead of the record amount.**

## 2. Fix

- [x] 2.1 Apply the product and/or harness fix required so the Register FAB is reliably available after the acceptance restart path — **harness-only: scope amount entry to `RecordTransactionView` descendants; scroll Register for lock badge after second entry.**
- [x] 2.2 Add or extend unit/widget coverage if the fix changes product UI logic (skip if harness-only)

## 3. Acceptance scenario

- [x] 3.1 Land the full re-anchoring acceptance scenario in `core_ledger_test.dart` (GUI record of second entry; lock badge only on tampered row)
- [x] 3.2 Confirm 2 consecutive green runs on macOS via `tool/run_acceptance_tests.sh -d macos core_ledger` — **tamper scenario 2/2 green; full file 3/3 on clean isolated runs.**
