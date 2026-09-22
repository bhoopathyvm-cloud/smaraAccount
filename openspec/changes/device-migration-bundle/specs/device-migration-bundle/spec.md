## Purpose

Let a user move to a new device in one guided step by exporting a single passphrase-protected bundle containing both the ledger database and the private key material, and offer that bundle as an explicit alternative to first-time setup at startup.

## ADDED Requirements

### Requirement: Device Migration Bundle Export
The system SHALL let the user export a single passphrase-protected file containing both the raw local ledger database and the current private key material, from a Settings screen, at any time, without requiring any other backup step to have been completed first.

#### Scenario: Export produces one file with both database and key
- **WHEN** the user exports a device migration bundle with a passphrase
- **THEN** a single encrypted file is written to the location they chose
- **AND** decrypting it with the correct passphrase yields both the ledger database bytes and the private key material

#### Scenario: Export discloses the combined-artifact trade-off
- **WHEN** the user opens the device migration bundle export screen
- **THEN** the system explains that this file, if it and its passphrase were both exposed, would allow both reading the full ledger history and signing new entries as the user — a broader exposure than the data-only `ledger-backup` export, which contains no key material

### Requirement: Device Migration Bundle Import Restores a Working Identity Immediately
The system SHALL let the user restore a device migration bundle by selecting the file and entering its passphrase. On success, the local ledger database SHALL be replaced by the bundle's data, the private key material SHALL be stored in OS secure storage, the restored chain SHALL be verified using the re-derived identity, and the user SHALL be able to record a new entry immediately, with no separate key-restoration step. Importing onto a device that already has an active signing identity different from the bundle's SHALL be rejected with an explanation.

#### Scenario: Successful import restores data and signing capability together
- **WHEN** the user imports a valid device migration bundle with the correct passphrase on a device with no prior active identity
- **THEN** the ledger database is restored, the matching private key is stored in secure storage, the chain verifies successfully, and the user can record a new transaction without any further setup

#### Scenario: Wrong passphrase is rejected
- **WHEN** the user attempts to import a device migration bundle with an incorrect passphrase
- **THEN** the import is rejected and no local data or key material is changed

#### Scenario: Importing a foreign identity onto a set-up device is rejected
- **WHEN** the user attempts to import a bundle whose signing identity differs from the device's own active identity
- **THEN** the system rejects the import and explains that this would combine two different identities' books rather than restore the user's own

### Requirement: Startup Setup Choice
On first launch, before any signing identity is generated or any account is created, the system SHALL present the user an explicit choice between New Setup and Import From Backup.

#### Scenario: New Setup proceeds as ordinary first-time onboarding
- **WHEN** the user chooses New Setup
- **THEN** a signing identity is generated automatically, and the user is guided to name a first account and record a first transaction, exactly as first-time setup already behaves, with no acknowledgment screen or other block following

#### Scenario: Import From Backup restores immediately usable books
- **WHEN** the user chooses Import From Backup and completes a valid device migration bundle import
- **THEN** the user lands directly in their restored, fully verified ledger, ready to record new entries, without going through guided first-account or first-transaction onboarding
