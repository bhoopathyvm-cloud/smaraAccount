# ledger-data-export

## Purpose

Let the user export a chosen account's transactions for a date range to
a CSV file, so the ledger's data can leave the app without exposing any
signing-key material.

## Requirements

### Requirement: Ledger Data Export
The user SHALL export transactions for a selected account and date range to a CSV file. Export SHALL not include private signing keys.

#### Scenario: Export CSV
- **WHEN** the user exports January for one account
- **THEN** a CSV file contains dated rows with category and amount
