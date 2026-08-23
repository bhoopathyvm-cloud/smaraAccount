## ADDED Requirements

### Requirement: Research Prompt Language Follows The UI Locale
The packed research prompt's instructional sentences SHALL come from `AppLocalizations` for the active UI locale. The instrument name, ticker, and ISIN SHALL appear as stored (not auto-translated). The prompt SHALL still ask for news, downside, and upside, forbid a buy/sell/hold recommendation, and SHALL NOT include quantity, cost, account name, or balances.

#### Scenario: Tamil UI produces a Tamil prompt template
- **WHEN** the UI locale is Tamil and the system builds the research prompt for an instrument
- **THEN** the instructional sentences are Tamil
- **AND** the instrument name and any ticker or ISIN appear as stored
- **AND** quantity, cost, and account name are still omitted
