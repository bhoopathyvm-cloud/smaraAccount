## ADDED Requirements

### Requirement: Sync Claims Receipts and Advances Over Peer Sync
Peer Sync SHALL exchange Claim, Claim Item, decision, Advance, and receipt-blob payloads for the books set in addition to Journal Entry batches and metadata ops. Private keys SHALL NEVER appear in those payloads. Sync SHALL remain same-Wi-Fi only.

#### Scenario: Submitted claim reaches Approver on sync
- **WHEN** a Claimant submits a Claim on device A and syncs with Approver device B on the same Wi-Fi
- **THEN** device B stores the Claim and its items for review
- **AND** no private key is transferred

#### Scenario: Receipt blob syncs with claim item
- **WHEN** a Claim Item on A has a receipt and A syncs with B
- **THEN** B can read the receipt for that item after sync

### Requirement: Claimant Peers Receive Scoped Sync Only
When the remote peer's membership on these books is Claimant only, the outbound sync batch SHALL include only that Claimant's claims and related decisions, receipts, advances, payments affecting their balance, the claim-category allowlist, spending-limit hints, and identities needed to verify those payloads. The batch SHALL NOT include other Journal Entries, other people's claims, or company bank account registers.

#### Scenario: Claimant sync omits bank register entries
- **WHEN** an Owner device syncs with a Claimant-only peer
- **THEN** the Claimant device does not receive Journal Entries for company bank activity unrelated to that Claimant's owed balance
- **AND** the Claimant device does receive their own Claims and receipt attachments

#### Scenario: Full-role peers still get full sync
- **WHEN** two Owner or Member devices sync
- **THEN** they continue to exchange full entry batches and metadata as before
