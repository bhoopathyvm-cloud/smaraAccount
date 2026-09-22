## ADDED Requirements

### Requirement: Look Up Identifiers From The Add-Instrument Form
The Add-instrument form SHALL offer an action, presented after the name field, that opens the user's chosen favourite AI web tool with a pre-filled prompt asking for the instrument's ISIN, primary listing exchange and ticker, trading currency, and market-data symbol — reusing the `investment-research-enablement` tool setting and launch-or-copy behaviour. The system SHALL NOT call that tool's API, store an API key, or log in. The prompt SHALL include only the name the user typed, SHALL NOT include quantity, cost, account name, or balances, and SHALL forbid a buy/sell/hold recommendation. When the browser cannot be opened or the tool has no query URL, the prompt SHALL be copied to the clipboard.

#### Scenario: Look-up opens the favourite tool with an identify prompt
- **WHEN** the user has typed an instrument name and taps the look-up action, and a favourite AI tool with a query URL is selected
- **THEN** the browser opens that tool with a prompt that asks for the ISIN, exchange, ticker, currency, and market-data symbol for that name
- **AND** the prompt contains no quantity, cost, or account information
- **AND** no API key is used

#### Scenario: Offline look-up falls back to copy
- **WHEN** the user taps the look-up action and the browser cannot be opened
- **THEN** the same prompt is copied to the clipboard and instrument creation can continue

### Requirement: ISIN Is Validated Offline At Entry
When the user enters an ISIN on the Add-instrument form, the system SHALL validate it locally without any network request. An entry that is not exactly 12 characters, or contains characters outside `A–Z`/`0–9`, or whose first two characters are not a recognised ISO 3166 country code or a recognised supranational code SHALL be reported as invalid. A 12-character alphanumeric entry whose mod-10 check digit does not verify SHALL be flagged as likely mistyped. A structurally invalid ISIN SHALL block saving the instrument; a check-digit-only failure SHALL warn but SHALL NOT block.

#### Scenario: Malformed ISIN blocks save
- **WHEN** the user enters an ISIN that is not 12 valid characters and tries to save
- **THEN** the form reports the ISIN as invalid and the instrument is not saved

#### Scenario: Bad check digit warns but allows save
- **WHEN** the user enters a 12-character alphanumeric ISIN whose check digit does not verify
- **THEN** the form shows a "looks mistyped" warning
- **AND** the user can still save the instrument

#### Scenario: Valid ISIN passes silently
- **WHEN** the user enters an ISIN with a valid structure and check digit
- **THEN** no ISIN validation message is shown

### Requirement: Currency Mismatch Is Warned At Entry
When the Add-instrument form is used within an investment account and the instrument's likely trading currency can be inferred locally — from the ISIN country, a ticker market suffix, or the default exchange — and that currency differs from the investment account's currency, the system SHALL show an inline warning that automatic market quotes will not match and SHALL indicate the listing that would match (for example, the exchange suffix for the account's currency). The warning SHALL NOT block saving.

#### Scenario: US identifier in a non-USD account warns
- **WHEN** the account currency is CHF and the entered ISIN begins `US`, or the ticker has no market suffix
- **THEN** the form warns that automatic quotes will not match and points at the account-currency listing
- **AND** the instrument can still be saved

#### Scenario: Matching currency does not warn
- **WHEN** the inferred trading currency equals the investment account's currency
- **THEN** no currency-mismatch warning is shown

### Requirement: Default Exchange Setting Backed By A Predefined Registry
The system SHALL maintain a fixed, predefined registry of stock exchanges, each with a display name, market identifier, market-data symbol suffix, trading currency, and an optional national fallback quote endpoint. The system SHALL provide a "Default exchange" setting, chosen from that registry, in the same settings area as the market-quote provider. The setting SHALL persist across restarts, SHALL default on first run from the device region, and SHALL fall back to that default when a stored value is not in the current registry. The system SHALL NOT offer a way to add a custom exchange, endpoint URL, or API key; extending the registry SHALL require a code change.

#### Scenario: Only predefined exchanges are offered
- **WHEN** the user opens the Default-exchange control
- **THEN** only the application's predefined exchanges are listed, with no custom-entry field

#### Scenario: First run picks a regional default
- **WHEN** the app is first run with a device region of Switzerland
- **THEN** the Default exchange is preset to the Swiss exchange, and the user can change it

#### Scenario: Unknown stored exchange falls back
- **WHEN** the persisted Default-exchange value does not match any exchange in the current registry
- **THEN** the system uses the regional/default exchange instead of failing to load Settings

### Requirement: Save Resolves The Identifier And The User Confirms The Listing
When the user saves a new instrument and the device is online, the system SHALL perform one identifier search against the market-data provider — keyed on the ISIN when present, otherwise the ticker, biased toward the default exchange — and SHALL present the candidate listing(s) as name, exchange, and currency for the user to confirm before the instrument is stored. The listing matching the default exchange SHALL be pre-selected; the system SHALL NOT commit a listing without the user's confirmation. On confirmation the instrument SHALL store a canonical market symbol and its exchange alongside the entered ticker and ISIN. When the device is offline or the search returns no candidate, the instrument SHALL be saved with the entered values and resolution SHALL be retried on the next background quote refresh. The search request SHALL transmit only the identifier being resolved.

#### Scenario: Multiple listings require a choice
- **WHEN** the saved identifier resolves to more than one listing (for example a Swiss listing in CHF and a US listing in USD)
- **THEN** the system shows both as name, exchange, and currency, pre-selecting the default-exchange one
- **AND** the instrument is stored only after the user confirms a listing

#### Scenario: Offline save defers resolution
- **WHEN** the user saves a new instrument while offline
- **THEN** the instrument is created with the entered ticker and ISIN
- **AND** the canonical symbol is resolved and stored on a later quote refresh

#### Scenario: Search sends only the identifier
- **WHEN** the Save-time resolution search runs
- **THEN** the request contains only the ISIN or ticker being resolved, and no quantity, cost, or account information
