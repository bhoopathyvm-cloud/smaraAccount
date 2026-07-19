## MODIFIED Requirements

### Requirement: Single Financial Account
The system SHALL support one or more financial accounts (asset or liability) that transactions and transfers are recorded against. The historical constraint of exactly one financial account no longer applies; multi-account behavior is defined by the `multi-account-ledger` capability.

#### Scenario: Multiple accounts may exist
- **WHEN** the application is set up or the user creates additional financial accounts
- **THEN** one or more financial accounts may exist
- **AND** each income or expense transaction is recorded against a user-selected financial account

### Requirement: Record a Transaction
The user SHALL record a transaction by providing a transaction date, an amount, a direction (money in or money out), a category, and a financial account. The system SHALL derive a balanced double-entry journal entry from these inputs; the user SHALL NOT be required to select debit and credit accounts directly.

#### Scenario: Record money in
- **WHEN** the user records a transaction as money in, with an amount, a transaction date, an Income category, and a financial account
- **THEN** the system posts a balanced journal entry affecting the selected Income category and the selected financial account

#### Scenario: Record money out
- **WHEN** the user records a transaction as money out, with an amount, a transaction date, an Expense category, and a financial account
- **THEN** the system posts a balanced journal entry affecting the selected Expense category and the selected financial account

#### Scenario: Archived category is not offered
- **WHEN** the user is choosing a category while recording a new transaction
- **THEN** archived categories do not appear in the selection

### Requirement: Transaction Register
The system SHALL provide a chronological register of posted journal entries for a selected financial account, showing a running balance for that account.

#### Scenario: Register shows running balance
- **WHEN** the user opens the register for a financial account
- **THEN** posted entries that affect that account are listed in chronological order by transaction date
- **AND** each entry shows that account’s balance as of that entry

### Requirement: Income vs. Expense Summary
The system SHALL provide a summary of total income and total expense for a date range selected by the user. Transfer entries that do not involve Income or Expense categories SHALL NOT be included in those totals. The summary SHALL support an optional filter by financial account; when no filter is set, totals SHALL include all financial accounts.

#### Scenario: Summary for a selected range
- **WHEN** the user selects a start and end date for the summary
- **THEN** the system shows the total income and total expense posted within that range, based on transaction date
- **AND** transfers are excluded from those totals

#### Scenario: Summary filtered by account
- **WHEN** the user selects a financial account filter for the summary
- **THEN** the income and expense totals include only entries that affect that financial account within the date range
