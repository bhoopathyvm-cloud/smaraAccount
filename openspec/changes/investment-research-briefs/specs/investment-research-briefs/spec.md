## Purpose

Optional, privacy-preserving research briefs for a held instrument: a copy-first prompt the user pastes into consumer AI tools they already use, and an opt-in in-app run that uses only the user's own API key and only instrument identifiers.

## ADDED Requirements

### Requirement: Copy-Prompt Research Pack
The system SHALL be able to build a research prompt for an instrument that asks a consumer AI tool for recent news about the company or issuer, material downside risks if the price falls, and possible upside — and that states the reply is not financial advice and not a price quote. The prompt SHALL include the instrument's name and, when present, its ticker and ISIN, and SHALL NOT include holding quantities, costs, account names, balances, or other ledger contents. The user SHALL be able to copy that prompt without any network request from this application.

#### Scenario: Copy prompt includes identifiers only
- **WHEN** the user copies a research prompt for an instrument
- **THEN** the clipboard text includes the instrument name and any ticker or ISIN
- **AND** it does not include quantity, cost, account name, or balance
- **AND** it asks for news, downside risks, and possible upside
- **AND** it states the answer is not financial advice

#### Scenario: Copy prompt works offline
- **WHEN** the device is offline or research API lookup is disabled
- **THEN** the user can still copy the prompt
- **AND** no research network request is made

### Requirement: Optional In-App Brief Uses the User's Own Key
The system SHALL provide a setting to enable in-app research briefs, defaulting to disabled. When enabled, the user SHALL choose a provider from a fixed, predefined set that this application can call with an official API (Anthropic, OpenAI, Google) and SHALL store the API key in OS-native secure storage, never in the SQLite database. The system SHALL NOT offer a custom endpoint URL. Adding a provider SHALL require a code change. A tool that is only a consumer chat (for example Meta AI) SHALL remain copy-prompt-only in this capability.

#### Scenario: In-app run disabled by default
- **WHEN** the user has never enabled in-app research
- **THEN** the application does not make a research API request
- **AND** copy-prompt remains available

#### Scenario: Key stays out of the database
- **WHEN** the user saves an API key for a predefined provider
- **THEN** the key is stored in OS secure storage
- **AND** the key is not written to the SQLite database

#### Scenario: Custom endpoint is not offered
- **WHEN** the user opens the research-provider setting
- **THEN** only the predefined official-API providers are listed
- **AND** there is no field for an arbitrary URL

### Requirement: In-App Request Sends Identifiers Only
When the user explicitly runs an in-app brief, the request SHALL transmit only the packed prompt (instrument name, optional ticker, optional ISIN, and the news/risk/upside instructions). The request SHALL NOT include quantities, costs, account identifiers, account names, descriptions, or other ledger contents. A failed, timed-out, or offline run SHALL NOT prevent the user from using copy-prompt or from recording holdings.

#### Scenario: Run sends no ledger amounts
- **WHEN** the system sends an in-app research request
- **THEN** the payload contains the instrument identifiers and the research instructions
- **AND** it does not contain quantity, cost, account id, or account name

#### Scenario: A failed run does not block holdings
- **WHEN** an in-app research request fails, times out, or the device is offline
- **THEN** the system surfaces that the brief was not retrieved
- **AND** the user can still copy the prompt and can still acquire or dispose holdings

### Requirement: Briefs Are Not Advice and Are Stored Locally
A stored or displayed brief SHALL be labeled as not financial advice, not a recommendation to buy or sell, and not a live price. The system MAY keep the last brief for an instrument on the device for later reading. A brief SHALL NOT be written as a journal entry and SHALL NOT affect balances, marks, or the hash chain.

#### Scenario: Brief does not move the ledger
- **WHEN** a brief is saved or displayed
- **THEN** no journal entry is posted
- **AND** holding quantities, costs, and display marks are unchanged

#### Scenario: Advice disclaimer is visible
- **WHEN** the user views a brief or the copy-prompt confirmation
- **THEN** the UI states that the content is not financial advice
