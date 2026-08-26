# acceptance-group-archive

## Purpose

TBD

## Requirements

### Requirement: Real-Build Coverage of User-Created Group Archive Lifecycle
The system SHALL provide an acceptance test that drives a real launched build through the Accounts GUI to exercise archiving a user-created account group: reject hide while the group still has an active member account, allow hide once it has none, keep the archived group and historically associated account visible, and omit the archived group from the reassignment target list for another account.

#### Scenario: Hide blocked while the group has an active account
- **WHEN** the acceptance test attempts to hide a user-created group that still has an active financial account, through the real Accounts UI
- **THEN** the UI shows the existing cannot-hide explanation and the group remains active

#### Scenario: Hide succeeds once the group is empty
- **WHEN** that group's last active member account has been archived and the test hides the group through the real Accounts UI
- **THEN** the group is archived, remains visible as archived with its historical account, and is not offered as a reassignment target for another account's "Reassign group" picker
