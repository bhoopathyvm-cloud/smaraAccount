## ADDED Requirements

### Requirement: Deferred Recovery Phrase Onboarding
The system SHALL allow naming a first account and recording a first spent
or received transaction before the mandatory recovery phrase is shown.
The signing identity and signed ledger chain SHALL NOT be committed until
the user completes recovery phrase acknowledgment. On a subsequent app
open before acknowledgment, the system SHALL require completion of the
Protect this ledger flow before other ledger actions.

#### Scenario: First session before phrase
- **WHEN** the user completes first account setup and one transaction in the guided first session
- **THEN** the recovery phrase has not yet been committed to the database
- **AND** the user is prompted to protect the ledger before continuing regular use

#### Scenario: Return before protect
- **WHEN** the user opens the app again before acknowledging the recovery phrase
- **THEN** the Protect this ledger flow is required before recording additional transactions
