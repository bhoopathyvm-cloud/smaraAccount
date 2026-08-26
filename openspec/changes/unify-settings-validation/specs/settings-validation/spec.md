## ADDED Requirements

### Requirement: PIN validation has one definition
The system SHALL validate a proposed app-lock PIN (minimum length, and matching a confirmation) through a single `SettingsViewModel.pinValidationError` method returning an `AppErrorCode?`. `SettingsView`'s set-PIN and change-PIN dialogs MUST call that method rather than inlining their own length/match checks.

#### Scenario: Too-short PIN is rejected consistently
- **WHEN** a proposed PIN is fewer than 4 digits, in either the set-PIN or change-PIN dialog
- **THEN** `pinValidationError` returns `AppErrorCode.validationPinTooShort`, and both dialogs render the same message via `localizeError`

#### Scenario: Mismatched confirmation is rejected consistently
- **WHEN** the PIN and its confirmation differ, in either dialog
- **THEN** `pinValidationError` returns `AppErrorCode.validationPinsDoNotMatch`

#### Scenario: Valid PIN passes
- **WHEN** the PIN is at least 4 digits and matches its confirmation
- **THEN** `pinValidationError` returns `null` and the dialog proceeds to call `enableAppLock`/`changePin`

### Requirement: Passphrase validation has one definition
The system SHALL validate that a backup passphrase is non-blank through a single `SettingsViewModel.passphraseValidationError` method. `SettingsView`'s save-backup and restore-backup dialogs MUST call that method rather than inlining their own blank check.

#### Scenario: Blank passphrase is rejected consistently
- **WHEN** the passphrase field is empty or whitespace-only, in either the save-backup or restore-backup dialog
- **THEN** `passphraseValidationError` returns `AppErrorCode.validationPassphraseRequired`, and both dialogs render the same message via `localizeError`

### Requirement: Views stay free of inline validation logic
`SettingsView`'s set-PIN, change-PIN, save-backup, and restore-backup dialogs SHALL NOT contain inline `length`/`==`/`isEmpty` validation checks for PIN or passphrase fields; they call `SettingsViewModel`'s validators and render the result.

#### Scenario: Existing tests still pass
- **WHEN** `settings_view_test.dart` and `settings_view_model_test.dart` run after the migration
- **THEN** they pass without weakening any assertion
