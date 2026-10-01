## MODIFIED Requirements

### Requirement: Device Signing Identity
On first install, before any journal entry can be recorded, the system SHALL generate an Ed25519 key pair and store the private key exclusively in OS-native secure storage. The public key SHALL be stored in the local database as a signing identity. The private key SHALL NOT be written to the SQLite database under any circumstance, and SHALL NEVER leave the device: it SHALL NOT be shown, exported, or included in any file the app writes. On iOS and macOS the private key SHALL be stored with this-device-only accessibility and not synchronized, so it does not travel in iCloud, Finder, or device-to-device transfers; an install that stored its key before this rule SHALL re-save the same key with this-device-only accessibility on its first launch after updating, without changing the key. A device that holds books but not their key SHALL get its own new identity through `device-continuation`, never by importing a key.

#### Scenario: First launch generates a signing identity
- **WHEN** the application is launched for the first time
- **THEN** an Ed25519 key pair is generated, the private key is stored in OS secure storage, and a corresponding signing identity row is created before any starter account or journal entry exists

#### Scenario: The private key is never exported
- **WHEN** the user saves a Books Copy, exports CSV, or uses any other export
- **THEN** no file written by the app contains private key material

#### Scenario: Existing Apple installs re-save the key as this-device-only
- **WHEN** an iOS or macOS install whose key was stored before this change launches for the first time after updating
- **THEN** the same key is re-saved with this-device-only accessibility and the books keep verifying and recording normally

### Requirement: Re-anchoring After a Break
When a break is detected, new transactions SHALL chain onto the last entry verified before the break point, not onto the compromised tip. The system SHALL record an integrity event describing the break and the re-anchor point. The same rule applies when a device continues damaged books under a new identity (`device-continuation`): the new identity's first entry chains onto the last verified entry.

#### Scenario: A new transaction after a break chains onto the last verified entry
- **WHEN** the user records a new transaction after a break has been detected
- **THEN** the new entry's previous hash references the last verified entry before the break, and an integrity event recording the break and re-anchor point is stored

#### Scenario: Legitimate entries in the quarantined tail require manual re-entry
- **WHEN** the user reviews a quarantined entry and determines it reflects a real transaction
- **THEN** the user can record it again as an ordinary new transaction chained onto the current trusted tip; the system does not automatically restore or re-trust the quarantined entry itself

#### Scenario: Continuation of damaged books re-anchors on the trusted tip
- **WHEN** a device continues books with a break under a new identity and records a new transaction
- **THEN** the new entry, signed by the new identity, chains onto the last verified entry before the break

### Requirement: Migration-Superseded Entries Are Visibly Marked
Key-loss migration is no longer offered, but books may still contain entries superseded by a migration performed with an earlier version of the app. Such a journal entry SHALL remain verifiable against its original identity, SHALL remain visible in the register and SHALL be marked as a historical, superseded record. The mark SHALL be distinct from the unverifiable/quarantine treatment used after a chain break. The superseded entry's amounts SHALL remain excluded from running balance and summary totals.

#### Scenario: A superseded entry is labeled in the register
- **WHEN** the user views the register of books that contain entries superseded by an earlier key-loss migration
- **THEN** each pre-migration entry is shown with a historical/superseded indication
- **AND** the entry is not hidden
- **AND** its amount is not included in the running balance

## ADDED Requirements

### Requirement: Optional Books Copy, No Key Export
The system SHALL make saving a Books Copy (see `books-copy`) available from Settings at any time, and SHALL NOT block recording a transaction, navigating the app, or resuming the app on it being completed. The system SHALL NOT offer a recovery phrase, a keystore file, or any other export of the signing key. The system SHALL NOT depend on any specific external storage provider or on a server-side escrow.

#### Scenario: Onboarding never blocks on backup setup
- **WHEN** a user completes first-time setup, with or without recording a first transaction
- **THEN** they can continue using the app — recording further transactions, navigating anywhere, backgrounding or killing and reopening the app — without ever completing a backup step

#### Scenario: Saving a copy remains available on request
- **WHEN** the user opens Settings at any time
- **THEN** "Save a copy of my books" is available, and the user may leave it at any time without saving

#### Scenario: No key export is offered
- **WHEN** the user looks through Settings and onboarding
- **THEN** there is no option to view a recovery phrase, export a keystore file, or otherwise export the signing key

#### Scenario: Signing identity generation is unaffected
- **WHEN** the application is launched for the very first time
- **THEN** the signing identity is generated automatically before the first-account screen is shown, exactly as `Device Signing Identity` already specifies

## REMOVED Requirements

### Requirement: Optional Recovery and Backup Setup
**Reason**: The recovery phrase display and keystore export it guaranteed are removed; the device migration bundle is replaced by the Books Copy.
**Migration**: See `Optional Books Copy, No Key Export` and `books-copy`.

### Requirement: Recoverable Reinstall or Device Migration
**Reason**: The recovery phrase and keystore file are removed; the private key never leaves the device.
**Migration**: A reinstalled or new device continues the books under its own new identity (`device-continuation`), or restores a Books Copy (`books-copy`). No re-signing is needed in either case.

### Requirement: True Key-Loss Migration
**Reason**: Continuation makes re-signing unnecessary: entries stay verifiable with their original public key, so losing the private key no longer means re-creating history.
**Migration**: Books without their key use "Continue my books on this phone" (`device-continuation`). Entries already superseded by an earlier migration stay visible and verifiable (see `Migration-Superseded Entries Are Visibly Marked`).
