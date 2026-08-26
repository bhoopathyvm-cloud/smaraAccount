## ADDED Requirements

### Requirement: macOS Release build runs under App Sandbox
The macOS Release build configuration SHALL have `com.apple.security.app-sandbox` enabled, with the minimum entitlement set its actual file and Keychain access patterns require.

#### Scenario: Sandbox is on for Release
- **WHEN** the macOS app is built in the Release configuration
- **THEN** `com.apple.security.app-sandbox` is `true` in its entitlements

### Requirement: Signing-key storage works under sandbox
The app SHALL retain read/write access to the device signing key stored via `flutter_secure_storage` in the macOS Keychain while sandboxed.

#### Scenario: Onboarding still generates and stores a key
- **WHEN** a user completes onboarding on a sandboxed macOS build
- **THEN** the signing key is generated, stored, and later readable exactly as on an unsandboxed build

### Requirement: File import and export work under sandbox
The app SHALL retain the ability to open a user-selected file (OFX/CSV import) and save a file to a user-chosen location (CSV export, ledger backup) while sandboxed.

#### Scenario: Import still opens a file picker
- **WHEN** a user starts an OFX or CSV import on a sandboxed macOS build
- **THEN** the file-open dialog appears and the chosen file is read successfully

#### Scenario: Export and backup still save to a chosen location
- **WHEN** a user exports a CSV or saves a ledger backup on a sandboxed macOS build
- **THEN** the save dialog appears and the file is written successfully to the chosen location

### Requirement: Biometric unlock works under sandbox
App-lock's Face ID/Touch ID unlock (`local_auth`) SHALL continue to function while sandboxed.

#### Scenario: Face ID/Touch ID unlock still succeeds
- **WHEN** a user with app lock and biometrics enabled unlocks the app on a sandboxed macOS build
- **THEN** the biometric prompt appears and a successful match unlocks the app
