## ADDED Requirements

### Requirement: Dual-Device Harness Covers Claims Sync and Approval
The dual-device acceptance harness SHALL cover Claimant submit → Peer Sync → Approver decide → payment posting, including Claimant-scoped sync (Claimant device does not receive unrelated bank entries) and receipt blob sync. Physical Claimant-phone runs SHALL remain manual.

#### Scenario: Harness approve posts journal entry
- **WHEN** the harness links Owner device A and Claimant device B, B submits a Claim with a receipt, they sync, and A approves the item
- **THEN** A's books contain the expense / owed-to Journal Entry
- **AND** B sees Approved status after sync
- **AND** B does not receive unrelated company bank Journal Entries

#### Scenario: Physical Claimant run is manual
- **WHEN** a developer looks for physical Claimant-phone acceptance
- **THEN** those cases are marked manual and are not required for the default CI acceptance invocation

## MODIFIED Requirements

### Requirement: Acceptance Coverage Spans the App's Shipped Capabilities
The system SHALL organize the acceptance suite into capability groups covering, at minimum: core ledger journeys (recording, reversing, archiving, tamper detection), currency and transfers, identity and backup, onboarding, data import, day-to-day organization features (payees, recurring templates, category rules, category limits, split transactions, corrections, register search), the home/accounts overview, App Lock's PIN path, Linked devices and peer sync (including the two-in-memory-device harness), shared category translations/merges, the books switcher, and expense Claims (submit, receipt attach, Approver decide, payment, Claimant-scoped sync via the dual-device harness). Each group SHALL be independently runnable and share the same real-build harness and cleanup helpers where a real build applies; in-memory dual-device groups MAY use the dual-device harness instead of a single GUI build when that is the only way to exercise sync in CI.

#### Scenario: A capability group runs independently
- **WHEN** a developer runs only one capability group's acceptance test file
- **THEN** it runs to completion using the same real-build harness and cleanup as the full suite, or the dual-device harness for peer-sync and claims groups, without requiring any other group to run first

#### Scenario: New capabilities extend the suite without changing its shape
- **WHEN** a new shipped capability needs acceptance coverage
- **THEN** it is added as a new capability group reusing the existing harness and cleanup helpers, not a bespoke test setup

#### Scenario: Linked devices group is present
- **WHEN** a developer lists acceptance capability groups after Linked devices ships
- **THEN** a group covering Linked devices / peer sync is included and runnable

#### Scenario: Expense claims group is present
- **WHEN** a developer lists acceptance capability groups after expense Claims ship
- **THEN** a group covering Claims / Approver / Claimant sync is included and runnable
