## MODIFIED Requirements

### Requirement: Rename and Archive Financial Accounts
The user SHALL be able to rename a financial account and archive a financial account that is no longer needed. Financial accounts SHALL NOT be permanently deleted. Archiving SHALL remove the account from pickers for new transactions and transfers (as both source and destination) while keeping historical entries, current balance, and the account itself fully visible in read-only views. The system SHALL reject archiving a financial account when it is the only remaining active financial account.

An archived financial account SHALL NOT be a party to any new transaction, and SHALL NOT be a party to any new transfer, except for a single closeout transfer: when an archived financial account has a strictly positive current display balance, the user SHALL be able to record exactly one transfer of that account's full current balance from the archived account to a different, active financial account. After that closeout transfer posts, the archived account's balance is zero and it is no longer eligible for any further transfer (its balance is no longer positive). An archived account with a zero or negative current display balance SHALL NOT offer a closeout transfer.

#### Scenario: Archive a financial account
- **WHEN** the user archives a financial account and at least one other active financial account still exists
- **THEN** the account is no longer offered when recording a new transaction or transfer
- **AND** the account and its historical entries remain visible in the register and home overview in a clearly inactive state

#### Scenario: Cannot archive the last active financial account
- **WHEN** the user attempts to archive the only remaining active financial account
- **THEN** the system rejects the action and the account remains active

#### Scenario: Rename a financial account
- **WHEN** the user renames a financial account
- **THEN** the new name is used going forward in lists, pickers, and the home overview

#### Scenario: Closeout transfer from an archived account with a positive balance
- **WHEN** the user records a transfer from an archived financial account that has a positive current display balance to a different, active financial account, for an amount equal to that account's full current balance
- **THEN** the system posts the transfer and the archived account's current display balance becomes zero

#### Scenario: Closeout transfer amount must equal the full balance
- **WHEN** the user attempts a transfer from an archived financial account for an amount other than that account's full current display balance
- **THEN** the system rejects the transfer and no journal entry is posted

#### Scenario: Closeout transfer destination must be active
- **WHEN** the user attempts a transfer from an archived financial account to another archived financial account
- **THEN** the system rejects the transfer and no journal entry is posted

#### Scenario: No closeout transfer once the balance is not positive
- **WHEN** the user views an archived financial account whose current display balance is zero or negative
- **THEN** the system does not offer a closeout transfer for that account

#### Scenario: Archived account rejected for an ordinary transaction
- **WHEN** the user attempts to record an income or expense transaction against an archived financial account
- **THEN** the system rejects the transaction and no journal entry is posted

### Requirement: Per-Account Balance and Register
The system SHALL compute a current display balance for each financial account from its postings (asset balance = sum of included postings; liability amount owed = negated sum of included postings). The system SHALL provide a chronological register for a selected financial account showing a running display balance for that account. Register rows SHALL correctly represent income/expense entries (category counterpart), transfers (counterparty account counterpart), and opening-balance entries (opening-balance counterpart label). The register SHALL remain fully readable for an archived financial account, including its history and current balance. The register's add-transaction control SHALL be disabled whenever the account currently selected in the register is archived.

#### Scenario: Register is scoped to one account
- **WHEN** the user opens the register for a specific financial account
- **THEN** posted entries that affect that account are listed in chronological order by transaction date
- **AND** each row shows the running display balance of that account as of that entry

#### Scenario: Transfer row shows the counterparty account
- **WHEN** the user views a transfer entry in an account's register
- **THEN** the row identifies the other financial account involved in the transfer
- **AND** the amount and direction are relative to the viewed account

#### Scenario: Opening-balance row is labeled as such
- **WHEN** the user views an opening-balance entry in an account's register
- **THEN** the row is labeled as an opening balance (not as an Income or Expense category)

#### Scenario: Current balance matches postings
- **WHEN** the user views a financial account's current balance
- **THEN** the balance equals the account's display balance as of its latest included posting (or zero if there are no included postings)

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
