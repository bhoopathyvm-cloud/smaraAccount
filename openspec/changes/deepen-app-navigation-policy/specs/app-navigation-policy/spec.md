## ADDED Requirements

### Requirement: Redirect decisions live behind one policy module
The system SHALL resolve startup and resume navigation (identity present, recovery-phrase acknowledgment, first guided entry, matching stored key, session chain verify, currency backfill, first-week setup, app lock) through one navigation-policy module. `GoRouter` MUST call that module rather than embedding the gate sequence in `redirect`.

#### Scenario: Policy is testable without the router
- **WHEN** unit tests assert gate order (e.g. no identity → currency path; lock required → lock path)
- **THEN** those tests call the policy interface directly (no `GoRouter` / `WidgetTester` required)

#### Scenario: Router stays a thin adapter
- **WHEN** the user navigates or the lock controller refreshes
- **THEN** `GoRouter.redirect` forwards location into the policy and returns its path (or none)

### Requirement: Existing route outcomes preserved
Extracting the policy SHALL NOT change which screen appears for onboarding, restore, backfill, first-week setup, or lock.

#### Scenario: Onboarding and lock flows still match
- **WHEN** existing router/onboarding/lock tests and related acceptance run after extraction
- **THEN** they pass without weakening assertions
