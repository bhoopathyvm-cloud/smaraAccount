# active-balance-engine

## Purpose

TBD

## Requirements

### Requirement: One exclusion policy for active balances
The system SHALL decide which journal entries contribute to display balances and home totals (verified, not superseded by migration) in one balance-engine module. Home overview, `displayBalanceMinor`, and register running-balance accumulation MUST use that policy rather than parallel skip loops.

#### Scenario: Home and register agree on exclusions
- **WHEN** the same ledger contains a quarantined entry and a superseded entry
- **THEN** home totals and register running balance exclude those entries via the same engine rule

### Requirement: Posting does not take a facade balance callback
`LedgerPosting` MUST obtain cash/display balances for transfer guards through the balance engine (or a port it owns), not a `Future<int> Function(String)` closed over `LedgerRepository`.

#### Scenario: Posting construction does not close over LedgerRepository.displayBalanceMinor
- **WHEN** `LedgerPosting` is constructed
- **THEN** it does not require a callback whose implementation lives on the ledger facade

### Requirement: Display-sign rules unchanged
The engine SHALL preserve Option A liability sign (`displayBalanceDeltaFor`) and current quarantine visibility (rows still shown; amounts omitted from totals).

#### Scenario: Existing balance tests still pass
- **WHEN** ledger display-balance and register projection tests run after extraction
- **THEN** they pass without changing product assertions
