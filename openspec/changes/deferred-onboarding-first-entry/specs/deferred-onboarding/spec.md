# deferred-onboarding

## Purpose

Capability for deferred onboarding first entry.

## Requirements

### Requirement: Deferred Recovery Phrase
The system SHALL allow the user to name a first account and record at least one spent or received transaction before displaying the mandatory recovery phrase flow, provided no signed ledger entries are committed until the user completes recovery phrase acknowledgment.

#### Scenario: First launch records before phrase
- **WHEN the user completes first launch without having acknowledged a recovery phrase**
- **THEN** they may record a first transaction in the guided flow AND the signing identity is not committed until acknowledgment completes

#### Scenario: Second session requires protect
- **WHEN the user returns before acknowledging the recovery phrase**
- **THEN** the app requires the Protect this ledger flow before other ledger actions

