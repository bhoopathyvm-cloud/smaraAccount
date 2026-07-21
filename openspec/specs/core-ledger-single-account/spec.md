# core-ledger-single-account

## Purpose

Provide the foundational double-entry accounting core for a single user on a single device: one financial account, a small starter chart of Income/Expense categories, transaction recording that derives a balanced journal entry without asking the user to pick debit/credit sides, strict immutability of posted entries with correction via reversal, a chronological register with running balance, and an income-vs-expense summary for a selected date range. No networking, multi-account, or business-feature support is in scope here — later changes build on this domain model without needing to reshape it.

## Requirements

### Requirement: Starter Chart of Accounts
The system SHALL provide a small starter set of Income and Expense categories on first use, so the user is not required to define every category before recording a transaction.

#### Scenario: First launch provides starter categories
- **WHEN** the user opens the application for the first time
- **THEN** a small default set of Income and Expense categories exists and is available for use without any setup step

### Requirement: Single Financial Account
The system SHALL support one or more financial accounts (asset or liability) that transactions and transfers are recorded against. The historical constraint of exactly one financial account no longer applies; multi-account behavior is defined by the `multi-account-ledger` capability.

#### Scenario: Multiple accounts may exist
- **WHEN** the application is set up or the user creates additional financial accounts
- **THEN** one or more financial accounts may exist
- **AND** each income or expense transaction is recorded against a user-selected financial account

### Requirement: Category Management
The user SHALL be able to rename a category, add a new category, and archive a category that is no longer needed. Categories SHALL NOT be permanently deleted.

#### Scenario: Rename a category
- **WHEN** the user renames an existing category
- **THEN** the category's new name is used going forward, and previously posted entries retain the description they were given at posting time

#### Scenario: Add a new category
- **WHEN** the user creates a new Income or Expense category
- **THEN** the category becomes available for selection when recording a transaction

#### Scenario: Archive a category
- **WHEN** the user archives a category
- **THEN** the category is no longer offered when recording a new transaction
- **AND** the category and any entries that reference it remain fully visible in read-only views (register, summary)

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

### Requirement: Transaction Amount Validation
The system SHALL require every transaction amount to be a positive, non-zero value. A zero or negative amount SHALL be rejected before any journal entry is posted.

#### Scenario: Zero or negative amount is rejected
- **WHEN** the user attempts to record a transaction with an amount of zero or a negative value
- **THEN** the system rejects the transaction and no journal entry is posted

### Requirement: Transaction Date and Recorded Timestamp
Every journal entry SHALL carry two distinct points in time: a transaction date supplied by the user (when the transaction occurred), and a recorded-at timestamp captured automatically by the system at the moment of posting (when it was entered). The user SHALL NOT be able to set or edit the recorded-at timestamp.

#### Scenario: Both timestamps are captured
- **WHEN** a user posts a transaction with a transaction date that differs from today
- **THEN** the entry stores the user-supplied transaction date as given
- **AND** the entry stores a recorded-at timestamp set automatically by the system to the current time, independent of the transaction date

### Requirement: Immutable Posted Entries
Once posted, a journal entry SHALL NOT be edited or deleted by any user action.

#### Scenario: Editing a posted entry is not possible
- **WHEN** the user attempts to modify or delete a posted journal entry
- **THEN** the system prevents the action and the entry remains unchanged

### Requirement: Correct a Posted Entry via Reversal
The user SHALL be able to reverse a posted entry as a single, independent, ordinary action. Reversing an entry SHALL create a new journal entry with the debit and credit sides swapped from the original, referencing the entry it reverses. Entering a corrected transaction, if one is needed, SHALL be a separate, ordinary transaction with no required system-enforced link back to the reversal.

#### Scenario: Reverse a posted entry
- **WHEN** the user chooses to reverse a posted journal entry
- **THEN** the system posts a new journal entry that swaps the debit and credit sides of the original amount and category
- **AND** the new entry records which entry it reverses
- **AND** the original entry remains visible and unchanged in the register

#### Scenario: Entering the corrected transaction is independent
- **WHEN** the user records the correct version of a transaction after reversing the mistaken one
- **THEN** the system posts it as an ordinary new transaction, with no special linkage required to the reversal

### Requirement: Transaction Register
The system SHALL provide a chronological register of posted journal entries for a selected financial account, showing a running balance for that account.

#### Scenario: Register shows running balance
- **WHEN** the user opens the register for a financial account
- **THEN** posted entries that affect that account are listed in chronological order by transaction date
- **AND** each entry shows that account’s balance as of that entry

### Requirement: Income vs. Expense Summary
The system SHALL provide a summary of total income and total expense for a date range selected by the user. Transfer entries and opening-balance entries SHALL NOT be included in those totals. The summary SHALL support an optional filter by financial account; when no filter is set, totals SHALL include all financial accounts.

#### Scenario: Summary for a selected range
- **WHEN** the user selects a start and end date for the summary
- **THEN** the system shows the total income and total expense posted within that range, based on transaction date
- **AND** transfers and opening-balance entries are excluded from those totals

#### Scenario: Summary filtered by account
- **WHEN** the user selects a financial account filter for the summary
- **THEN** the income and expense totals include only entries that affect that financial account within the date range
