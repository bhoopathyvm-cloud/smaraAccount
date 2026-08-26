## Why

`settings_view.dart`'s own doc comment (line 18-19 area, the file-level "Views are lean. No business logic, no Repository calls" convention from `smara-tech-guidelines.md`) is violated by its own dialogs:

- PIN policy is written out twice: `_showSetPinDialog` (`settings_view.dart:555-566`) and `_showChangePinDialog` (lines 636-647) each independently check `pin.length < 4` and `pin != confirmController.text`.
- "Passphrase must not be blank" is written out twice: `_showSaveBackupDialog` (lines 341-347) and `_showRestoreBackupDialog` (lines 464-470) each independently check `passphrase.trim().isEmpty`.

`SettingsViewModel.enableAppLock`/`changePin` (`settings_view_model.dart:204-233`) explicitly document that they assume the caller already validated ("this method itself does not ask for confirmation") — there is no `SettingsViewModel` method a unit test can call to exercise the PIN-length or passphrase-required rule. `AppErrorCode` already has `validationPinsDoNotMatch` and `validationPassphraseRequired` entries mapped through `localizeError` (`l10n/localize_error.dart:218-220`), but the View reads the l10n string directly instead of going through that mapping, and `validationPinMinLength` has no `AppErrorCode` entry at all — the PIN-length rule isn't even wired into the existing structured-failure pattern.

`test/ui/features/settings/view_models/settings_view_model_test.dart` has no coverage of PIN-format or passphrase validation (there's nothing on the ViewModel to test); `settings_view_test.dart` only reaches these rules by pumping a widget and typing into text fields.

## What Changes

- Add `AppErrorCode.validationPinTooShort` alongside the existing `validationPinsDoNotMatch` and `validationPassphraseRequired`, mapped through `localizeError`.
- Add pure validation to `SettingsViewModel`: `pinValidationError(String pin, String confirm)` and `passphraseValidationError(String passphrase)`, each returning `AppErrorCode?` (null = valid).
- `_showSetPinDialog`, `_showChangePinDialog`, `_showSaveBackupDialog`, `_showRestoreBackupDialog` call the corresponding `SettingsViewModel` method and render `localizeError(l10n, code)` for the returned failure — no inline `if` checks left in the View.
- Preserve existing validation thresholds and messages exactly — this is a locality change, not a product-behavior change.

## Capabilities

### New Capabilities
- `settings-validation`: unit-testable PIN-format and passphrase-required validation, owned by `SettingsViewModel`, using the existing `AppErrorCode`/`localizeError` structured-failure pattern.

### Modified Capabilities
- (none — App Lock PIN and ledger-backup-restore product requirements unchanged)

## Impact

- `lib/ui/features/settings/views/settings_view.dart` (`_showSetPinDialog`, `_showChangePinDialog`, `_showSaveBackupDialog`, `_showRestoreBackupDialog`)
- `lib/ui/features/settings/view_models/settings_view_model.dart`
- `lib/domain/app_error.dart` (new `AppErrorCode.validationPinTooShort`)
- `lib/l10n/localize_error.dart`
- New unit tests on `SettingsViewModel` for both validators
- No Drift schema change; no ADR conflict
