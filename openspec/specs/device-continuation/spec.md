# device-continuation Specification

## Purpose
Let a device carry on with books whose signing key is not on this device, after a phone transfer, a reinstall or a restore, by giving the device its own new key that continues the verified history instead of re-recording it.

## Requirements

### Requirement: Books Without Their Key Offer Continuation
When the device holds books with entries but no private key matching the books' active Signing Identity, the system SHALL show a screen explaining that the books arrived on this phone without their key, offering "Continue my books on this phone" and "Restore from a copy". The system SHALL NOT ask for a recovery phrase or keystore file.

#### Scenario: Phone transfer brings books but not the key
- **WHEN** the app starts with existing entries and no matching private key in secure storage
- **THEN** the user sees "Continue my books on this phone" and "Restore from a copy", and no recovery-phrase or keystore option

### Requirement: Continuation Keeps History and Adds a New Key
Continuation SHALL verify the existing books against their stored public identities, generate a new Signing Identity for this device whose private key is stored only on this device, and record the previous active identity as continued from. The previous identities' entries SHALL remain active, verified and counted in balances, unchanged. No entry SHALL be re-signed, copied or re-recorded. The first entry signed by the new identity SHALL chain onto the last verified entry.

#### Scenario: Clean books continue without any copying
- **WHEN** the user continues books whose whole chain verifies
- **THEN** a new Signing Identity is created, every existing entry stays exactly as it was and remains verified and counted
- **AND** the next recorded entry is signed by the new identity and chains onto the last existing entry

#### Scenario: Entries signed by earlier identities verify forever
- **WHEN** the app verifies the chain at any later startup
- **THEN** entries signed by identities from before the Continuation verify against those identities' public keys

### Requirement: Continuation From Damaged Books
If verification finds a break during Continuation, the break point and every entry after it SHALL be quarantined exactly as after any break, and the new identity SHALL continue from the last entry verified before the break.

#### Scenario: Damaged tail is set aside and history continues
- **WHEN** the user continues books in which an entry fails verification
- **THEN** that entry and those after it are shown as unverified and excluded from totals
- **AND** the next new entry chains onto the last verified entry before the break

### Requirement: Continuation Is Recorded and Shown in Device History
Each Continuation SHALL append an integrity event naming the new and previous identities, the continuation point, and, when it followed a restore, when the copy was saved. Settings SHALL show a "Device history" list describing each Continuation in plain words, for example "Your books continued on this phone on 3 Oct 2026 (from a copy saved on 1 Oct)".

#### Scenario: Device history after a restore
- **WHEN** the user opens Device history after restoring a copy saved on 1 Oct and continuing on 3 Oct
- **THEN** it shows that the books continued on this phone on 3 Oct from a copy saved on 1 Oct

#### Scenario: Device history after a phone transfer
- **WHEN** the user opens Device history after continuing books that arrived without their key
- **THEN** it shows the date the books continued on this phone
