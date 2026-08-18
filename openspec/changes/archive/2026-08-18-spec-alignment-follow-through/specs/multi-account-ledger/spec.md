## MODIFIED Requirements

### Requirement: Per-Account Balance and Register
The system SHALL compute a current display balance for each financial account from its postings (asset balance = sum of included postings; liability amount owed = negated sum of included postings). The system SHALL provide a reverse-chronological register for a selected financial account showing a running display balance for that account. The most recently dated entry SHALL be listed first, so that it and the account's current balance are visible without scrolling. Running-balance amounts SHALL still be computed oldest-to-newest so each row's balance is as of that entry. Register rows SHALL correctly represent income/expense entries (category counterpart), transfers (counterparty account counterpart), and opening-balance entries (opening-balance counterpart label). The register SHALL remain fully readable for an archived financial account, including its history and current balance. The register's add-transaction control SHALL be disabled whenever the account currently selected in the register is archived.

#### Scenario: Register is scoped to one account
- **WHEN** the user opens the register for a specific financial account
- **THEN** posted entries that affect that account are listed in reverse-chronological order, most recent transaction date first
- **AND** each row shows the running display balance of that account as of that entry

#### Scenario: Transfer row shows the counterparty account
- **WHEN** the user views a transfer entry in an account’s register
- **THEN** the row identifies the other financial account involved in the transfer
- **AND** the amount and direction are relative to the viewed account

#### Scenario: Opening-balance row is labeled as such
- **WHEN** the user views an opening-balance entry in an account’s register
- **THEN** the row is labeled as an opening balance (not as an Income or Expense category)

#### Scenario: Current balance matches postings
- **WHEN** the user views a financial account’s current balance
- **THEN** the balance equals the account’s display balance as of its latest included posting (or zero if there are no included postings)

#### Scenario: Quarantined and superseded postings are excluded from balance
- **WHEN** an entry affecting a financial account has been marked unverifiable following a detected chain break, or has been superseded by a true-key-loss migration
- **THEN** that entry's postings are excluded from the account's current balance and from its register's running balance, the same way they are excluded from the income/expense summary
- **AND** the entry itself remains visible in the account's register for review, never hidden

#### Scenario: Archived account register stays fully readable
- **WHEN** the user opens the register for an archived financial account
- **THEN** its historical entries, running balance, and current balance display exactly as they would for an active account

#### Scenario: Add-transaction control disabled for an archived account
- **WHEN** the user is viewing the register for an archived financial account
- **THEN** the add-transaction control is disabled and does not open the transaction-entry screen

#### Scenario: A newly recorded entry appears at the top
- **WHEN** the user records a new entry against the currently viewed account
- **THEN** the new entry appears as the first (topmost) row in the register
- **AND** its running balance equals the account's current balance
