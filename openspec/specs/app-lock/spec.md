# app-lock

## Purpose

Optional PIN/biometric lock and app-switcher snapshot hiding, so an
unlocked or backgrounded device doesn't expose the ledger at a glance.

## Requirements

### Requirement: Application Lock
The system SHALL optionally require PIN or device biometrics to open the app after launch or after a configurable idle timeout.

#### Scenario: Lock on resume
- **WHEN** app lock is enabled and the idle timeout elapses
- **THEN** the user must unlock before viewing balances

#### Scenario: Lock is off by default
- **WHEN** the user has never enabled app lock
- **THEN** the app opens without a lock screen, exactly as it does today

### Requirement: App-Switcher Snapshot Hides Balances
The system SHALL optionally obscure the app's content in the OS app-switcher snapshot (backgrounding), independent of whether PIN/biometric lock is enabled — a user may want the snapshot hidden without wanting a full unlock gate every time. This SHALL use each platform's own mechanism (e.g. a secure-flag or an overlay shown while backgrounded) and MAY not be available identically on every supported platform; where a platform has no equivalent mechanism, the system SHALL state that plainly in Settings rather than claim the protection silently applies.

#### Scenario: Snapshot hidden while backgrounded
- **WHEN** snapshot hiding is enabled and the app is backgrounded
- **THEN** the OS app-switcher shows an obscured view instead of balances or ledger content

#### Scenario: Snapshot hiding works independently of app lock
- **WHEN** the user enables snapshot hiding without enabling PIN/biometric lock
- **THEN** the switcher snapshot is still obscured, and the app still opens without a lock screen

### Requirement: PIN Unlock Completes Without Hanging
PIN verification that reads the stored PIN record from OS secure storage SHALL return success or failure in bounded time on every platform the app supports for development and release, including local/ad-hoc signed macOS runs. It SHALL NOT hang indefinitely waiting on Keychain/secure-storage I/O.

#### Scenario: Verify PIN returns on ad-hoc signed macOS
- **WHEN** a PIN has been set and the app later calls PIN verification on an ad-hoc signed macOS build using the production secure-storage path
- **THEN** verification completes with true or false rather than hanging

#### Scenario: Lock then unlock through the real GUI restores the main shell
- **WHEN** the user enables a PIN, the app shows the Lock screen, and the user enters the correct PIN
- **THEN** the Lock screen dismisses and the main app shell is usable again
