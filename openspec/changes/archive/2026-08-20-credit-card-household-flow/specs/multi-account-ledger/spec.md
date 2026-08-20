## ADDED Requirements

### Requirement: Liability Accounts May Be Flagged as Credit Cards
When creating a liability financial account, the user SHALL be able to mark it as a credit card. The flag SHALL NOT be changeable after creation. An asset account SHALL NOT be markable as a credit card. A credit-card-flagged account remains an ordinary liability account for balance, archive, rename, transfer, and transaction-recording purposes — the flag changes only labeling and capture-flow defaults, not posting behavior.

#### Scenario: Create a credit card account
- **WHEN** the user creates a liability financial account marked as a credit card, with a name and a group
- **THEN** the account is flagged as a credit card
- **AND** it behaves as an ordinary liability account for balance, transfers, and transaction recording

#### Scenario: An asset account cannot be flagged as a credit card
- **WHEN** the user attempts to mark an asset financial account as a credit card
- **THEN** the system rejects the create or the flag

#### Scenario: The credit-card flag is immutable
- **WHEN** the user attempts to change an existing account's credit-card flag after creation
- **THEN** the system rejects the change
