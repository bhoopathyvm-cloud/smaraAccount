# ledger-integrity-signing

## Purpose

Protect the local ledger with a device signing identity, hash-chained signed journal entries, startup integrity verification, quarantine/re-anchoring after breaks, and recovery or true key-loss migration flows. For users, this provides verified history: the app can warn when stored books no longer match what was originally signed, rather than silently counting damaged or modified entries.

## Background References

These references are non-normative context for the integrity model:

- [NIST: integrity](https://csrc.nist.gov/glossary/term/integrity)
- [NIST: digital signature](https://csrc.nist.gov/glossary/term/digital_signature)
- [NIST: hash function](https://csrc.nist.gov/glossary/term/hash_function)
- [OWASP Logging Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Logging_Cheat_Sheet.html)
- [Schneier/Kelsey: Secure Audit Logs to Support Computer Forensics](https://www.schneier.com/academic/archives/1999/05/secure_audit_logs_to.html)
- [AWS QLDB journal overview](https://aws.amazon.com/blogs/aws/now-available-amazon-quantum-ledger-database-qldb/)

## Requirements

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

### Requirement: Chained and Signed Journal Entries
Every journal entry SHALL include a hash of its canonical content plus the previous entry's hash, and SHALL be signed with the current signing identity's private key. The genesis entry's previous hash SHALL be a well-defined constant rather than an arbitrary null.

#### Scenario: Recording a transaction produces a signed, chained entry
- **WHEN** a transaction is recorded
- **THEN** the resulting journal entry stores its own hash (covering its content and the previous entry's hash), a signature over that hash from the current signing identity, and its position in the device's chain

#### Scenario: Reversal is also chained and signed
- **WHEN** a posted entry is reversed
- **THEN** the reversing entry is likewise hashed, chained to the current tip, and signed — using the same mechanism as an ordinary transaction

### Requirement: Startup Integrity Verification
On every application startup, the system SHALL verify the entire chain: recomputing each entry's hash, checking its signature against the identity that signed it, and confirming each entry's stored previous hash matches the prior entry's actual hash.

#### Scenario: A fully intact chain verifies without issue
- **WHEN** the application starts and no entry has been altered outside the application
- **THEN** every entry is confirmed verified and no entry is excluded from balances or reports

#### Scenario: The first broken entry becomes the break point
- **WHEN** verification finds an entry whose stored hash, signature, or previous-hash linkage does not match what is recomputed
- **THEN** that entry is identified as the break point and no earlier entry is affected by it

### Requirement: Quarantine of Entries After a Break
An entry identified as the break point, and every entry chained after it, SHALL be excluded from balance and summary calculations, but SHALL remain visible in the register for review. These entries SHALL NOT be deleted or hidden.

#### Scenario: Quarantined entries are visible but excluded from totals
- **WHEN** a break point has been identified
- **THEN** the break-point entry and all entries chained after it are visibly marked as unverifiable in the register
- **AND** none of their amounts are included in the running balance or the income/expense summary

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
