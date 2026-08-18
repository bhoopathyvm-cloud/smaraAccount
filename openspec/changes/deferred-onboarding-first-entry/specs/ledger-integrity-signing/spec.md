## MODIFIED Requirements

### Requirement: Mandatory Recovery Phrase Acknowledgment
The system SHALL derive a human-readable recovery phrase from the signing key and require the user to acknowledge having saved it externally before the ledger can be used further. The system SHALL also offer an optional encrypted keystore file export. The system SHALL NOT depend on any specific external storage provider or on a server-side escrow. On first run only, the user MAY name their first account and record exactly one transaction before the acknowledgment flow is shown; the acknowledgment flow SHALL then block every subsequent action — recording another transaction, navigating elsewhere, or reopening the app after backgrounding or a kill — until completed. This first-run exception does not change how or when the signing identity itself is generated (see `Device Signing Identity`, unchanged by this requirement).

#### Scenario: Onboarding blocks until recovery phrase is acknowledged
- **WHEN** a user completes first-time setup and has not used the first-run exception below
- **THEN** the recovery phrase is displayed with an explanation of the consequences of losing both the device and the phrase
- **AND** the user must confirm possession of the phrase (e.g. re-entering part of it) before recording their first transaction

#### Scenario: Optional keystore file export
- **WHEN** the user chooses to export an encrypted keystore file instead of, or in addition to, the recovery phrase
- **THEN** the system produces a passphrase-protected file the user can store in storage of their own choosing

#### Scenario: First-run exception records one transaction before the phrase
- **WHEN** a user completes first-account setup on their very first launch and has not yet acknowledged the recovery phrase
- **THEN** they may name that account and record exactly one transaction before the acknowledgment flow is shown
- **AND** that transaction posts as a fully signed, permanent journal entry identical in every respect to any later entry — nothing about it is staged or unsigned

#### Scenario: The acknowledgment flow blocks immediately after the first entry
- **WHEN** the user's first-run transaction has posted and the recovery phrase has not yet been acknowledged
- **THEN** the system requires the acknowledgment flow before any further action, including recording a second transaction, navigating away, or reopening the app after it was closed or killed

#### Scenario: Signing identity generation is unaffected
- **WHEN** the application is launched for the very first time
- **THEN** the signing identity is generated automatically before the first-account screen is shown, exactly as `Device Signing Identity` already specifies
- **AND** this happens whether or not the user later uses the first-run acknowledgment exception
