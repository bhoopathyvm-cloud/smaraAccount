## ADDED Requirements

### Requirement: Account and group dialogs survive dismissal
The account management screen's create/rename dialogs for accounts and
groups SHALL remain stable through dismissal — including any in-progress
dialog exit transition or keyboard-dismiss animation — without throwing an
unhandled exception or triggering Flutter's error screen.

#### Scenario: Creating an account group
- **WHEN** a user fills in the "Create group" dialog and taps "Create"
- **THEN** the group is created, the dialog closes, and no error screen is
  shown while the dialog's exit transition plays

#### Scenario: Creating an account
- **WHEN** a user fills in the "Create account" dialog and taps "Create"
- **THEN** the account is created, the dialog closes, and no error screen is
  shown while the dialog's exit transition plays

#### Scenario: Renaming an account or group
- **WHEN** a user edits the name field in a rename dialog and taps "Save"
- **THEN** the rename is applied, the dialog closes, and no error screen is
  shown while the dialog's exit transition plays
