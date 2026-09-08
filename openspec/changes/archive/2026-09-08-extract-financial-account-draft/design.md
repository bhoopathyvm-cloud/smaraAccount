## Decisions
1. Structure, not behavior. The create dialog keeps its existing submit
   gate (enabled once a group is selected; the name is validated in the
   handler), so `hasSelectedGroup` - not a full `canSubmit` - drives the
   button. Wiring name into the enable condition would flip the button to
   disabled while the name field is empty (the name `TextField` has no
   `onChanged`, so the button would not re-enable until another rebuild),
   an observable behavior change; avoided deliberately.
2. `ensureValidGroupSelection()` is idempotent and called on every rebuild,
   preserving the old inline auto-select-first-of-kind behavior.
3. The draft does not re-implement group type-filtering. The existing
   account/group type-filter seam is `AccountManagementViewModel`'s
   `groupsAvailableForType` (blessed by the `account-group-invariants`
   spec); the dialog reads that list and passes it into the draft's
   `ensureValidGroupSelection` / `selectedGroupCurrency`. This keeps the
   type-filter rule with one owner and avoids introducing a second copy in
   the draft.
4. The account name stays in its `TextEditingController` rather than moving
   into the draft: it is an independent single field with no coupling to
   type/group/flags, so pulling it in would add controller↔draft sync for
   no locality gain.
