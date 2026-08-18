# household-product-positioning

## Purpose

Define the household repositioning program: product promise, non-negotiable
integrity rules, and the mapping from user needs to OpenSpec child changes.

## Requirements

### Requirement: Household Product Promise
The product SHALL be positioned as local household books: users record
spent and received money in plain language, see where money went this
month, and trust that posted history cannot be silently rewritten. The
signed double-entry ledger SHALL remain the implementation mechanism, not
the user-facing vocabulary.

#### Scenario: User-facing flows avoid ledger jargon
- **WHEN** a user completes onboarding or records a transaction after Wave 1
- **THEN** primary actions use household terms (e.g. Spent, Received,
  Fix) rather than debit/credit or journal-entry language

### Requirement: Integrity Non-Negotiables
The repositioning program SHALL NOT introduce silent edit or delete of
posted journal entries, SHALL NOT require a server to hold books or
signing keys, and SHALL NOT auto-fill cross-currency amounts from
reference rates as if they were actual settled amounts.

#### Scenario: Correction remains reversal-based
- **WHEN** a user fixes a posted transaction via the correction wizard
- **THEN** the system posts a reversal and a new entry rather than editing
  the original entry in place

### Requirement: Child Change Coverage
Each of the twenty household usability improvements identified in the
repositioning review SHALL be owned by exactly one OpenSpec child change
listed in the program `proposal.md`, except language localization which
is owned by `i18n-foundation` and follow-on locale packs.

#### Scenario: Feature has a named change
- **WHEN** a contributor implements “search the register”
- **THEN** they implement the `register-search` change rather than an
  unspecified patch
