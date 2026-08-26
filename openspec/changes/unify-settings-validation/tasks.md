## 1. Structured failure

- [ ] 1.1 Add `AppErrorCode.validationPinTooShort` to `lib/domain/app_error.dart`
- [ ] 1.2 Map it through `lib/l10n/localize_error.dart` to `l10n.validationPinMinLength`

## 2. Validators on SettingsViewModel

- [ ] 2.1 `pinValidationError(String pin, String confirm)` → `AppErrorCode.validationPinTooShort` if `pin.length < 4`, `AppErrorCode.validationPinsDoNotMatch` if `pin != confirm`, else `null`
- [ ] 2.2 `passphraseValidationError(String passphrase)` → `AppErrorCode.validationPassphraseRequired` if blank, else `null`
- [ ] 2.3 Unit tests: both validators, all failure cases plus the valid case

## 3. Migrate the View

- [ ] 3.1 `_showSetPinDialog` and `_showChangePinDialog` call `viewModel.pinValidationError(...)`, render `localizeError(l10n, code)` on failure
- [ ] 3.2 `_showSaveBackupDialog` and `_showRestoreBackupDialog` call `viewModel.passphraseValidationError(...)`, render `localizeError(l10n, code)` on failure
- [ ] 3.3 Delete the four inline `if` checks

## 4. Verify

- [ ] 4.1 `dart analyze` clean; new `SettingsViewModel` unit tests green
- [ ] 4.2 Existing `settings_view_test.dart` and `settings_view_model_test.dart` widget/unit tests still green, no assertions weakened
