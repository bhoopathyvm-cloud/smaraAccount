## ADDED Requirements

### Requirement: Instrument Identity May Include A Resolved Market Symbol
An instrument MAY additionally carry a resolved canonical market symbol and its exchange, established when the user confirms a listing during instrument creation (see `instrument-identifier-assist`). These fields are optional and additive; an instrument without them behaves exactly as before. Background market-price fetching SHALL use the resolved canonical symbol in preference to the raw ticker when it is present, and MAY fall back to the resolved exchange's national quote endpoint when the primary provider returns no quote. The resolved symbol and exchange SHALL NOT change how lots, cost, quantity, sellable quantity, or buy/sell/dividend posting behave.

#### Scenario: Quote fetch uses the resolved symbol
- **WHEN** an instrument has a resolved canonical symbol and a background quote refresh runs
- **THEN** the market-data request uses the resolved symbol rather than the raw ticker

#### Scenario: Instrument without a resolved symbol is unchanged
- **WHEN** an instrument has only a name, kind, and optional ticker/ISIN
- **THEN** market-price fetching and all holdings computations behave as they did before this capability
