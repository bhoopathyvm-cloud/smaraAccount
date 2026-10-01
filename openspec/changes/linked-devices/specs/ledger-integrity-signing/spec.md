## MODIFIED Requirements

### Requirement: Device Signing Identity
On first install, before any journal entry can be recorded, the system SHALL generate an Ed25519 key pair and store the private key exclusively in OS-native secure storage. The public key SHALL be stored in the local database as a signing identity. The private key SHALL NOT be written to the SQLite database under any circumstance, and SHALL NEVER leave the device: it SHALL NOT be shown, exported, sent to a linked device, or included in any file the app writes. On iOS and macOS the private key SHALL be stored with this-device-only accessibility and not synchronized, so it does not travel in iCloud, Finder, or device-to-device transfers; an install that stored its key before this rule SHALL re-save the same key with this-device-only accessibility on its first launch after updating, without changing the key. A device that holds books but not their key SHALL get its own new identity through `device-continuation`, never by importing a key. Each set of books on a device SHALL have its own signing identity. When books are shared between Linked Devices, every linked device SHALL have its own signing identity for those books, and the books SHALL store the public signing identity of every linked device so any device can verify any other device's records.

#### Scenario: First launch generates a signing identity
- **WHEN** the application is launched for the first time
- **THEN** an Ed25519 key pair is generated, the private key is stored in OS secure storage, and a corresponding signing identity row is created before any starter account or journal entry exists

#### Scenario: The private key is never exported
- **WHEN** the user saves a Books Copy, exports CSV, syncs with a linked device, or uses any other export
- **THEN** no file or message written by the app contains private key material

#### Scenario: Existing Apple installs re-save the key as this-device-only
- **WHEN** an iOS or macOS install whose key was stored before this change launches for the first time after updating
- **THEN** the same key is re-saved with this-device-only accessibility and the books keep verifying and recording normally

#### Scenario: A joining device gets its own identity
- **WHEN** a device joins shared books as a Linked Device
- **THEN** it generates its own signing identity for those books, and every linked device stores that identity's public key

### Requirement: Chained and Signed Journal Entries
Every journal entry SHALL include a hash of its canonical content plus the previous entry's hash in the chain of the device that made it, and SHALL be signed with that device's current signing identity's private key. Each signing identity SHALL keep its own chain, with its own position counter. The genesis entry of each chain SHALL use a well-defined constant previous hash rather than an arbitrary null.

#### Scenario: Recording a transaction produces a signed, chained entry
- **WHEN** a transaction is recorded
- **THEN** the resulting journal entry stores its own hash (covering its content and the previous entry's hash), a signature over that hash from the current signing identity, and its position in that identity's chain

#### Scenario: Reversal is also chained and signed
- **WHEN** a posted entry is reversed
- **THEN** the reversing entry is likewise hashed, chained to the current tip of the reversing device's chain, and signed, using the same mechanism as an ordinary transaction

#### Scenario: Two linked devices keep separate chains
- **WHEN** two linked devices each record entries
- **THEN** each device's entries form their own unbroken chain, and both chains are present on both devices after syncing

### Requirement: Startup Integrity Verification
On every application startup, the system SHALL verify every chain in the open books: recomputing each entry's hash, checking its signature against the identity that signed it, and confirming each entry's stored previous hash matches the prior entry's actual hash in the same chain. A break in one device's chain SHALL NOT affect the verification of another device's chain.

#### Scenario: A fully intact chain verifies without issue
- **WHEN** the application starts and no entry has been altered outside the application
- **THEN** every entry is confirmed verified and no entry is excluded from balances or reports

#### Scenario: The first broken entry becomes the break point
- **WHEN** verification finds an entry whose stored hash, signature, or previous-hash linkage does not match what is recomputed
- **THEN** that entry is identified as the break point of its chain and no earlier entry is affected by it

#### Scenario: A break in one chain leaves others verified
- **WHEN** one linked device's chain has a break point
- **THEN** entries in the other devices' chains remain verified and counted
