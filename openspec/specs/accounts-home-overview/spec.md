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
The home overview SHALL show an overall net position equal to total asset display balances minus total liability display balances across all financial accounts (including archived). Balances used for group totals and net position SHALL exclude any entry excluded from a financial account's own balance under the `multi-account-ledger` capability's quarantine/supersession rules.

#### Scenario: Net position calculation
- **WHEN** the user has asset accounts totaling A and liability accounts totaling L (amounts owed)
- **THEN** the home overview shows net position as A − L

#### Scenario: A chain break does not silently distort net position
- **WHEN** a financial account has an entry excluded from its balance due to a detected chain break or a true-key-loss migration
- **THEN** that entry's amount is excluded from that account's contribution to its group total and to the overall net position, consistent with the account's own displayed balance

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
