## ADDED Requirements

### Requirement: Multi-chain verification against signedByIdentityId
The chain verifier SHALL verify each journal entry's signature against the public key of the Signing Identity named by that entry's `signedByIdentityId`, including when the books contain several active linked-device identities. The verifier SHALL treat each identity's hash chain independently for link checks, while still using only public keys already stored in the books.

#### Scenario: Entries from two devices both verify
- **WHEN** `verifyChain` runs on books that include entries signed by identity A and identity B, both active linked identities with public keys in the books
- **THEN** each entry's signature verifies against its own identity's public key
- **AND** a break in identity A's chain does not mark identity B's verified entries as the break point

#### Scenario: Missing public key fails closed
- **WHEN** an entry's `signedByIdentityId` has no matching public key in the books
- **THEN** that entry fails verification and is not treated as a trusted tip
