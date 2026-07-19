## MODIFIED Requirements

### Requirement: Overall Net Position
The home overview SHALL show an overall net position for each currency present among included financial accounts, each equal to that currency's total included asset balances minus that currency's total included liability balances. The system SHALL NOT convert or combine balances across currencies into a single figure. Balances used for group totals and net position SHALL exclude any entry excluded from a financial account's own balance under the `multi-account-ledger` capability's quarantine/supersession rules.

#### Scenario: Net position calculation for a single currency
- **WHEN** the user has asset accounts totaling A and liability accounts totaling L (amounts owed) in one currency, all included in net worth
- **THEN** the home overview shows that currency's net position as A − L

#### Scenario: Net position shown separately per currency
- **WHEN** the user has financial accounts spanning more than one currency
- **THEN** the home overview shows one net position figure per currency present
- **AND** no combined or converted total across currencies is shown

#### Scenario: A chain break does not silently distort net position
- **WHEN** a financial account has an entry excluded from its balance due to a detected chain break or a true-key-loss migration
- **THEN** that entry's amount is excluded from that account's contribution to its group total and to its currency's net position, consistent with the account's own displayed balance

## ADDED Requirements

### Requirement: Pending Transfers Are Shown on the Home Overview
The home overview SHALL show a Pending Transfers section listing every unsettled pending transfer or foreign-currency transaction as its own line item. A pending item's provisional amount SHALL be included in its source currency's net position while it remains unsettled.

#### Scenario: Pending transfer shown as its own line item
- **WHEN** the user has one or more unsettled pending transfers or foreign-currency transactions
- **THEN** the home overview lists each one individually, showing its source account, intended or possible destination, and provisional amount

#### Scenario: Pending amount counted toward net worth
- **WHEN** a pending transfer's provisional entry has posted but it has not yet been settled
- **THEN** its amount is included in the net position of its source currency

#### Scenario: Settled transfer no longer appears as pending
- **WHEN** a pending transfer is settled, whether delivered to its original destination or returned to its source
- **THEN** it no longer appears in the Pending Transfers section
