## ADDED Requirements

### Requirement: Two-In-Memory-Device Peer Sync Harness for CI
The system SHALL provide an acceptance (or integration) harness that can run two in-memory "devices" in one process — each with its own books database, Signing Identity, and sync endpoint — so linking and peer-sync scenarios run in CI without real hardware. Real two-physical-device acceptance SHALL remain available and SHALL be flagged as manual.

#### Scenario: CI links and syncs two in-memory devices
- **WHEN** the harness creates devices A and B in one process, links them for the same books, records an entry on A, and syncs
- **THEN** B's books show A's entry with a valid signature
- **AND** the scenario runs without requiring two physical devices

#### Scenario: Real two-device run is manual
- **WHEN** a developer looks for physical two-device acceptance coverage
- **THEN** those cases are clearly marked manual and are not required for the default CI acceptance invocation

## MODIFIED Requirements

### Requirement: Acceptance Coverage Spans the App's Shipped Capabilities
The system SHALL organize the acceptance suite into capability groups covering, at minimum: core ledger journeys (recording, reversing, archiving, tamper detection), currency and transfers, identity and backup, onboarding, data import, day-to-day organization features (payees, recurring templates, category rules, category limits, split transactions, corrections, register search), the home/accounts overview, App Lock's PIN path, Linked devices and peer sync (including the two-in-memory-device harness), shared category translations/merges, and the books switcher. Each group SHALL be independently runnable and share the same real-build harness and cleanup helpers where a real build applies; in-memory dual-device groups MAY use the dual-device harness instead of a single GUI build when that is the only way to exercise sync in CI.

#### Scenario: A capability group runs independently
- **WHEN** a developer runs only one capability group's acceptance test file
- **THEN** it runs to completion using the same real-build harness and cleanup as the full suite, or the dual-device harness for peer-sync groups, without requiring any other group to run first

#### Scenario: New capabilities extend the suite without changing its shape
- **WHEN** a new shipped capability needs acceptance coverage
- **THEN** it is added as a new capability group reusing the existing harness and cleanup helpers, not a bespoke test setup

#### Scenario: Linked devices group is present
- **WHEN** a developer lists acceptance capability groups after this change ships
- **THEN** a group covering Linked devices / peer sync is included and runnable
