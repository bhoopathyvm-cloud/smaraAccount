## ADDED Requirements

### Requirement: Multiple Financial Accounts
The system SHALL allow the user to maintain zero or more financial accounts in addition to any seeded default. Each financial account SHALL have a name, a type of either asset or liability, and membership in exactly one account group.

#### Scenario: Create an asset account
- **WHEN** the user creates a financial account with type asset, a name, and an account group
- **THEN** the account becomes available for recording transactions, transfers, and the home overview
- **AND** its current balance starts at zero unless an opening balance was supplied

#### Scenario: Create a liability account
- **WHEN** the user creates a financial account with type liability, a name, and an account group
- **THEN** the account is treated as money owed for balance and net-position calculations
- **AND** the account becomes available for recording transactions and transfers

### Requirement: Account Groups for Financial Accounts
The system SHALL provide account groups that classify financial accounts for overview rollups. The system SHALL seed at least these system groups on first use or migration: Cash & cash equivalents (asset), Pension & retirement (asset), Credit & short-term debt (liability), and Loans & mortgages (liability).

#### Scenario: Seeded groups exist after setup or migration
- **WHEN** the application completes first-identity confirmation or migrates an existing single-account database
- **THEN** the four system account groups exist and are available for assignment

#### Scenario: Financial account requires a group
- **WHEN** the user creates or edits a financial account
- **THEN** the system requires selection of an account group whose kind matches the account type (asset accounts in asset groups, liability accounts in liability groups)

### Requirement: System Account Groups Cannot Be Deleted
The four seeded system account groups SHALL NOT be permanently deleted. A system account group MAY be archived once it has no active financial accounts assigned to it; the system SHALL prevent archiving a system account group that still has at least one active financial account.

#### Scenario: System group with no active accounts can be archived
- **WHEN** the user archives a system account group that currently has zero active financial accounts
- **THEN** the group is archived and no longer offered when assigning a group to a financial account

#### Scenario: System group with active accounts cannot be archived
- **WHEN** the user attempts to archive a system account group that still has at least one active financial account
- **THEN** the system rejects the action and the group remains active

### Requirement: Rename and Archive Financial Accounts
The user SHALL be able to rename a financial account and archive a financial account that is no longer needed. Financial accounts SHALL NOT be permanently deleted. Archiving SHALL remove the account from pickers for new transactions and transfers while keeping historical entries and balances visible in read-only views.

#### Scenario: Archive a financial account
- **WHEN** the user archives a financial account
- **THEN** the account is no longer offered when recording a new transaction or transfer
- **AND** the account and its historical entries remain visible in the register and home overview in a clearly inactive state

#### Scenario: Rename a financial account
- **WHEN** the user renames a financial account
- **THEN** the new name is used going forward in lists, pickers, and the home overview

### Requirement: Record Transaction Against a Selected Financial Account
When recording an income or expense transaction, the user SHALL select the financial account the money moves into or out of. The system SHALL derive a balanced double-entry journal entry between that financial account and the selected Income or Expense category. The user SHALL NOT be required to select debit and credit sides directly.

#### Scenario: Record money in to a chosen account
- **WHEN** the user records money in with an amount, transaction date, Income category, and a selected active asset or liability financial account
- **THEN** the system posts a balanced journal entry affecting that financial account and the Income category

#### Scenario: Record money out from a chosen account
- **WHEN** the user records money out with an amount, transaction date, Expense category, and a selected active financial account
- **THEN** the system posts a balanced journal entry affecting that financial account and the Expense category

#### Scenario: Archived financial account is not offered
- **WHEN** the user is choosing a financial account while recording a new transaction
- **THEN** archived financial accounts do not appear in the selection

### Requirement: Transfer Between Financial Accounts
The user SHALL be able to record a transfer of a positive amount from one active financial account to another distinct active financial account. The system SHALL post a single balanced journal entry that moves value between those two accounts without using an Income or Expense category.

#### Scenario: Transfer between two accounts
- **WHEN** the user records a transfer with a positive amount, transaction date, source financial account, and destination financial account
- **THEN** the system posts one balanced journal entry affecting only those two financial accounts
- **AND** the transfer does not change income or expense totals for any date range

#### Scenario: Transfer to the same account is rejected
- **WHEN** the user attempts a transfer where source and destination are the same financial account
- **THEN** the system rejects the transfer and no journal entry is posted

#### Scenario: Non-positive transfer amount is rejected
- **WHEN** the user attempts a transfer with an amount of zero or a negative value
- **THEN** the system rejects the transfer and no journal entry is posted

### Requirement: Per-Account Balance and Register
The system SHALL compute a current balance for each financial account from its postings, using an asset-appropriate or liability-appropriate display convention. The system SHALL provide a chronological register for a selected financial account showing a running balance for that account.

#### Scenario: Register is scoped to one account
- **WHEN** the user opens the register for a specific financial account
- **THEN** posted entries that affect that account are listed in chronological order by transaction date
- **AND** each row shows the running balance of that account as of that entry

#### Scenario: Current balance matches postings
- **WHEN** the user views a financial account’s current balance
- **THEN** the balance equals the account’s balance as of its latest posting (or zero if there are no postings)

#### Scenario: Quarantined and superseded postings are excluded from balance
- **WHEN** an entry affecting a financial account has been marked unverifiable following a detected chain break, or has been superseded by a true-key-loss migration
- **THEN** that entry's postings are excluded from the account's current balance and from its register's running balance, the same way they are excluded from the income/expense summary
- **AND** the entry itself remains visible in the account's register for review, never hidden

### Requirement: Opening Balance on Account Creation
When creating a financial account, the user SHALL be able to supply an optional opening balance. If supplied, the system SHALL post a balanced opening entry so the account’s current balance equals that amount without recording it as user income or expense.

#### Scenario: Create account with opening balance
- **WHEN** the user creates a financial account with a non-zero opening balance
- **THEN** the account’s current balance equals that opening balance
- **AND** income and expense summaries are unchanged by the opening entry

#### Scenario: The system offset account is never user-selectable
- **WHEN** the user is choosing a financial account for a transaction, a transfer, or account management, or viewing the home overview
- **THEN** the internal system account used to balance opening-balance entries does not appear in any of those selections or displays

### Requirement: Existing Single Account Migrates
When upgrading a database that has exactly one financial asset account from the single-account era, the system SHALL keep that account’s identity and postings, assign it to the Cash & cash equivalents group, and SHALL NOT require the user to re-enter historical transactions.

#### Scenario: Migrate existing ledger
- **WHEN** an existing single-account database is opened after this capability is installed
- **THEN** the previous financial account still exists with the same id and balance
- **AND** it belongs to the Cash & cash equivalents group
- **AND** all prior journal entries remain intact
