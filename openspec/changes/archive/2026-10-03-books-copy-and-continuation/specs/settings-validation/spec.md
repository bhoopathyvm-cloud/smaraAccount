## MODIFIED Requirements

### Requirement: Passphrase validation has one definition
The system SHALL validate that a backup passphrase is non-blank through a single `SettingsViewModel.passphraseValidationError` method. `SettingsView`'s "Save a copy of my books" and "Restore from a copy" dialogs MUST call that method rather than inlining their own blank check.

#### Scenario: Blank passphrase is rejected consistently
- **WHEN** the passphrase field is empty or whitespace-only, in either the save-a-copy or restore-from-a-copy dialog
- **THEN** `passphraseValidationError` returns `AppErrorCode.validationPassphraseRequired`, and both dialogs render the same message via `localizeError`

### Requirement: Views stay free of inline validation logic
`SettingsView`'s set-PIN, change-PIN, save-a-copy, and restore-from-a-copy dialogs SHALL NOT contain inline `length`/`==`/`isEmpty` validation checks for PIN or passphrase fields; they call `SettingsViewModel`'s validators and render the result.

#### Scenario: Existing tests still pass
- **WHEN** `settings_view_test.dart` and `settings_view_model_test.dart` run after the migration
- **THEN** they pass without weakening any assertion
