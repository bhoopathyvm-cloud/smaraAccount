## MODIFIED Requirements

### Requirement: Household Product Promise
The product SHALL be positioned as local books for households and small businesses, as equal audiences. Users record spent and received money in plain language, see where money went this month, and trust that posted history cannot be silently rewritten. The books MAY be shared between Linked Devices, such as a partner's phone or a colleague's computer, without any server. The signed double-entry ledger SHALL remain the implementation mechanism, not the user-facing vocabulary.

#### Scenario: User-facing flows avoid ledger jargon
- **WHEN** a user completes onboarding or records a transaction after Wave 1
- **THEN** primary actions use household terms (e.g. Spent, Received,
  Fix) rather than debit/credit or journal-entry language

#### Scenario: A small business shares books between two devices
- **WHEN** a small business links an office computer and a phone to the same books
- **THEN** both devices record into the same books in the same plain language, without creating any online account

### Requirement: Integrity Non-Negotiables
The product SHALL NOT introduce silent edit or delete of posted journal entries, SHALL NOT require a server to hold, relay or synchronize books or signing keys, and SHALL NOT auto-fill cross-currency amounts from reference rates as if they were actual settled amounts. Sharing books between devices SHALL happen only directly over the local network.

#### Scenario: Correction remains reversal-based
- **WHEN** a user fixes a posted transaction via the correction wizard
- **THEN** the system posts a reversal and a new entry rather than editing
  the original entry in place

#### Scenario: Sharing needs no server
- **WHEN** two linked devices share books
- **THEN** no books data, setting or key is sent to any server, cloud service or relay
