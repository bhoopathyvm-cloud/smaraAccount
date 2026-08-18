# app-lock

## Purpose

Capability for app lock.

## Requirements

### Requirement: Application Lock
The system SHALL optionally require PIN or device biometrics to open the app after launch or after a configurable idle timeout.

#### Scenario: Lock on resume
- **WHEN app lock is enabled and the idle timeout elapses**
- **THEN** the user must unlock before viewing balances

