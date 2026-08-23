## ADDED Requirements

### Requirement: Real-Build Coverage of Favourite Tool and Tap-to-Browser Research
The acceptance suite SHALL include an independently runnable group that
launches the real `SmaraAccountingApp` root widget, selects a favourite
consumer AI tool in Settings, records a holding through the real
holdings GUI, and exercises tap-on-instrument-name research. The group
SHALL reuse the existing acceptance harness and cleanup helpers.

#### Scenario: Settings offers only predefined tools
- **WHEN** the acceptance test opens Settings after onboarding
- **THEN** the favourite-research-tool control lists the application's
  predefined consumer tools (including ChatGPT, Claude, Gemini, and
  Meta AI)
- **AND** no API key field and no arbitrary URL field are shown

#### Scenario: Tapping an instrument name starts research without sending the ledger
- **WHEN** the acceptance test has a holding with a name and ticker,
  a favourite tool selected, and taps that instrument name on holdings
- **THEN** the system starts research by launching the tool with a
  query or copying the same prompt
- **AND** the prompt or query includes the instrument name and ticker
- **AND** it asks for news, downside, and possible upside and forbids
  a buy/sell recommendation
- **AND** it does not include quantity, cost, or the investment
  account's name

#### Scenario: The research group runs independently
- **WHEN** a developer runs only
  `integration_test/acceptance/investment_research_test.dart`
- **THEN** it completes using the same real-build harness and cleanup
  as the rest of the acceptance suite, without requiring any other
  acceptance file to run first
