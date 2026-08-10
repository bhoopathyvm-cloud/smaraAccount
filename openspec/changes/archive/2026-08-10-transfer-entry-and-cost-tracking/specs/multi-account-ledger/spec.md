## MODIFIED Requirements

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
