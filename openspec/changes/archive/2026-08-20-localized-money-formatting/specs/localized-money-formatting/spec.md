## Purpose

Format and parse money amounts according to each amount's own currency
code — grouping, decimal separator, and minor-unit digit count — rather
than a single hardcoded "1234.56," and accept locale-appropriate decimal
separators on input.

## ADDED Requirements

### Requirement: Money Is Formatted by Its Own Currency, Not the Device's Locale
Every displayed amount SHALL be formatted using its own currency code's conventions (grouping, decimal separator, minor-unit digit count), sourced from the `intl` package's built-in currency data, not from a custom-maintained table. Formatting SHALL NOT depend on the viewing device's locale — the same account's amounts SHALL render identically regardless of which device or locale is viewing them, since a currency's own convention is what makes the figure intelligible to anyone reading it, not the reader's device settings.

#### Scenario: INR grouping
- **WHEN** displaying INR amounts
- **THEN** grouping and decimal formatting follow INR's own convention, from `intl`'s currency data, regardless of the device's locale

#### Scenario: JPY has no decimal digits
- **WHEN** displaying JPY amounts
- **THEN** no decimal point or minor-unit digits are shown, since JPY's minor unit is zero

#### Scenario: Same amount renders the same on any device
- **WHEN** the same EUR amount is viewed on two devices set to different locales
- **THEN** it renders identically on both, since formatting follows the currency, not the device

### Requirement: Amount Input Accepts the Currency's Decimal Separator
The money amount input field SHALL accept the decimal separator conventional for the transaction's currency (e.g. a comma for currencies where that's standard), not only a period, and SHALL reject the input as invalid rather than silently treating it as zero or empty when it can't be parsed.

#### Scenario: Comma decimal input
- **WHEN** the user enters `12,50` for a currency where comma is the conventional decimal separator
- **THEN** the amount parses as 12.50 in that currency's minor units

#### Scenario: Unparseable input is rejected, not silently emptied
- **WHEN** the user enters text that isn't a valid amount for the field's currency
- **THEN** the field shows an invalid-input state rather than silently behaving as if empty
