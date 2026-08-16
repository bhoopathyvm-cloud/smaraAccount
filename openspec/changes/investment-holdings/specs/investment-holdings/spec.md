## Purpose

Model an investment account as a wrapper with cash, an instrument inventory, and user-recorded buy/sell (price plus brokerage), and show portfolio value from background free-market quotes — not a broker, not order routing.

## ADDED Requirements

### Requirement: Investment Account Has Cash and Inventory
A user-facing investment account SHALL present two parts in one wrapper: a **cash** balance that increases when money is transferred in from another of the user's financial accounts and decreases when money is transferred out, and an **inventory** of instruments (quantity held and cost). Only an asset account marked as an investment account at creation SHALL have this shape. The investment-account flag SHALL NOT be changeable after creation. A liability SHALL NOT be an investment account.

#### Scenario: Cash in from a user account
- **WHEN** the user transfers a positive amount from a different active financial account into an investment account
- **THEN** the investment account's cash increases by that amount
- **AND** inventory quantities are unchanged

#### Scenario: Cash out to a user account
- **WHEN** the user transfers a positive amount from an investment account's cash to a different active financial account
- **THEN** the investment account's cash decreases by that amount
- **AND** inventory quantities are unchanged

#### Scenario: Cash out cannot exceed cash
- **WHEN** the user attempts to transfer more than the investment account's current cash to another account
- **THEN** the system rejects the transfer and no journal entry is posted

### Requirement: Inventory Is the Holding of Instruments
The inventory SHALL list each instrument the investment account holds with a positive quantity. Quantity is the number of units held. Cost is the average cost of those units in the account's group currency. An instrument with quantity zero SHALL NOT appear as a current holding. Instruments are user-defined (name, kind, optional ticker, optional ISIN), renameable, archivable, and never permanently deleted.

#### Scenario: Inventory shows units held
- **WHEN** the user opens an investment account that holds two instruments
- **THEN** the inventory lists each instrument with its quantity
- **AND** does not list instruments with quantity zero

#### Scenario: Archived instrument stays on existing holdings
- **WHEN** the user archives an instrument that is still held
- **THEN** the holding remains visible in inventory
- **AND** the instrument is not offered for a new buy

### Requirement: Buy Records Price Paid and Brokerage
The user SHALL record a buy by providing an instrument, a positive quantity, a positive price per unit, a transaction date, and a brokerage amount that is zero or positive. The system SHALL decrease cash by (quantity × price) + brokerage, SHALL increase inventory quantity and cost by quantity and (quantity × price), and SHALL post brokerage as a separate same-currency expense against the investment account's cash when brokerage is positive (an active expense category is then required). The system SHALL NOT place a broker order. A buy SHALL be rejected if cash is insufficient for the total debit, if the investment account is archived, or if brokerage is positive and no active expense category is selected.

#### Scenario: Buy with brokerage
- **WHEN** the user buys 10 units at 100.00 with brokerage 5.00, with sufficient cash and an active expense category
- **THEN** cash decreases by 1005.00
- **AND** inventory of that instrument increases by 10 units and 1000.00 cost
- **AND** a separate expense of 5.00 is posted against the chosen category

#### Scenario: Buy without brokerage
- **WHEN** the user buys with brokerage of zero
- **THEN** cash decreases by quantity × price only
- **AND** no fee expense entry is posted

#### Scenario: Buy with insufficient cash is rejected
- **WHEN** the user attempts a buy whose (quantity × price) + brokerage exceeds the investment account's cash
- **THEN** the system rejects the buy and no journal entry is posted
- **AND** inventory is unchanged

### Requirement: Sell Records Price Received and Brokerage
The user SHALL record a sell by providing a held instrument, a positive quantity no greater than the quantity held, a positive price per unit, a transaction date, and a brokerage amount that is zero or positive. The system SHALL increase cash by (quantity × price) − brokerage, SHALL reduce inventory quantity and cost using average cost, SHALL post any realized gain or loss as income or expense, and SHALL post brokerage as a separate same-currency expense when brokerage is positive. A sell SHALL be rejected if quantity exceeds holdings, if (quantity × price) is less than brokerage, if the account is archived, or if a required income/expense category is missing. The system SHALL NOT place a broker order.

#### Scenario: Sell at a gain with brokerage
- **WHEN** the user sells 10 units at 120.00 with brokerage 5.00, average cost 100.00 per unit, with an active income category and an active expense category for brokerage
- **THEN** cash increases by 1195.00
- **AND** inventory decreases by 10 units and 1000.00 cost
- **AND** income of 200.00 is posted
- **AND** expense of 5.00 is posted for brokerage

#### Scenario: Selling more than held is rejected
- **WHEN** the user attempts to sell more units than the inventory quantity
- **THEN** the system rejects the sell and no journal entry is posted

### Requirement: Background Market Prices for Portfolio Value
The system SHALL fetch a latest market price for held instruments that have a ticker or ISIN from a fixed, predefined set of free market-data providers, in the background while the application is in the foreground on home or the holdings view. The request SHALL include the identifiers needed for the quote (ticker and/or ISIN) and SHALL NOT include quantities, costs, account ids, or account names. Portfolio value for an investment account SHALL equal cash plus the sum over inventory of (quantity × last fetched price). When a quote is missing, stale, or the fetch failed, the system SHALL use the last cached price if any, otherwise cost, and SHALL indicate that the figure is not a current market price. Quote fetches SHALL NOT post journal entries. The user SHALL be able to disable quote fetching; when disabled, no market-data request is made.

#### Scenario: Portfolio value uses cash plus quoted inventory
- **WHEN** an investment account has cash 500 and holds 10 units whose last fetched price is 20
- **THEN** the displayed portfolio value is 700
- **AND** no journal entry is posted by the quote

#### Scenario: Quote request does not upload the ledger
- **WHEN** the system fetches a market price
- **THEN** the request includes the instrument's ticker and/or ISIN as needed for the quote
- **AND** the request does not include quantity, cost, account id, or account name

#### Scenario: Failed quote does not block the account
- **WHEN** a quote fetch fails, times out, or quote fetching is disabled
- **THEN** the user can still transfer cash, buy, and sell
- **AND** portfolio value uses cached price or cost, labeled as not current

#### Scenario: Quote fetching can be disabled
- **WHEN** the user disables market-price fetching
- **THEN** no market-data network request is made until it is enabled again
