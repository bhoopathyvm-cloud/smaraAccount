# ledger-chain-verifier

## Purpose

Leaf module for full-chain hash/signature/link verification and tip/cache rebuild, separate from Signing Identity lifecycle (ADR 0002-safe).

## Requirements

### Requirement: Chain verification lives behind a leaf module
The system SHALL verify journal entry hashes, signatures, and chain links through a Flutter-free `LedgerChainVerifier` that depends only on `AppDatabase`, `SigningKeyService`, and `LedgerChainStore`. `IdentityRepository` MUST NOT own the chain walk.

#### Scenario: Verifier does not depend on Identity or Account repositories
- **WHEN** `LedgerChainVerifier` is constructed for DI
- **THEN** its constructor takes only database, signing-key, and chain-store adapters

#### Scenario: Startup and restore call the verifier
- **WHEN** app navigation policy or restore/onboarding completes identity setup
- **THEN** they invoke `LedgerChainVerifier.verifyChain` (not `IdentityRepository.verifyChain`)

### Requirement: Verification behavior preserved
Extracting the verifier SHALL NOT change break detection, tip re-anchor, cache rebuild, or migration genesis-hash reset rules.

#### Scenario: Existing chain-verification repository tests still pass
- **WHEN** ledger repository / migration tests that assert verifyChain outcomes run after the migration
- **THEN** they pass without weakening assertions
