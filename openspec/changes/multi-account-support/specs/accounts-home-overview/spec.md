## ADDED Requirements

### Requirement: Home Overview Lists All Financial Accounts
The system SHALL provide a home overview that lists every financial account (active and archived, with archived clearly indicated) together with each account’s current balance.

#### Scenario: Home shows accounts and balances
- **WHEN** the user opens the home overview
- **THEN** each financial account is shown with its name and current balance
- **AND** accounts are organized under their account groups

### Requirement: Group Totals for Assets and Liabilities
The home overview SHALL show a total for each account group that has at least one financial account included in net-worth calculations. Asset-group totals SHALL sum member asset balances. Liability-group totals SHALL sum member liability balances (amount owed).

#### Scenario: Cash equivalents group total
- **WHEN** the user has one or more accounts in Cash & cash equivalents
- **THEN** the home overview shows a group total equal to the sum of those accounts’ current balances

#### Scenario: Mortgage and loan group total
- **WHEN** the user has one or more accounts in Loans & mortgages
- **THEN** the home overview shows a group total equal to the sum of those liability balances

#### Scenario: Pension group total
- **WHEN** the user has one or more accounts in Pension & retirement
- **THEN** the home overview shows a group total equal to the sum of those accounts’ current balances

#### Scenario: Empty group is not emphasized
- **WHEN** an account group has no financial accounts
- **THEN** the home overview does not present that group as a primary populated section (it may be omitted or shown empty without a misleading non-zero total)

### Requirement: Overall Net Position
The home overview SHALL show an overall net position equal to total included asset balances minus total included liability balances.

#### Scenario: Net position calculation
- **WHEN** the user has asset accounts totaling A and liability accounts totaling L (amounts owed), all included in net worth
- **THEN** the home overview shows net position as A − L

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
