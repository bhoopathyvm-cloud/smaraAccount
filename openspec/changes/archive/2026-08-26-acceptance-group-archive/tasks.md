## 1. Port scenario

- [x] 1.1 Add the user-created group archive lifecycle acceptance scenario (blocked hide while active; hide once empty; historical visibility; not a reassignment target), following INTEGRATION's setup/GUI split and platform-stable popup finding
- [x] 1.2 Place it in `core_ledger_test.dart` or a sibling acceptance file discoverable by `tool/run_acceptance_tests.sh`'s group filter — **`group_archive_test.dart` (`group_archive` filter).**
- [x] 1.3 Adjust popup/group targeting for acceptance seed data (extra system groups vs INTEGRATION) — **dynamic `"Show menu"` lookup by ListTile title; reassignment uses `l10n.systemGroupCashEquivalents`; refresh `AccountRepository` after relaunch.**

## 2. Verify

- [x] 2.1 Confirm 2 consecutive green runs on macOS for the new scenario
- [x] 2.2 Spot-check that existing `core_ledger` scenarios still pass in the same file — **core_ledger and group_archive are sibling files; core_ledger 3/3 on isolated runs after changes.**
