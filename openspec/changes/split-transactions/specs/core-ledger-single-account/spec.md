## MODIFIED Requirements

### Requirement: Record a Transaction
The user SHALL record a transaction by providing a transaction date, an amount, a direction (money in or money out), a financial account, and either a single category or a **split** across two or more categories whose amounts sum exactly to the transaction total. The system SHALL derive a balanced double-entry journal entry from these inputs — one posting against the financial account and one posting per category leg — and the user SHALL NOT be required to select debit and credit accounts directly. A split SHALL be rejected before posting if its category amounts do not sum exactly to the transaction total, or if any category line is missing an active category.

#### Scenario: Record money in
- **WHEN** the user records a transaction as money in, with an amount, a transaction date, an Income category, and a financial account
- **THEN** the system posts a balanced journal entry affecting the selected Income category and the selected financial account

#### Scenario: Record money out
- **WHEN** the user records a transaction as money out, with an amount, a transaction date, an Expense category, and a financial account
- **THEN** the system posts a balanced journal entry affecting the selected Expense category and the selected financial account

#### Scenario: Archived category is not offered
- **WHEN** the user is choosing a category while recording a new transaction
- **THEN** archived categories do not appear in the selection

#### Scenario: Split across multiple categories
- **WHEN** the user records a 100 expense split into 60 against Food and 40 against Household
- **THEN** the system posts one journal entry with one financial-account posting of 100 and two category postings, 60 and 40
- **AND** each category posting uses its own active category

#### Scenario: Split amounts must sum to the total
- **WHEN** the user attempts to record a split whose category amounts do not sum to the transaction total
- **THEN** the system rejects the submit and no journal entry is posted
