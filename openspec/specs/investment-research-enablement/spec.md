# investment-research-enablement

## Purpose

Enable research on a held instrument by opening the user's favourite consumer AI website with a strong pre-filled prompt — not an API integration, not a login, not an in-app model call.

## Requirements

### Requirement: Tap Instrument Name Opens Favourite AI Tool
The system SHALL let the user choose a favourite consumer AI web tool from a fixed, predefined list (including ChatGPT, Claude, Gemini, and Meta AI). Tapping an instrument's name in an investment account's inventory SHALL open the device browser at that tool with a research prompt already filled in the tool's query, when the tool supports a query URL. The system SHALL NOT call that tool's API, SHALL NOT store an API key for this capability, and SHALL NOT log into the user's AI account. If the device is offline or the selected tool cannot receive a pre-filled query, the system SHALL copy the same prompt so the user can paste it.

#### Scenario: Tap opens the browser with a pre-filled prompt
- **WHEN** the user taps an instrument name in inventory and a favourite tool is selected that supports a query URL
- **THEN** the system browser opens that tool with the research prompt in the query
- **AND** no API key is used

#### Scenario: Offline or unsupported query falls back to copy
- **WHEN** the user taps an instrument name and the browser cannot be opened or the tool has no query URL
- **THEN** the research prompt is copied to the clipboard
- **AND** no research API request is made

### Requirement: Research Prompt Is Built for Useful Output
The packed prompt SHALL ask for recent material news about the company or issuer, downside risks that could pressure the price, possible upside drivers, and a separation of facts from speculation. It SHALL tell the tool not to give a buy, sell, or hold recommendation and that the reply is not financial advice. The prompt SHALL include the instrument name and, when present, ticker and ISIN, and SHALL NOT include quantity, cost, account name, or balances.

#### Scenario: Prompt contains identifiers and research asks, not the ledger
- **WHEN** the system builds the research prompt for an instrument
- **THEN** the text includes the name and any ticker or ISIN
- **AND** it asks for news, downside risks, and possible upside
- **AND** it forbids a buy/sell recommendation
- **AND** it does not include quantity, cost, or account name

### Requirement: Favourite Tool List Is Fixed
The favourite-tool setting SHALL persist across restarts. The list SHALL be predefined in the application. The system SHALL NOT offer a custom URL or an API key field for this capability. Adding a tool SHALL require a code change.

#### Scenario: Only predefined tools are offered
- **WHEN** the user opens the favourite AI tool setting
- **THEN** only the application's predefined consumer tools are listed
- **AND** there is no API key field and no arbitrary URL field

### Requirement: Research Prompt Language Follows The UI Locale
The packed research prompt's instructional sentences SHALL come from `AppLocalizations` for the active UI locale. The instrument name, ticker, and ISIN SHALL appear as stored (not auto-translated). The prompt SHALL still ask for news, downside, and upside, forbid a buy/sell/hold recommendation, and SHALL NOT include quantity, cost, account name, or balances.

#### Scenario: Tamil UI produces a Tamil prompt template
- **WHEN** the UI locale is Tamil and the system builds the research prompt for an instrument
- **THEN** the instructional sentences are Tamil
- **AND** the instrument name and any ticker or ISIN appear as stored
- **AND** quantity, cost, and account name are still omitted
