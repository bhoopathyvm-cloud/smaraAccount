## ADDED Requirements

### Requirement: Unarchive Financial Account
The user SHALL be able to restore an archived financial account to active status. A restored account SHALL appear in pickers for new transactions and transfers. If the account's current group is itself archived, unarchiving the account SHALL also unarchive that group in the same action, so the account is never left referencing an archived group.

#### Scenario: Unarchive account
- **WHEN** the user restores an archived financial account
- **THEN** the account appears when recording new spent received or moved money
- **AND** `archivedAt` is cleared

#### Scenario: Unarchiving an account also unarchives its archived group
- **WHEN** the user restores an archived financial account whose group is itself archived
- **THEN** both the account's `archivedAt` and the group's `archivedAt` are cleared
- **AND** the group is available for assignment again

### Requirement: Unarchive Account Group
The user SHALL be able to restore an archived user-created account group to active status. A restored group SHALL be available for assignment to financial accounts of its kind and currency. Unarchiving a group SHALL NOT itself unarchive any of the accounts that reference it — that is done independently, per account. A system group SHALL NOT need this action, since system groups are never archived in the first place.

#### Scenario: Unarchive a user-created group
- **WHEN** the user restores an archived user-created account group
- **THEN** the group is available for assignment to new or reassigned financial accounts
- **AND** `archivedAt` is cleared

#### Scenario: Unarchiving a group does not unarchive its former members
- **WHEN** the user unarchives a group that has previously-archived member accounts
- **THEN** those accounts remain archived until unarchived individually
