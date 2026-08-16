## MODIFIED Requirements

### Requirement: Overall Net Position
The home overview SHALL show an overall net position for each currency present, each equal to that currency's total asset display balances minus that currency's total liability display balances across all financial accounts in that currency (including archived). For an ordinary (non-investment) financial account, display balance is the ledger display balance. For an investment account, the figure used in group totals and net position SHALL be **portfolio value**: cash plus inventory at last market price (or cached price or cost when a current quote is unavailable), as defined by `investment-holdings`. That portfolio figure SHALL be labeled as a market estimate. The signed book (cash plus inventory at cost) SHALL remain visible on the investment account's own view. The system SHALL NOT convert or combine balances across currencies into a single figure. Amounts excluded under the `multi-account-ledger` capability's quarantine/supersession rules SHALL stay excluded from both book and the cash leg of portfolio value.

#### Scenario: Net position calculation for a single currency
- **WHEN** the user has ordinary asset accounts totaling A, investment accounts whose portfolio values total I, and liability accounts totaling L (amounts owed) in one currency
- **THEN** the home overview shows that currency's net position as A + I − L

#### Scenario: Net position shown separately per currency
- **WHEN** the user has financial accounts spanning more than one currency
- **THEN** the home overview shows one net position figure per currency present
- **AND** no combined or converted total across currencies is shown

#### Scenario: A chain break does not silently distort net position
- **WHEN** a financial account has an entry excluded from its balance due to a detected chain break or a true-key-loss migration
- **THEN** that entry's amount is excluded from that account's contribution to its group total and to its currency's net position, consistent with the account's own displayed book

#### Scenario: Investment account shows portfolio value on home
- **WHEN** the user views an investment account on the home overview
- **THEN** the headline amount is portfolio value (cash plus inventory at last quote, cache, or cost)
- **AND** the amount is labeled as a market estimate
