# app-lock-session-policy

## Purpose

TBD

## Requirements

### Requirement: Session lock policy has one module
The system SHALL decide whether the app is locked, whether a timeout requires relock, and whether snapshot hiding applies through one session-policy module. Router redirects and the lock screen MUST read that module rather than re-deriving policy from ad hoc settings reads and controller fields.

#### Scenario: Lifecycle event updates policy
- **WHEN** the app backgrounds and the configured lock timeout has elapsed
- **THEN** the session-policy module reports locked so the router presents the lock screen

#### Scenario: Timeout policy is unit-testable
- **WHEN** unit tests advance time past the configured timeout after a background event
- **THEN** they assert locked state via the policy module without pumping the full widget tree

### Requirement: PIN crypto stays on the ADR 0001 path
Session-policy deepening SHALL NOT replace Keychain/secure-storage PIN verification with an acceptance-only in-memory bypass. PIN derive MUST remain off the UI isolate as established for production unlock.

#### Scenario: Unlock still verifies via AppLockService
- **WHEN** the user submits a correct PIN on the lock screen
- **THEN** verification goes through `AppLockService` (secure storage + isolate PBKDF2) and policy marks the session unlocked on success

#### Scenario: Acceptance unlock remains green on macOS
- **WHEN** `home_and_lock_test.dart` runs on macOS after the policy consolidation
- **THEN** lock and unlock scenarios pass
