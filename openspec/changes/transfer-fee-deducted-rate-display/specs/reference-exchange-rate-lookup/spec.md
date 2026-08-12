## MODIFIED Requirements

### Requirement: Optional Reference Exchange Rate for Cross-Currency Transfers
When recording a transfer between financial accounts in different-currency groups **and** the reference-rate lookup setting is enabled, the system SHALL attempt a best-effort fetch of an indicative reference exchange rate for that currency pair from the user-selected predefined provider, for comparison purposes only. When the fetch succeeds, the system SHALL display that rate. When the setting is disabled, the fetch fails, times out, the pair is unsupported, or the device is offline, the system SHALL omit the reference-rate display and SHALL NOT prevent the user from completing the transfer. This reference rate SHALL NOT be used to populate or validate the transfer's actual destination amount.

When both a source amount and a destination amount are present, the system MAY also display the implied rate derived from those amounts (which does not require a network lookup), still for comparison only — with or without a fetched reference rate beside it. The reference rate and any implied rate SHALL use the same quote convention: units of destination currency per one unit of source currency. When the transfer has a fee marked as deducted from the source amount, the implied rate SHALL be computed against the amount actually converted (the source amount minus the deducted fee), not the full entered source amount, since the fee itself is never converted. When a lookup request is made, it SHALL transmit only the currency codes needed for the quote — not amounts, account identifiers, or other ledger contents.

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
- **WHEN** the user has entered both a source amount and a destination amount for a cross-currency transfer, and no fee is present or the fee is not deducted from the amount
- **THEN** the system may display the implied rate as the destination amount divided by the full source amount, even if the reference-rate setting is disabled or the fetch failed
- **AND** if a reference rate is also available, both are expressed as destination units per one source unit
- **AND** neither rate modifies the amounts the user entered

#### Scenario: Implied rate accounts for a deducted transfer fee
- **WHEN** the user has entered a source amount, a destination amount, and a transfer fee marked as deducted from the source amount, for a cross-currency transfer
- **THEN** the system computes the implied rate as the destination amount divided by the source amount minus the fee, not divided by the full source amount
- **AND** if the fee is greater than or equal to the source amount, the system omits the implied rate rather than showing a negative or infinite value

#### Scenario: Rate lookup does not upload ledger data
- **WHEN** the system fetches a reference exchange rate
- **THEN** the request includes the source and destination currency codes as needed for the quote
- **AND** the request does not include transfer amounts, account ids, account names, or descriptions
