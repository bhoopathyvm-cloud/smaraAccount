# ledger-chain-store

## Purpose

TBD

## Requirements

### Requirement: Chain tip and verification cache share one module
The system SHALL persist trusted-tip chain state and entry verification-cache upserts through one chain-store module. Both journal posting and identity verification/migration MUST use that module rather than private copies of `_chainState` / `_updateChainState` / `_upsertVerificationCache`.

#### Scenario: Posting updates tip through the store
- **WHEN** `appendSignedEntry` advances the trusted tip or writes a verified cache row
- **THEN** it calls the chain-store interface, not a private Drift helper duplicated in IdentityRepository

#### Scenario: Identity verify and migrate use the same store
- **WHEN** `verifyChain` or key-loss migration updates chain state or verification cache
- **THEN** those writes go through the same chain-store module as posting

### Requirement: No Identity → Ledger cycle
The chain-store module SHALL NOT depend on `LedgerPosting` or `IdentityRepository`. Identity MAY depend on the store; posting MAY depend on the store.

#### Scenario: Construction stays acyclic
- **WHEN** the app constructs IdentityRepository, LedgerPosting, and the chain store
- **THEN** Dart can construct the graph (no Identity → Account → Ledger → Identity cycle)

### Requirement: Integrity outcomes unchanged
Extracting the store SHALL NOT change chain-break detection, re-anchor events, or key-loss migration results.

#### Scenario: Integrity suites still green
- **WHEN** existing verify-chain, re-anchor, and key-loss unit/INTEGRATION tests run after extraction
- **THEN** they pass without changing product assertions
