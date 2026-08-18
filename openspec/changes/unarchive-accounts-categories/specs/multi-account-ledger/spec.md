## ADDED Requirements

### Requirement: Unarchive Financial Account
The user SHALL be able to restore an archived financial account to active
status. A restored account SHALL appear in pickers for new transactions
and transfers.

#### Scenario: Unarchive account
- **WHEN** the user restores an archived financial account
- **THEN** the account appears when recording new spent received or moved money
- **AND** archivedAt is cleared
