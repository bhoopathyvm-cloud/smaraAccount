## ADDED Requirements

### Requirement: Multiple Financial Accounts
The system SHALL allow the user to maintain zero or more financial accounts in addition to any seeded default. Each financial account SHALL have a name, a type of either asset or liability, and membership in exactly one account group. The account’s type SHALL NOT be changeable after creation (reassign group is allowed; convert asset↔liability is not).

#### Scenario: Create an asset account
- **WHEN** the user creates a financial account with type asset, a name, and an account group
- **THEN** the account becomes available for recording transactions, transfers, and the home overview
- **AND** its current balance starts at zero unless an opening balance was supplied

#### Scenario: Create a liability account
- **WHEN** the user creates a financial account with type liability, a name, and an account group
- **THEN** the account is treated as money owed for balance and net-position calculations
- **AND** the account becomes available for recording transactions and transfers

#### Scenario: Account type cannot be changed after creation
- **WHEN** the user attempts to change an existing financial account’s type from asset to liability or vice versa
- **THEN** the system rejects the change and the account type remains as created

### Requirement: Account Groups for Financial Accounts
The system SHALL provide account groups that classify financial accounts for overview rollups. The system SHALL seed at least these system groups on first use or migration: Cash & cash equivalents (asset), Pension & retirement (asset), Credit & short-term debt (liability), and Loans & mortgages (liability). In this change, the user SHALL NOT be able to create additional custom account groups. The user SHALL be able to rename a system account group.

#### Scenario: Seeded groups exist after setup or migration
- **WHEN** the application completes first-identity confirmation or migrates an existing pre-multi-account database
- **THEN** the four system account groups exist and are available for assignment

#### Scenario: Financial account requires a group
- **WHEN** the user creates or edits a financial account
- **THEN** the system requires selection of an account group whose kind matches the account type (asset accounts in asset groups, liability accounts in liability groups)

#### Scenario: Reassign a financial account to another group
- **WHEN** the user changes a financial account’s group to another group of the matching kind
- **THEN** the account appears under the new group on the home overview
- **AND** its balance is included in the new group’s total instead of the previous group’s total

#### Scenario: Reassignment to a mismatched-kind group is rejected
- **WHEN** the user attempts to reassign a financial account to a group whose kind does not match the account’s type (e.g. an asset account to a liability group)
- **THEN** the system rejects the reassignment and the account remains in its original group

#### Scenario: Rename a system account group
- **WHEN** the user renames a system account group
- **THEN** the new name is used on the home overview and in account-group pickers

### Requirement: System Account Groups Are Permanent and Renameable
The four seeded system account groups SHALL NOT be permanently deleted and SHALL NOT be archived. They remain available for assignment for the lifetime of the ledger. The user SHALL be able to rename a system account group. Empty groups (no member accounts) are simply omitted or de-emphasized on the home overview rather than archived.

#### Scenario: System group cannot be deleted
- **WHEN** the user attempts to permanently delete a system account group
- **THEN** the system rejects the action and the group remains

#### Scenario: System group cannot be archived
- **WHEN** the user attempts to archive a system account group
- **THEN** the system rejects the action and the group remains available for assignment

### Requirement: Rename and Archive Financial Accounts
The user SHALL be able to rename a financial account and archive a financial account that is no longer needed. Financial accounts SHALL NOT be permanently deleted. Archiving SHALL remove the account from pickers for new transactions and transfers while keeping historical entries and balances visible in read-only views. The system SHALL reject archiving a financial account when it is the only remaining active financial account.

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
The user SHALL be able to record a transfer of a positive amount from one active financial account to another distinct active financial account. The system SHALL post a single balanced journal entry that moves value between those two accounts without using an Income or Expense category. The user SHALL be able to reverse a posted transfer via the same reversal action used for other journal entries.

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

#### Scenario: Reverse a transfer
- **WHEN** the user reverses a posted transfer entry
- **THEN** the system posts a new journal entry that negates the original transfer’s postings
- **AND** the original transfer remains visible and unchanged

### Requirement: Per-Account Balance and Register
The system SHALL compute a current display balance for each financial account from its postings (asset balance = sum of included postings; liability amount owed = negated sum of included postings). The system SHALL provide a chronological register for a selected financial account showing a running display balance for that account. Register rows SHALL correctly represent income/expense entries (category counterpart), transfers (counterparty account counterpart), and opening-balance entries (opening-balance counterpart label).

#### Scenario: Register is scoped to one account
- **WHEN** the user opens the register for a specific financial account
- **THEN** posted entries that affect that account are listed in chronological order by transaction date
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

### Requirement: Opening Balance on Account Creation
When creating a financial account, the user SHALL be able to supply an optional opening balance. If an opening balance is supplied, it SHALL be a positive, non-zero amount. For an asset account, that amount SHALL mean funds held. For a liability account, that amount SHALL mean amount owed. The system SHALL post a balanced opening entry against the internal system equity account so the account’s current display balance equals that amount without recording it as user income or expense. Omitting the opening balance SHALL leave the account at zero with no opening entry.

#### Scenario: Create asset account with opening balance
- **WHEN** the user creates an asset financial account with a positive opening balance
- **THEN** the account’s current display balance equals that opening balance
- **AND** income and expense summaries are unchanged by the opening entry

#### Scenario: Create liability account with opening amount owed
- **WHEN** the user creates a liability financial account with a positive opening balance representing amount owed
- **THEN** the account’s current display balance (amount owed) equals that opening balance
- **AND** income and expense summaries are unchanged by the opening entry

#### Scenario: Non-positive opening balance is rejected
- **WHEN** the user attempts to create a financial account with an opening balance of zero or a negative value
- **THEN** the system rejects the create (or rejects the opening-balance portion) and does not post an opening entry

#### Scenario: The system offset account is never user-selectable
- **WHEN** the user is choosing a financial account for a transaction, a transfer, or account management, or viewing the home overview, or choosing a category
- **THEN** the internal system equity account used to balance opening-balance entries does not appear in any of those selections or displays

#### Scenario: Liability accounts are not offered as categories
- **WHEN** the user is choosing an Income or Expense category while recording a transaction
- **THEN** liability financial accounts and the system equity account do not appear in the category selection

### Requirement: Existing Single Account Migrates
When upgrading a database from the pre-multi-account schema (schema version 2) that has a financial asset account, the system SHALL keep that account’s identity and postings, assign it to the Cash & cash equivalents group, seed the system account groups and equity account, and SHALL NOT require the user to re-enter historical transactions.

#### Scenario: Migrate existing ledger
- **WHEN** an existing schema-version-2 database is opened after this capability is installed
- **THEN** the previous financial account still exists with the same id and balance
- **AND** it belongs to the Cash & cash equivalents group
- **AND** all prior journal entries remain intact
