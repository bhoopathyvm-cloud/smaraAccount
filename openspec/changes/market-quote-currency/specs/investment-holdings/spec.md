## MODIFIED Requirements

### Requirement: Background Market Prices for Portfolio Value and Unrealized Gain/Loss
The system SHALL fetch a latest market price for held instruments that have a ticker or ISIN from a fixed, predefined set of free market-data providers, in the background while the application is in the foreground on home or the holdings view. The request SHALL include the identifiers needed for the quote (ticker and/or ISIN) and SHALL NOT include quantities, costs, account ids, or account names. Portfolio value for an investment account SHALL equal cash plus the sum over inventory of (quantity × last fetched price). Every fetched price SHALL carry the currency it is quoted in: taken from the provider's response when the provider reports one, otherwise the currency implied by the instrument's market symbol (for a symbol-suffix provider such as Stooq). A fetched price whose currency cannot be determined, or cannot be reconciled with the investment account's own currency, SHALL be treated as a missing quote — it SHALL NOT be multiplied into portfolio value, and the holdings view SHALL indicate that the figure is book cost because the quote is in another currency, distinctly from an instrument that has no quote at all. When a quote is missing, stale, in an unreconcilable currency, or the fetch failed, the system SHALL use the last cached usable price if any, otherwise cost, and SHALL indicate that the figure is not a current market price. The holdings view SHALL show, per instrument, unrealized gain or loss equal to that instrument's contribution to portfolio value minus its book cost. Quote fetches SHALL NOT post journal entries. The user SHALL be able to disable quote fetching; when disabled, no market-data request is made.

#### Scenario: Portfolio value uses cash plus quoted inventory
- **WHEN** an investment account has cash 500 and holds 10 units whose last fetched price is 20
- **THEN** the displayed portfolio value is 700
- **AND** no journal entry is posted by the quote

#### Scenario: Unrealized gain/loss is shown per instrument
- **WHEN** an instrument's held quantity has a book cost of 1000 and a current market contribution of 1200
- **THEN** the holdings view shows an unrealized gain of 200 for that instrument

#### Scenario: A quote in the account's currency is applied to a non-USD account
- **WHEN** an investment account's currency is CHF, an instrument is held with quantity 1000 and book cost 1000 CHF, and a market price of 25.00 CHF is fetched for its symbol
- **THEN** that instrument's market contribution is 25000 CHF and its unrealized gain is 24000 CHF
- **AND** the account's Market estimate reflects 25000 CHF for that holding, not its book cost

#### Scenario: A quote in a different currency does not silently become cost
- **WHEN** a fetched price for a held instrument is quoted in USD but the investment account's currency is CHF
- **THEN** that instrument's market contribution is its book cost
- **AND** the holdings row indicates the quote is in another currency, distinct from the label shown when no quote exists at all

#### Scenario: Quote request does not upload the ledger
- **WHEN** the system fetches a market price
- **THEN** the request includes the instrument's ticker and/or ISIN as needed for the quote
- **AND** the request does not include quantity, cost, account id, or account name

#### Scenario: Failed quote does not block the account
- **WHEN** a quote fetch fails, times out, or quote fetching is disabled
- **THEN** the user can still transfer cash, buy, sell, and record a dividend
- **AND** portfolio value uses cached price or cost, labeled as not current

#### Scenario: Quote fetching can be disabled
- **WHEN** the user disables market-price fetching
- **THEN** no market-data network request is made until it is enabled again
