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

#### Scenario: A non-positive amount in either currency is rejected
- **WHEN** the user records a known-rate cross-currency transfer or transaction with a zero or negative amount in either currency
- **THEN** the system rejects the entry and nothing is posted

### Requirement: Settle a Pending Transfer or Transaction
The user SHALL be able to settle a pending transfer or foreign-currency transaction by specifying which account actually received funds and the real settled amount. Settling to the original destination account posts the received amount in the destination currency and closes the pending transfer on its own, with no shortfall comparison — the destination-currency amount was never a promised figure to compare against. Settling back to the original source account posts the returned amount in the same currency as the provisional entry; if that amount is less than the provisional amount, the system SHALL post the shortfall as a fee or loss entry against a user-selected expense category. Either way, the Transfers-in-transit position opened by the provisional entry is always left fully closed. For a pending item of kind foreign-currency transaction, the account that receives the settled amount SHALL always be the transaction's own financial account, using the same-currency shortfall comparison — there is no alternate destination to choose.

#### Scenario: Full settlement to the original destination
- **WHEN** the user settles a pending transfer by confirming the original destination account and the amount that arrived there
- **THEN** the system posts a balanced settlement entry crediting the destination account and debiting the Transfers-in-transit account, in the destination currency
- **AND** the pending transfer's status becomes settled with no shortfall or fee entry

#### Scenario: Settlement returns less than the original amount
- **WHEN** the user settles a pending transfer by specifying that funds returned to the original source account for less than the amount originally sent
- **THEN** the system posts a balanced settlement entry crediting the source account for the returned amount
- **AND** posts a second balanced entry debiting a user-selected expense category for the shortfall, crediting the Transfers-in-transit account, both in the source currency
- **AND** the pending transfer's status becomes settled

#### Scenario: Settlement with a total loss
- **WHEN** the user settles a pending transfer indicating that none of the original amount was recovered
- **THEN** the system posts the full original amount as an entry against a user-selected expense category
- **AND** the pending transfer's status becomes settled

#### Scenario: Settlement always closes the provisional position
- **WHEN** a pending transfer is settled by any of the above scenarios
- **THEN** the pending transfer's status becomes settled and it no longer requires any further entry, regardless of whether the settlement and provisional amounts share a currency

#### Scenario: A foreign-currency transaction always settles to its own account
- **WHEN** the user settles a pending item of kind foreign-currency transaction
- **THEN** the settled amount posts against the transaction's own financial account, using the same-currency shortfall comparison as settling a transfer back to its source, regardless of any other account the user might otherwise be able to name for a transfer

#### Scenario: A fee category is rejected when settling to the destination
- **WHEN** the user supplies a fee category while settling to the original destination account
- **THEN** the system rejects the settlement, since no shortfall comparison applies to a destination-currency settlement

#### Scenario: Negative settled amount is rejected
- **WHEN** the user attempts to settle a pending transfer with a negative settled amount
- **THEN** the system rejects the settlement and no entry is posted

#### Scenario: Settling an already-settled pending transfer is rejected
- **WHEN** the user attempts to settle a pending transfer whose status is already settled
- **THEN** the system rejects the settlement and no additional entry is posted

#### Scenario: Fee category must be an active expense category
- **WHEN** the user attempts to settle a pending transfer with a shortfall using a category that is not an active Expense-type category
- **THEN** the system rejects the settlement and no entry is posted

#### Scenario: A settlement to the source account cannot exceed the provisional amount
- **WHEN** the user attempts to settle a pending transfer back to its source account with an amount greater than the original provisional amount
- **THEN** the system rejects the settlement, and the user is expected to settle for the provisional amount and record any extra as an ordinary income transaction afterward

#### Scenario: An archived account can still receive a settlement
- **WHEN** the user settles a pending transfer whose source or destination account has since been archived
- **THEN** the settlement posts normally, since settling is not a new recording action gated on the account being active

### Requirement: A Provisional Entry Cannot Be Reversed Directly While Pending
A provisional entry SHALL NOT be reversed through the general journal-entry reversal action while its pending transfer's status is still pending, regardless of whether that pending transfer is a transfer or a foreign-currency transaction. Reversing it out is instead achieved by settling the pending transfer back to its own source account for the full provisional amount, with no fee. Once a pending transfer is settled, its provisional entry MAY be reversed normally like any other posted entry.

#### Scenario: Direct reversal of a pending provisional entry is rejected
- **WHEN** the user attempts to reverse an entry that is still the open provisional leg of a pending transfer
- **THEN** the system rejects the reversal and directs the user to settle the pending transfer instead

#### Scenario: Reversal works normally after settlement
- **WHEN** the user reverses a provisional entry whose pending transfer has already been settled
- **THEN** the system posts a normal reversal entry, the same as for any other posted entry
