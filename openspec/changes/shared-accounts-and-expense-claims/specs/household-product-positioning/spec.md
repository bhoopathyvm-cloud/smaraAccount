## MODIFIED Requirements

### Requirement: Household Product Promise
The product SHALL be positioned as local books for households and small businesses: users record spent and received money in plain language, see where money went this month, and trust that posted history cannot be silently rewritten. Books MAY be shared across Linked devices on the same Wi-Fi without a server. Small businesses MAY run employee expense Claims that become books records only when approved. The signed double-entry ledger SHALL remain the implementation mechanism, not the user-facing vocabulary.

#### Scenario: User-facing flows avoid ledger jargon
- **WHEN** a user completes onboarding or records a transaction after Wave 1
- **THEN** primary actions use household terms (e.g. Spent, Received,
  Fix) rather than debit/credit or journal-entry language

#### Scenario: Linked devices stay in the product promise
- **WHEN** a visitor reads the positioning or glossary opening after Linked devices land
- **THEN** it allows books on more than one device for households and small businesses
- **AND** it still states that history is not silently rewritten

#### Scenario: Expense claims stay in the product promise
- **WHEN** a visitor reads the positioning after expense Claims land
- **THEN** it allows small-business Claims that post to the books only on approval
- **AND** it still states that no server holds books or private keys

### Requirement: Integrity Non-Negotiables
The repositioning program SHALL NOT introduce silent edit or delete of posted journal entries, SHALL NOT require a server to hold books or signing keys, SHALL NOT sync through a cloud relay, SHALL NOT treat unapproved Claims as posted history, and SHALL NOT auto-fill cross-currency amounts from reference rates as if they were actual settled amounts.

#### Scenario: Correction remains reversal-based
- **WHEN** a user fixes a posted transaction via the correction wizard
- **THEN** the system posts a reversal and a new entry rather than editing
  the original entry in place

#### Scenario: Sync does not introduce a server
- **WHEN** Linked devices catch up
- **THEN** traffic stays device to device on the local network
- **AND** no server holds books or private keys

#### Scenario: Unapproved claims are not posted history
- **WHEN** a Claimant submits a Claim that has not been approved
- **THEN** the company register does not show Journal Entries for those Claim Items
