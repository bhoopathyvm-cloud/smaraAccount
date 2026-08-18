# ledger-data-export

## Purpose

Capability for ledger data export.

## Requirements

### Requirement: Ledger Data Export
The user SHALL export transactions for a selected account and date range to a CSV file. Export SHALL not include private signing keys.

#### Scenario: Export CSV
- **WHEN the user exports January for one account**
- **THEN** a CSV file contains dated rows with category and amount

