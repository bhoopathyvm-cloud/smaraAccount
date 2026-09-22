## REMOVED Requirements

### Requirement: Guided First Entry Before Acknowledgment
**Reason**: This requirement existed solely to sequence the guided first account/entry before the mandatory recovery-phrase acknowledgment flow. That acknowledgment flow no longer exists (see `ledger-integrity-signing`'s removed `Mandatory Recovery Phrase Acknowledgment` requirement) — there is nothing left to defer into. Naming a first account and recording a first transaction remains ordinary first-time onboarding UX, but is no longer a distinct spec-level behavior contract, since nothing gates a second transaction, navigation, or app resume on its completion.
**Migration**: See `device-migration-bundle`'s `Startup Setup Choice` requirement, whose "New Setup proceeds as ordinary first-time onboarding" scenario covers what remains of the guided first-account/first-entry flow.

On a user's very first launch, the system SHALL guide them to name a
first financial account and record one Spent or Received transaction
before showing the mandatory recovery-phrase acknowledgment flow defined
by `ledger-integrity-signing`. The signing identity SHALL already exist
by this point (generated automatically at first launch, unchanged from
today) and the guided first entry SHALL post as an ordinary, fully
signed journal entry — this requirement changes only the order onboarding
screens appear in, not what a posted entry is.

#### Scenario: First launch guides account naming then one entry
- **WHEN** the user completes first launch
- **THEN** they are guided to name their first financial account and
  record one transaction before the recovery-phrase screen appears

#### Scenario: The guided first entry is an ordinary signed entry
- **WHEN** the guided first entry posts
- **THEN** it is chained and signed exactly like any other journal entry
- **AND** no separate "unsigned" or "staged" storage is used for it

#### Scenario: Acknowledgment is required before anything else
- **WHEN** the guided first entry has posted
- **THEN** the user must complete the recovery-phrase acknowledgment flow
  before recording a second transaction, navigating elsewhere, or
  resuming the app after it was closed or killed
