## Purpose

Domain module assembling HomeOverview from chart, balances, pending inputs, and investment portfolio totals — shared portfolio fold for Home and Holdings.

## Requirements

### Requirement: Home overview assembly lives behind one domain module
The system SHALL assemble `HomeOverview` (group sections, per-currency net positions, pending summaries with quarantine exclusion) through a Flutter-free `buildHomeOverview` module. `LedgerRepository` MUST load inputs and call that module rather than inlining assembly.

#### Scenario: Quarantined provisional pending does not inflate assets
- **WHEN** a pending transfer's provisional entry is unverified
- **THEN** it appears in `pendingTransfers` but does not add to `netPositionsByCurrency` assets

#### Scenario: Investment account display uses portfolio totals
- **WHEN** an investment account has cash and holdings with market values
- **THEN** its `AccountBalance.displayBalanceMinor` equals cash + market inventory and `bookValueMinor` equals cash + book inventory

### Requirement: Investment portfolio fold is shared
Holdings UI and Home SHALL compute cash+inventory portfolio/book totals through the same domain helper.

#### Scenario: Holdings ViewModel uses the shared helper
- **WHEN** `HoldingsViewModel.bookMinor` / `portfolioMinor` are read
- **THEN** they equal `investmentPortfolioTotals` for the account's cash and holdings list

### Requirement: Home overview behavior preserved
Extracting the engine SHALL NOT change Home section ordering, net positions, or pending listing.

#### Scenario: Existing overview-related tests still pass
- **WHEN** ledger/home tests that cover overview run after the migration
- **THEN** they pass without weakening assertions
