## MODIFIED Requirements

### Requirement: Settle a Pending Transfer or Transaction
The user SHALL be able to settle a pending transfer or foreign-currency transaction by specifying which account actually received funds and the real settled amount. Settling to the original destination account posts the received amount in the destination currency and closes the pending transfer on its own, with no shortfall comparison — the destination-currency amount was never a promised figure to compare against. Settling back to the original source account posts the returned amount in the same currency as the provisional entry; if that amount is less than the provisional amount, the system SHALL post the shortfall as a fee or loss entry against a user-selected expense category. Either way, the Transfers-in-transit position opened by the provisional entry is always left fully closed. For a pending item of kind foreign-currency transaction, the account that receives the settled amount SHALL always be the transaction's own financial account, and settlement SHALL follow the same no-shortfall path as settling a transfer to its destination: the provisional clearing leg is in the transaction's native currency while the settled amount is in the account's currency, so there is no shared-currency figure to compare a shortfall against. There is no alternate destination to choose. A fee category SHALL be rejected for a foreign-currency transaction settlement. A zero settled amount SHALL be rejected for a foreign-currency transaction settlement, the same way a zero destination-delivery settlement is rejected.

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
- **THEN** the settled amount posts against the transaction's own financial account
- **AND** no shortfall comparison is applied
- **AND** no fee or loss entry is posted
- **AND** any other account the user might otherwise name for a transfer is ignored

#### Scenario: A fee category is rejected when settling to the destination
- **WHEN** the user supplies a fee category while settling to the original destination account
- **THEN** the system rejects the settlement, since no shortfall comparison applies to a destination-currency settlement

#### Scenario: A fee category is rejected when settling a foreign-currency transaction
- **WHEN** the user supplies a fee category while settling a pending item of kind foreign-currency transaction
- **THEN** the system rejects the settlement, since no shortfall comparison applies

#### Scenario: A zero settled amount is rejected for destination delivery or a foreign-currency transaction
- **WHEN** the user attempts to settle a pending transfer to its destination, or a pending foreign-currency transaction, with a settled amount of zero
- **THEN** the system rejects the settlement and no entry is posted

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
