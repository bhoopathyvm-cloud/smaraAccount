## Why

Archive is one-way trapdoor; beginners fear cleanup.

## What Changes

- Restore an archived financial account or category to active status.
- Restore an archived user-created account group. (System groups are
  never archived in the first place, so "unarchive a group" only ever
  applies to a user-created one.)
- Unarchiving an account whose current group is itself archived also
  unarchives that group — an account can only reach that state by being
  archived, then its now-empty group being archived too (the group's own
  archive precondition already requires zero active members), so
  restoring the account without also restoring its group would leave it
  homeless. No separate group-picker step is required.
- Closeout remains separate; unarchive does not reverse a closeout that
  already happened, and does not restore whatever balance a closeout
  moved out.

## Capabilities

### New Capabilities

(none)

### Modified Capabilities

- `multi-account-ledger`: unarchive for financial accounts and account
  groups, including the transitive group-unarchive case above.
- `core-ledger-single-account`: unarchive for categories.
- `user-guide`

## Impact

- As described in What Changes.
- Tests and user guide.
