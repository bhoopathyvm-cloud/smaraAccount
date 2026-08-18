# localized-money-formatting

## Purpose

Capability for localized money formatting.

## Requirements

### Requirement: Locale-Aware Money Display and Input
Amounts SHALL be displayed with grouping decimal separator and minor-unit rules appropriate to the currency code. Amount input SHALL accept the locale-appropriate decimal separator.

#### Scenario: INR grouping
- **WHEN displaying INR amounts**
- **THEN** grouping follows locale conventions for that currency

#### Scenario: Comma decimal input
- **WHEN the user enters 12,50 in a European locale**
- **THEN** the amount parses correctly

