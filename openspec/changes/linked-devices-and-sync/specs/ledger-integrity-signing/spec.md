## ADDED Requirements

### Requirement: Linked Device Identities Stay Active
When books are shared across Linked devices, the system SHALL keep every linked device's Signing Identity active in the books: each device's public key remains available for verification, and identities SHALL NOT be marked continued-from solely because another device joined. Each device SHALL sign only the journal entries it records, with its private key never leaving that device (ADR 0004).

#### Scenario: Two devices both remain current signers
- **WHEN** device A and device B are linked on the same books and each records a new entry
- **THEN** each entry is signed by that device's own Signing Identity
- **AND** both identities remain active for verification
- **AND** neither private key is present on the other device

#### Scenario: Continuation is distinct from linking
- **WHEN** a device continues books after restore or key loss (device-continuation) versus when it joins as a Linked device
- **THEN** Continuation may mark a prior identity continued-from on that device
- **AND** linking another device does not mark existing linked identities continued-from

### Requirement: Startup Verification Covers Every Linked Chain
On startup, the system SHALL verify every journal entry against the public key of the Signing Identity recorded in `signedByIdentityId`, including entries signed by other Linked devices. A break on one device's chain SHALL NOT automatically invalidate verified entries signed by a different linked identity.

#### Scenario: Peer-signed entries verify at startup
- **WHEN** the books contain entries signed by two linked identities and the app starts
- **THEN** each entry verifies against its own identity's public key
- **AND** balances include every verified entry from every linked identity
