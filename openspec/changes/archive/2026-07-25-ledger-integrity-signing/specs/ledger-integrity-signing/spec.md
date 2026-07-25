## ADDED Requirements

### Requirement: Device Signing Identity
On first install, before any journal entry can be recorded, the system SHALL generate an Ed25519 key pair and store the private key exclusively in OS-native secure storage. The public key SHALL be stored in the local database as a signing identity. The private key SHALL NOT be written to the SQLite database under any circumstance.

#### Scenario: First launch generates a signing identity
- **WHEN** the application is launched for the first time
- **THEN** an Ed25519 key pair is generated, the private key is stored in OS secure storage, and a corresponding signing identity row is created before any starter account or journal entry exists

### Requirement: Mandatory Recovery Phrase Acknowledgment
The system SHALL derive a human-readable recovery phrase from the signing key and require the user to acknowledge having saved it externally before the ledger can be used. The system SHALL also offer an optional encrypted keystore file export. The system SHALL NOT depend on any specific external storage provider or on a server-side escrow.

#### Scenario: Onboarding blocks until recovery phrase is acknowledged
- **WHEN** a user completes first-time setup
- **THEN** the recovery phrase is displayed with an explanation of the consequences of losing both the device and the phrase
- **AND** the user must confirm possession of the phrase (e.g. re-entering part of it) before recording their first transaction

#### Scenario: Optional keystore file export
- **WHEN** the user chooses to export an encrypted keystore file instead of, or in addition to, the recovery phrase
- **THEN** the system produces a passphrase-protected file the user can store in storage of their own choosing

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
When a break is detected, new transactions SHALL chain onto the last entry verified before the break point, not onto the compromised tip. The system SHALL record an integrity event describing the break and the re-anchor point.

#### Scenario: A new transaction after a break chains onto the last verified entry
- **WHEN** the user records a new transaction after a break has been detected
- **THEN** the new entry's previous hash references the last verified entry before the break, and an integrity event recording the break and re-anchor point is stored

#### Scenario: Legitimate entries in the quarantined tail require manual re-entry
- **WHEN** the user reviews a quarantined entry and determines it reflects a real transaction
- **THEN** the user can record it again as an ordinary new transaction chained onto the current trusted tip; the system does not automatically restore or re-trust the quarantined entry itself

### Requirement: Recoverable Reinstall or Device Migration
When the user has retained their recovery phrase or keystore file, importing it during setup SHALL re-derive the original signing key exactly, allowing the existing database's chain to be verified normally without re-signing any entry.

#### Scenario: Importing a valid recovery phrase restores the original identity
- **WHEN** a user imports a previously-saved recovery phrase during setup on a reinstalled or new device with the existing database file present
- **THEN** the same key pair is derived, the existing chain is verified using it, and no entry is re-signed or altered

### Requirement: True Key-Loss Migration
When no recovery phrase or keystore file is available, the system SHALL offer an explicit migration flow: the user reviews and confirms the current ledger state is valid, a new signing identity is generated, and every existing entry is re-signed as a new entry preserving its original content, with each new entry referencing the legacy entry it preserves. Legacy entries SHALL remain visible as read-only historical records and SHALL be excluded from active balances after migration. The confirmation step SHALL state plainly that migration does not retroactively prove pre-migration entries were untampered.

#### Scenario: User confirms current data and migrates to a new identity
- **WHEN** the user has no recovery phrase and chooses to migrate existing data forward
- **THEN** the system requires explicit confirmation that the current ledger state is accepted as valid before generating a new signing identity and proceeding

#### Scenario: Migrated entries preserve content and reference legacy entries
- **WHEN** migration proceeds
- **THEN** each existing entry is recreated as a new, signed entry with identical transaction content, referencing the original entry it preserves

#### Scenario: Legacy entries remain visible but excluded from active balances
- **WHEN** migration has completed
- **THEN** the pre-migration entries remain visible as historical records but are excluded from the running balance and summary, which are computed from the post-migration chain onward
