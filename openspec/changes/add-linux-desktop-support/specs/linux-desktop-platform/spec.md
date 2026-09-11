## ADDED Requirements

### Requirement: The App Builds and Runs on Linux Desktop
The app SHALL build successfully for Linux desktop (`flutter build linux`) and SHALL launch and complete first-launch onboarding when run on a real or CI-provisioned Linux environment.

#### Scenario: A Linux build is produced
- **WHEN** `flutter build linux` runs on a Linux environment with this project's `linux/` platform directory present
- **THEN** the build completes without error and produces a runnable Linux executable

#### Scenario: The app launches and completes onboarding on Linux
- **WHEN** the built Linux app is launched for the first time
- **THEN** the mandatory language-selection screen appears, a language can be selected, and the guided first-entry onboarding flow (currency selection, first account, recording one transaction, recovery phrase) completes the same way it does on macOS

### Requirement: Secure Storage Works on Linux
Signing-key and pending-recovery-phrase storage (`SecureKeyStorage`) SHALL work correctly on Linux, using whatever platform-specific configuration Linux's secure-storage backend requires — documented with the same rationale-comment convention already used for macOS's `MacOsOptions`.

#### Scenario: A signing identity persists across a relaunch on Linux
- **WHEN** a signing identity is generated on first launch, then the app is closed and relaunched
- **THEN** the same identity is available after relaunch, without needing to restore from a recovery phrase
