## ADDED Requirements

### Requirement: Transfers-in-Transit System Account
The system SHALL maintain a single internal system account used to hold the provisional side of cross-currency transfers and foreign-currency transactions awaiting settlement. This account SHALL NOT appear in any user-facing account picker, list, or overview, and its balance SHALL NOT be displayed as a single combined figure.

#### Scenario: System account never user-selectable
- **WHEN** the user is choosing a financial account for a transaction, a transfer, or account management, or viewing the home overview
- **THEN** the internal Transfers-in-transit account does not appear in any of those selections or displays

#### Scenario: System account balance is never shown as one number
- **WHEN** the user or any overview would otherwise display the Transfers-in-transit account's balance
- **THEN** the system instead shows its constituent pending transfers individually, never a single summed figure

### Requirement: Provisional Posting for Unknown-Amount Cross-Currency Movements
When a cross-currency transfer or foreign-currency transaction is recorded without a known final settlement amount, the system SHALL post a provisional journal entry immediately for the known side, balanced against the Transfers-in-transit account in the known currency, and SHALL create a pending transfer record awaiting settlement.

#### Scenario: Provisional entry for a transfer
- **WHEN** the user records a transfer between accounts in different-currency groups without knowing the destination amount
- **THEN** the system posts a balanced entry debiting the source account and crediting the Transfers-in-transit account, in the source currency
- **AND** creates a pending transfer with status pending

#### Scenario: Provisional entry for a foreign-currency transaction
- **WHEN** the user records an income or expense transaction whose native currency differs from the selected financial account's group currency, without knowing the account-currency amount
- **THEN** the system posts the category leg immediately in the transaction's native currency
- **AND** posts a balanced provisional entry for the account leg against the Transfers-in-transit account
- **AND** creates a pending transfer with status pending

### Requirement: Known-Rate Cross-Currency Movement Posts as a Single Entry
When the exact amount in the destination or account currency is known at the time a cross-currency transfer or foreign-currency transaction is recorded, the system SHALL post one complete journal entry covering both currencies immediately, and SHALL NOT create a pending transfer.

#### Scenario: Transfer with a known upfront rate
- **WHEN** the user records a cross-currency transfer and supplies both the source-currency amount and the exact destination-currency amount
- **THEN** the system posts a single complete entry affecting both financial accounts
- **AND** no pending transfer is created

#### Scenario: Foreign-currency transaction with a known upfront rate
- **WHEN** the user records a foreign-currency transaction and supplies both the transaction's native-currency amount and the exact account-currency amount
- **THEN** the system posts a single complete entry affecting the category and the financial account
- **AND** no pending transfer is created

### Requirement: Settle a Pending Transfer or Transaction
The user SHALL be able to settle a pending transfer or foreign-currency transaction by specifying which account actually received funds and the real settled amount. If the settled amount is less than the original provisional amount, the system SHALL post the shortfall as a fee or loss entry against a user-selected expense category, so that the Transfers-in-transit position opened by the provisional entry is always fully closed.

#### Scenario: Full settlement to the original destination
- **WHEN** the user settles a pending transfer by confirming the original destination account and the full expected amount
- **THEN** the system posts a balanced settlement entry crediting the destination account and debiting the Transfers-in-transit account
- **AND** the pending transfer's status becomes settled

#### Scenario: Settlement returns less than the original amount
- **WHEN** the user settles a pending transfer by specifying that funds returned to the original source account for less than the amount originally sent
- **THEN** the system posts a balanced settlement entry crediting the source account for the returned amount
- **AND** posts a second balanced entry debiting a user-selected expense category for the shortfall, crediting the Transfers-in-transit account
- **AND** the pending transfer's status becomes settled

#### Scenario: Settlement with a total loss
- **WHEN** the user settles a pending transfer indicating that none of the original amount was recovered
- **THEN** the system posts the full original amount as an entry against a user-selected expense category
- **AND** the pending transfer's status becomes settled

#### Scenario: Settlement always closes the provisional position
- **WHEN** a pending transfer is settled by any of the above scenarios
- **THEN** the settlement and any fee entry together account for exactly the amount opened by the provisional entry, leaving no unresolved balance for that transfer in the Transfers-in-transit account
