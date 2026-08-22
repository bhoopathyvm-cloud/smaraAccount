# ledger-data-export

## Purpose

Let the user export a chosen account's transactions for a date range to
a CSV file, so the ledger's data can leave the app without exposing any
signing-key material, while preserving enough verification context for a
reader to know whether each exported row still belongs to the app's intact
signed history.

## Background References

- [OpenStax: audit trails in accounting](https://openstax.org/books/principles-financial-accounting/pages/7-1-define-and-describe-the-components-of-an-accounting-information-system)
- [IRS electronic accounting records FAQ](https://www.irs.gov/businesses/small-businesses-self-employed/use-of-electronic-accounting-software-records-frequently-asked-questions-and-answers)
- [NIST: audit trail](https://csrc.nist.gov/glossary/term/audit_trail)

## Requirements

### Requirement: Ledger Data Export
The user SHALL export transactions for a selected account and date range to a CSV file. Export SHALL include ordinary register data and each row's signature-verification status. Export SHALL not include private signing keys, recovery phrases, keystore contents, or other signing-key material.

#### Scenario: Export CSV
- **WHEN** the user exports January for one account
- **THEN** a CSV file contains dated rows with category, amount, currency, and verification status
- **AND** the file contains no signing-key material
