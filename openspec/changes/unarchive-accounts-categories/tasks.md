## Tasks

- [x] 1.1 `unarchiveFinancialAccount`: clear `archivedAt`; if the account's group is archived, clear the group's `archivedAt` too in the same transaction.
- [x] 1.2 `unarchiveAccountGroup`: clear `archivedAt` on a user-created group; reject for a system group (should be unreachable, since system groups are never archived, but guard anyway).
- [x] 1.3 `unarchiveCategory`: clear `archivedAt`.
- [x] 1.4 UI: "Restore" action on account management (accounts and groups) and category management screens for archived items - replaces the now-`null`/archive-icon trailing widget with a plain `TextButton` reading "Restore", no confirmation dialog (mirrors that restoring is the low-risk undo of the confirmed "Hide" action, not itself destructive).
- [x] 1.5 Tests: `ledger_repository_test.dart`'s "unarchive-accounts-categories" group (account restore; the transitive account+group case; group restore independent of former members; system-group rejection; category restore); `account_management_view_test.dart`/`category_management_view_test.dart`'s "unarchive-accounts-categories" groups (Restore button visibility and wiring).
- [x] 1.6 User guide: how to undo an archive (Categories and Accounts and account groups sections), and that closeout is separate and not reversed by unarchiving.
