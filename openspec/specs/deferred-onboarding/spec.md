# deferred-onboarding

## Purpose

Let a first-time user name their first account and record one
transaction before facing the mandatory recovery-phrase acknowledgment
screen, without changing when or how the signing identity itself is
generated or what makes an entry signed.

## Requirements

### Requirement: Guided First Entry Before Acknowledgment
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
