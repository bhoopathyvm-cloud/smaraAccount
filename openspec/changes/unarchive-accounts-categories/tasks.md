## Tasks

- [ ] 1.1 `unarchiveFinancialAccount`: clear `archivedAt`; if the account's group is archived, clear the group's `archivedAt` too in the same transaction.
- [ ] 1.2 `unarchiveAccountGroup`: clear `archivedAt` on a user-created group; reject for a system group (should be unreachable, since system groups are never archived, but guard anyway).
- [ ] 1.3 `unarchiveCategory`: clear `archivedAt`.
- [ ] 1.4 UI: "Restore" / "Show again" action on account management, category management, and account group screens for archived items.
- [ ] 1.5 Tests: unarchive account restores pickers; unarchiving an account with an archived group unarchives both; unarchiving a group does not unarchive its former member accounts; unarchive category restores it to the picker; system group has no unarchive affordance (n/a since never archived).
- [ ] 1.6 User guide: how to undo an archive, and that closeout is separate and not reversed by unarchiving.
