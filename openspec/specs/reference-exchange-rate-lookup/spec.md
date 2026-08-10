# reference-exchange-rate-lookup

## Purpose

Provide an optional, best-effort reference exchange rate lookup for cross-currency transfers, for comparison purposes only, sourced from a user-selected predefined provider, disabled by default and never blocking or auto-filling a transfer. (Purpose derived from the `transfer-entry-and-cost-tracking` change; refine as the capability evolves.)

## Requirements

### Requirement: Optional Reference Exchange Rate for Cross-Currency Transfers
When recording a transfer between financial accounts in different-currency groups **and** the reference-rate lookup setting is enabled, the system SHALL attempt a best-effort fetch of an indicative reference exchange rate for that currency pair from the user-selected predefined provider, for comparison purposes only. When the fetch succeeds, the system SHALL display that rate. When the setting is disabled, the fetch fails, times out, the pair is unsupported, or the device is offline, the system SHALL omit the reference-rate display and SHALL NOT prevent the user from completing the transfer. This reference rate SHALL NOT be used to populate or validate the transfer's actual destination amount.

When both a source amount and a destination amount are present, the system MAY also display the implied rate derived from those amounts (which does not require a network lookup), still for comparison only — with or without a fetched reference rate beside it. The reference rate and any implied rate SHALL use the same quote convention: units of destination currency per one unit of source currency. When a lookup request is made, it SHALL transmit only the currency codes needed for the quote — not amounts, account identifiers, or other ledger contents.

#### Scenario: Reference rate shown when available
- **WHEN** the user is recording a cross-currency transfer, the reference-rate setting is enabled, and a reference rate for that currency pair is successfully fetched
- **THEN** the system displays that rate next to the destination-amount field, labeled as a reference/market rate
- **AND** the destination-amount field remains independently editable by the user

#### Scenario: Reference rate unavailable does not block the transfer
- **WHEN** the reference-rate lookup fails, times out, or the device is offline
- **THEN** the system omits the reference-rate display
- **AND** the user can still complete the transfer exactly as if the lookup had never been attempted

#### Scenario: Reference rate never auto-fills the destination amount
- **WHEN** a reference rate is displayed for a cross-currency transfer
- **THEN** the destination-amount field is not automatically populated or overwritten from that rate
- **AND** the amount actually posted comes only from what the user enters (or is later settled)

#### Scenario: Implied rate may be shown without requiring a network lookup
- **WHEN** the user has entered both a source amount and a destination amount for a cross-currency transfer
- **THEN** the system may display the implied rate from those amounts even if the reference-rate setting is disabled or the fetch failed
- **AND** if a reference rate is also available, both are expressed as destination units per one source unit
- **AND** neither rate modifies the amounts the user entered

#### Scenario: Rate lookup does not upload ledger data
- **WHEN** the system fetches a reference exchange rate
- **THEN** the request includes the source and destination currency codes as needed for the quote
- **AND** the request does not include transfer amounts, account ids, account names, or descriptions

### Requirement: Reference Rate Lookup Can Be Disabled
The system SHALL provide a setting the user can use to enable or disable the reference exchange rate lookup, defaulting to disabled. The preference SHALL persist across app restarts. When disabled, the system SHALL NOT attempt any reference-rate network request, regardless of whether the current transfer is cross-currency.

#### Scenario: Lookup disabled by default on first use
- **WHEN** the user has never changed the reference-rate setting
- **THEN** the reference exchange rate lookup is disabled
- **AND** no reference-rate network request is made for any cross-currency transfer

#### Scenario: Disabling the setting stops all lookups
- **WHEN** the user disables the reference exchange rate setting
- **THEN** no reference-rate network request is made for any subsequent cross-currency transfer, until the user re-enables it
- **AND** the reference-rate display is simply omitted, exactly as if the lookup had failed

#### Scenario: Enabling the setting allows lookups again
- **WHEN** the user enables the reference exchange rate setting after it was disabled
- **THEN** subsequent cross-currency transfers may attempt the reference-rate lookup again, subject to the existing best-effort/offline-safe behavior

### Requirement: Predefined Exchange Rate Provider Selection
The system SHALL let the user choose which reference-rate provider to use from a fixed, predefined set of providers, presented as a selectable list (e.g. a dropdown) in the same settings area as the enable/disable control. The system SHALL NOT offer a way for the user to add, edit, or supply a custom provider (such as a free-text endpoint URL or an API key field). Adding a new provider to the predefined set SHALL require a code change to the application, not a user-facing configuration option.

#### Scenario: Provider list is fixed and predefined
- **WHEN** the user opens the provider selection control
- **THEN** only the application's predefined set of providers is offered
- **AND** there is no option to enter a custom provider URL or otherwise supply an arbitrary endpoint

#### Scenario: Selected provider is used for subsequent lookups
- **WHEN** the user selects a different provider from the predefined set
- **THEN** subsequent reference-rate lookups use the newly selected provider
- **AND** the preference persists across app restarts

#### Scenario: Unrecognized stored provider falls back to the default
- **WHEN** the persisted provider preference does not match any provider currently in the predefined set (for example, after an app update that renamed or removed one)
- **THEN** the system uses the default provider instead of failing to load Settings or the Transfer screen
