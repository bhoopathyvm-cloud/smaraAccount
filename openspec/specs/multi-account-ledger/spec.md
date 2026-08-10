# multi-account-ledger

## Purpose

Extend the single-account ledger core to support multiple financial accounts (asset and liability), account groups for overview rollups, transfers between accounts, per-account balances and registers, opening balances, and migration of the pre-existing single-account database. (Purpose derived from the `multi-account-support` change; refine as the capability evolves.)

## Requirements

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
The system SHALL provide account groups that classify financial accounts for overview rollups. The system SHALL seed at least these system groups on first use or migration: Cash & cash equivalents (asset), Pension & retirement (asset), Credit & short-term debt (liability), and Loans & mortgages (liability). The user SHALL be able to create additional account groups, each with a name, a kind (asset or liability), and a currency. The user SHALL be able to rename any account group, system or user-created. Reassigning a financial account to a different group additionally requires the destination group to have the same currency as the account's current group.

#### Scenario: Seeded groups exist after setup or migration
- **WHEN** the application completes first-identity confirmation or migrates an existing pre-multi-account database
- **THEN** the four system account groups exist and are available for assignment

#### Scenario: Create a custom account group
- **WHEN** the user creates a new account group with a name, a kind, and a currency
- **THEN** the group exists and is available for assignment to financial accounts of the matching kind
- **AND** the group is not a system group

#### Scenario: A new account group requires a currency
- **WHEN** the user attempts to create an account group without supplying a currency
- **THEN** the system rejects the creation

#### Scenario: Financial account requires a group
- **WHEN** the user creates or edits a financial account
- **THEN** the system requires selection of an account group whose kind matches the account type (asset accounts in asset groups, liability accounts in liability groups)

#### Scenario: Reassign a financial account to another group of the same currency
- **WHEN** the user changes a financial account's group to another group of the matching kind and the same currency
- **THEN** the account appears under the new group on the home overview
- **AND** its balance is included in the new group's total instead of the previous group's total

#### Scenario: Reassignment to a mismatched-kind group is rejected
- **WHEN** the user attempts to reassign a financial account to a group whose kind does not match the account’s type (e.g. an asset account to a liability group)
- **THEN** the system rejects the reassignment and the account remains in its original group

#### Scenario: Cross-currency reassignment is rejected
- **WHEN** the user attempts to reassign a financial account to a group with a different currency than its current group
- **THEN** the system rejects the reassignment and the account remains in its original group

#### Scenario: Rename an account group
- **WHEN** the user renames a system or user-created account group
- **THEN** the new name is used on the home overview and in account-group pickers

### Requirement: System Account Groups Are Permanent and Renameable
The four seeded system account groups SHALL NOT be permanently deleted and SHALL NOT be archived. They remain available for assignment for the lifetime of the ledger. The user SHALL be able to rename a system account group. A user-created account group SHALL be archivable once it has zero active member financial accounts; an archived user-created group SHALL NOT be permanently deleted. An empty, non-archived group (no active member accounts) is simply omitted or de-emphasized on the home overview rather than requiring archiving.

#### Scenario: System group cannot be deleted
- **WHEN** the user attempts to permanently delete a system account group
- **THEN** the system rejects the action and the group remains

#### Scenario: System group cannot be archived
- **WHEN** the user attempts to archive a system account group
- **THEN** the system rejects the action and the group remains available for assignment

#### Scenario: Archive a user-created account group with no active accounts
- **WHEN** the user archives a user-created account group that has zero active member financial accounts
- **THEN** the group no longer appears in account-group pickers offered for new assignments
- **AND** any account still historically associated with that group (e.g. an already-archived account) continues to resolve the group's name and currency normally

#### Scenario: Archiving a user-created group with an active account is rejected
- **WHEN** the user attempts to archive a user-created account group that has at least one active member financial account
- **THEN** the system rejects the action and the group remains available for assignment

#### Scenario: Archiving an already-archived group is rejected
- **WHEN** the user attempts to archive a user-created account group that is already archived
- **THEN** the system rejects the action

#### Scenario: A user-created account group cannot be permanently deleted
- **WHEN** the user attempts to permanently delete a user-created account group, archived or not
- **THEN** the system rejects the action

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

### Requirement: Transfer Between Financial Accounts
The user SHALL be able to record a transfer of a positive amount from one active financial account to another distinct active financial account, without using an Income or Expense category. The user SHALL be able to reverse a posted transfer via the same reversal action used for other journal entries. When both accounts' groups share the same currency, the system SHALL post a single balanced journal entry that moves value between those two accounts. When the accounts' groups have different currencies, the system SHALL post the transfer using the `foreign-currency-settlement` capability: as a single complete entry when the destination amount is known at record time, or as a provisional entry now with settlement recorded later when it is not.

The transfer entry point SHALL be reachable both from a standalone Transfer action and from the account-scoped register (an account's transaction history view), with the currently-viewed account pre-selected as the source when opened from the register. The register-scoped Transfer action SHALL be available only when the currently viewed financial account is active (not archived).

The user SHALL be able to optionally record a commission or fee associated with a transfer. When supplied, the fee SHALL be a positive amount in the source account's currency, SHALL require an active expense category, and SHALL be posted as a separate same-currency money-out expense transaction against the source account and that category, independent of and reversible independently from the transfer entry itself. When the user has entered a fee amount, the system SHALL validate that the fee is positive and that an active expense category is selected before posting the transfer; invalid fee configuration SHALL reject the submit without posting transfer or fee. If the transfer has already posted and the subsequent fee post fails, the system SHALL leave the transfer posted, SHALL NOT roll it back, and SHALL surface that the transfer succeeded while the fee failed.

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

#### Scenario: Reverse a transfer
- **WHEN** the user reverses a posted transfer entry
- **THEN** the system posts a new journal entry that negates the original transfer's postings
- **AND** the original transfer remains visible and unchanged

#### Scenario: Starting a transfer from the register pre-selects the viewed account
- **WHEN** the user is viewing an active account's register and starts a transfer from there
- **THEN** the transfer screen opens with that account already selected as the source
- **AND** the user only needs to choose the destination account and amount

#### Scenario: Register transfer action unavailable for archived accounts
- **WHEN** the user is viewing an archived financial account's register
- **THEN** the ordinary register-scoped Transfer action is not offered
- **AND** the user cannot start this ordinary transfer flow with that archived account pre-selected as the source

#### Scenario: Recording a transfer with a fee posts two independent entries
- **WHEN** the user records a transfer and supplies a positive fee amount and an active expense category
- **THEN** the system posts the transfer entry as usual
- **AND** separately posts a same-currency money-out entry for the fee amount against the source account and the chosen expense category
- **AND** reversing either entry does not affect the other

#### Scenario: Fee without category or non-positive fee is rejected
- **WHEN** the user attempts to record a transfer with a fee amount but no active expense category, or with a zero or negative fee amount
- **THEN** the system rejects the submit for that fee configuration
- **AND** neither a new transfer entry nor a new fee entry is posted as part of that invalid attempt

#### Scenario: Fee post failure after a successful transfer is surfaced clearly
- **WHEN** the transfer entry posts successfully and the subsequent fee `recordTransaction` call fails
- **THEN** the transfer entry remains posted
- **AND** the user is informed that the transfer was saved but the fee was not

#### Scenario: Recording a transfer without a fee is unchanged
- **WHEN** the user records a transfer without supplying a fee
- **THEN** only the transfer entry posts, exactly as before this change

#### Scenario: Fee may accompany a provisional cross-currency transfer
- **WHEN** the user records an unknown-destination-amount cross-currency transfer and also supplies a valid fee
- **THEN** the system posts the provisional transfer as usual
- **AND** posts the fee as a separate same-currency money-out on the source account

Reversing the provisional leg of a still-pending cross-currency transfer is governed by the `foreign-currency-settlement` capability's "A Provisional Entry Cannot Be Reversed Directly While Pending" requirement, not by this one.

### Requirement: Transfer Fee Can Be Deducted From the Transferred Amount
In addition to the default mode where a transfer fee posts as an additional debit on top of the transferred amount, the user SHALL be able to indicate, per transfer, that the fee is deducted from the entered amount rather than added to it. When this deducted-fee mode is selected and a valid fee is present, the amount actually moved by the transfer (and, for a known-rate cross-currency transfer, converted to the destination) SHALL be the entered amount minus the fee amount, while the total debited from the source account SHALL remain equal to the entered amount (transfer amount plus separately posted fee amount). The known destination amount field, when supplied, SHALL continue to represent the amount the user expects to arrive and SHALL NOT be altered by this mode. The system SHALL reject the submit, before posting either entry, if the fee amount is greater than or equal to the entered amount while deducted-fee mode is selected.

#### Scenario: Deducted fee reduces the transfer's own amount
- **WHEN** the user records a same-currency transfer of 100.00, supplies a fee of 1.62 with an active expense category, and selects deducted-fee mode
- **THEN** the transfer entry posts for 98.38 between the source and destination accounts
- **AND** a separate same-currency money-out fee entry of 1.62 posts against the source account and the chosen category
- **AND** the total amount debited from the source account across both entries is 100.00

#### Scenario: Deducted fee applies to a known-rate cross-currency transfer's source leg
- **WHEN** the user records a cross-currency transfer with a source amount of 100.00, a known destination amount, a fee of 1.62, and deducted-fee mode selected
- **THEN** the transfer's source-side amount used for the entry and its conversion is 98.38
- **AND** the destination amount posted is exactly the value the user entered, unmodified by the fee or the mode

#### Scenario: A fee that would consume the entire amount is rejected
- **WHEN** the user selects deducted-fee mode and enters a fee amount greater than or equal to the transfer amount
- **THEN** the system rejects the submit
- **AND** neither a transfer entry nor a fee entry is posted

#### Scenario: Fee mode defaults to additive, unchanged from existing behavior
- **WHEN** the user records a transfer with a fee and does not select deducted-fee mode
- **THEN** the transfer posts for the full entered amount
- **AND** the fee posts as an additional debit, as already specified by the transfer fee requirement

### Requirement: Per-Account Balance and Register
The system SHALL compute a current display balance for each financial account from its postings (asset balance = sum of included postings; liability amount owed = negated sum of included postings). The system SHALL provide a chronological register for a selected financial account showing a running display balance for that account. Register rows SHALL correctly represent income/expense entries (category counterpart), transfers (counterparty account counterpart), and opening-balance entries (opening-balance counterpart label). The register SHALL remain fully readable for an archived financial account, including its history and current balance. The register's add-transaction control SHALL be disabled whenever the account currently selected in the register is archived.

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

#### Scenario: Archived account register stays fully readable
- **WHEN** the user opens the register for an archived financial account
- **THEN** its historical entries, running balance, and current balance display exactly as they would for an active account

#### Scenario: Add-transaction control disabled for an archived account
- **WHEN** the user is viewing the register for an archived financial account
- **THEN** the add-transaction control is disabled and does not open the transaction-entry screen

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
