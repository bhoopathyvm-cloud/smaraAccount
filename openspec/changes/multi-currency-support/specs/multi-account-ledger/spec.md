## MODIFIED Requirements

### Requirement: Transfer Between Financial Accounts
The user SHALL be able to record a transfer of a positive amount from one active financial account to another distinct active financial account, without using an Income or Expense category. When both accounts' groups share the same currency, the system SHALL post a single balanced journal entry that moves value between those two accounts. When the accounts' groups have different currencies, the system SHALL post the transfer using the `foreign-currency-settlement` capability: as a single complete entry when the destination amount is known at record time, or as a provisional entry now with settlement recorded later when it is not.

#### Scenario: Transfer between two same-currency accounts
- **WHEN** the user records a transfer with a positive amount, transaction date, source financial account, and destination financial account whose groups share the same currency
- **THEN** the system posts one balanced journal entry affecting only those two financial accounts
- **AND** the transfer does not change income or expense totals for any date range

#### Scenario: Cross-currency transfer with a known destination amount
- **WHEN** the user records a transfer between financial accounts in different-currency groups and supplies the exact destination-currency amount at record time
- **THEN** the system posts one complete journal entry with the source-currency amount and the destination-currency amount
- **AND** no pending transfer is created

#### Scenario: Cross-currency transfer with an unknown destination amount
- **WHEN** the user records a transfer between financial accounts in different-currency groups without knowing the exact destination-currency amount
- **THEN** the system posts a provisional entry debiting the source account and crediting the internal Transfers-in-transit account
- **AND** creates a pending transfer awaiting settlement

#### Scenario: Transfer to the same account is rejected
- **WHEN** the user attempts a transfer where source and destination are the same financial account
- **THEN** the system rejects the transfer and no journal entry is posted

#### Scenario: Non-positive transfer amount is rejected
- **WHEN** the user attempts a transfer with an amount of zero or a negative value
- **THEN** the system rejects the transfer and no journal entry is posted

### Requirement: Record Transaction Against a Selected Financial Account
When recording an income or expense transaction, the user SHALL select the financial account the money moves into or out of. The system SHALL derive a balanced double-entry journal entry between that financial account and the selected Income or Expense category. The user SHALL NOT be required to select debit and credit sides directly. When the transaction's native currency differs from the selected financial account's group currency, the system SHALL post the category leg immediately in the transaction's native currency and post the account leg using the `foreign-currency-settlement` capability: as part of a single complete entry when the account-currency amount is known at record time, or as a provisional entry settled later when it is not.

#### Scenario: Record money in to a chosen account
- **WHEN** the user records money in with an amount, transaction date, Income category, and a selected active asset or liability financial account whose group currency matches the transaction's native currency
- **THEN** the system posts a balanced journal entry affecting that financial account and the Income category

#### Scenario: Record money out from a chosen account
- **WHEN** the user records money out with an amount, transaction date, Expense category, and a selected active financial account whose group currency matches the transaction's native currency
- **THEN** the system posts a balanced journal entry affecting that financial account and the Expense category

#### Scenario: Foreign-currency expense with an unknown settlement amount
- **WHEN** the user records an expense against a financial account whose group currency differs from the transaction's native currency, without knowing the exact amount that will be charged to the account
- **THEN** the system posts the Expense category leg immediately in the transaction's native currency
- **AND** posts a provisional entry for the account leg through the internal Transfers-in-transit account, creating a pending transfer awaiting settlement
- **AND** the transaction's date, not its later settlement date, is used for income/expense summary reporting

#### Scenario: Archived financial account is not offered
- **WHEN** the user is choosing a financial account while recording a new transaction
- **THEN** archived financial accounts do not appear in the selection
