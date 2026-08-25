## ADDED Requirements

### Requirement: PIN Unlock Completes Without Hanging
PIN verification that reads the stored PIN record from OS secure storage SHALL return success or failure in bounded time on every platform the app supports for development and release, including local/ad-hoc signed macOS runs. It SHALL NOT hang indefinitely waiting on Keychain/secure-storage I/O.

#### Scenario: Verify PIN returns on ad-hoc signed macOS
- **WHEN** a PIN has been set and the app later calls PIN verification on an ad-hoc signed macOS build using the production secure-storage path
- **THEN** verification completes with true or false rather than hanging

#### Scenario: Lock then unlock through the real GUI restores the main shell
- **WHEN** the user enables a PIN, the app shows the Lock screen, and the user enters the correct PIN
- **THEN** the Lock screen dismisses and the main app shell is usable again
