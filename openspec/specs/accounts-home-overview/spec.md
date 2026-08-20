# accounts-home-overview

## Purpose

Provide a home overview surface that lists every financial account (active and archived) with its current balance, organized under account groups with group totals, and an overall net position, serving as the default landing surface once the ledger is ready to use. (Purpose derived from the `multi-account-support` change; refine as the capability evolves.)

## Requirements

### Requirement: Home Overview Lists All Financial Accounts
The system SHALL provide a home overview that lists every financial account (active and archived, with archived clearly indicated) together with each account’s current balance.

#### Scenario: Home shows accounts and balances
- **WHEN** the user opens the home overview
- **THEN** each financial account is shown with its name and current balance
- **AND** accounts are organized under their account groups

### Requirement: Group Totals for Assets and Liabilities
The home overview SHALL show a total for each account group that has at least one financial account. Asset-group totals SHALL sum member asset display balances. Liability-group totals SHALL sum member liability display balances (amount owed). Archived member accounts SHALL still contribute to group totals and net position; they are listed with a clear inactive indication. Groups with no member financial accounts SHALL NOT be presented as primary populated sections.

#### Scenario: Cash equivalents group total
- **WHEN** the user has one or more accounts in Cash & cash equivalents
- **THEN** the home overview shows a group total equal to the sum of those accounts’ current display balances

#### Scenario: Mortgage and loan group total
- **WHEN** the user has one or more accounts in Loans & mortgages
- **THEN** the home overview shows a group total equal to the sum of those liability display balances

#### Scenario: Pension group total
- **WHEN** the user has one or more accounts in Pension & retirement
- **THEN** the home overview shows a group total equal to the sum of those accounts’ current display balances

#### Scenario: Archived account still counts toward totals
- **WHEN** a financial account is archived but has a non-zero display balance
- **THEN** that balance is included in its group total and in the overall net position
- **AND** the account is shown as inactive on the home overview

#### Scenario: Empty group is not emphasized
- **WHEN** an account group has no financial accounts
- **THEN** the home overview does not present that group as a primary populated section (it may be omitted or shown empty without a misleading non-zero total)

### Requirement: Overall Net Position
The home overview SHALL show an overall net position for each currency present, each equal to that currency's total asset display balances minus that currency's total liability display balances across all financial accounts in that currency (including archived). The system SHALL NOT convert or combine balances across currencies into a single figure. Balances used for group totals and net position SHALL exclude any entry excluded from a financial account's own balance under the `multi-account-ledger` capability's quarantine/supersession rules.

#### Scenario: Net position calculation for a single currency
- **WHEN** the user has asset accounts totaling A and liability accounts totaling L (amounts owed) in one currency
- **THEN** the home overview shows that currency's net position as A − L

#### Scenario: Net position shown separately per currency
- **WHEN** the user has financial accounts spanning more than one currency
- **THEN** the home overview shows one net position figure per currency present
- **AND** no combined or converted total across currencies is shown

#### Scenario: A chain break does not silently distort net position
- **WHEN** a financial account has an entry excluded from its balance due to a detected chain break or a true-key-loss migration
- **THEN** that entry's amount is excluded from that account's contribution to its group total and to its currency's net position, consistent with the account's own displayed balance

### Requirement: Group Totals and Balances Display Their Currency
Every group total, financial account balance, and pending-transfer amount shown on the home overview SHALL be labeled with the currency it is denominated in.

#### Scenario: Group total is labeled with its currency
- **WHEN** the user views a group total on the home overview
- **THEN** the total is shown with its currency code or symbol, matching the group's own currency

#### Scenario: Account balance is labeled with its currency
- **WHEN** the user views a financial account's balance on the home overview or in its register
- **THEN** the balance is shown with the currency of the account's group

#### Scenario: Pending-transfer amount is labeled with its currency
- **WHEN** the user views a pending transfer's amount in the Pending Transfers section
- **THEN** the amount is shown with its source currency

### Requirement: Pending Transfers Are Shown on the Home Overview
The home overview SHALL show a Pending Transfers section listing every unsettled pending transfer or foreign-currency transaction as its own line item. A pending item's provisional amount SHALL be included in its source currency's net position while it remains unsettled.

#### Scenario: Pending transfer shown as its own line item
- **WHEN** the user has one or more unsettled pending transfers or foreign-currency transactions
- **THEN** the home overview lists each one individually, showing its source account, intended or possible destination, and provisional amount

#### Scenario: Pending amount counted toward net worth
- **WHEN** a pending transfer's provisional entry has posted but it has not yet been settled
- **THEN** its amount is included in the net position of its source currency

#### Scenario: A quarantined or superseded provisional entry does not distort net worth
- **WHEN** a pending transfer's provisional entry has been marked unverifiable following a detected chain break, or has been superseded by a true-key-loss migration
- **THEN** its amount is excluded from its currency's net position
- **AND** the pending transfer remains visible in the Pending Transfers section for review

#### Scenario: Settled transfer no longer appears as pending
- **WHEN** a pending transfer is settled, whether delivered to its original destination or returned to its source
- **THEN** it no longer appears in the Pending Transfers section

### Requirement: Plain-Language Pending Money
Pending cross-currency items on the home overview SHALL be described in plain language stating what was sent and prompting the user to confirm what arrived, without requiring FX settlement vocabulary.

#### Scenario: Pending line readable
- **WHEN** a pending transfer exists
- **THEN** the home line describes sent amount and accounts in plain language

### Requirement: This Month Category Totals on Home
The home overview SHALL include a section showing total spent per expense
category and total received per income category for the current calendar
month, based on transaction date.

#### Scenario: Month totals visible
- **WHEN** the user opens Home
- **THEN** category totals for the current calendar month are shown
- **AND** transfers and opening balances are excluded from those totals

### Requirement: Navigate From Home to Account Register
From the home overview, the user SHALL be able to open the register for a selected financial account.

#### Scenario: Tap account opens register
- **WHEN** the user selects a financial account on the home overview
- **THEN** the system opens that account’s register

### Requirement: Home Is the Default Landing Surface
After the user can use the ledger (identity confirmed / restored), the application’s primary landing surface SHALL be the home overview.

#### Scenario: Launch lands on home
- **WHEN** the user opens the application in a ready-to-use state
- **THEN** the home overview is the initial screen shown in the main shell
