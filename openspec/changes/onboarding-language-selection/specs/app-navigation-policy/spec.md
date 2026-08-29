## MODIFIED Requirements

### Requirement: Redirect decisions live behind one policy module
The system SHALL resolve startup and resume navigation (language selection, identity present, recovery-phrase acknowledgment, first guided entry, matching stored key, session chain verify, currency backfill, first-week setup, app lock) through one navigation-policy module. `GoRouter` MUST call that module rather than embedding the gate sequence in `redirect`.

#### Scenario: Policy is testable without the router
- **WHEN** unit tests assert gate order (e.g. no identity → language path, then currency path; lock required → lock path)
- **THEN** those tests call the policy interface directly (no `GoRouter` / `WidgetTester` required)

#### Scenario: Router stays a thin adapter
- **WHEN** the user navigates or the lock controller refreshes
- **THEN** `GoRouter.redirect` forwards location into the policy and returns its path (or none)

#### Scenario: Pre-identity users start at the language screen
- **WHEN** the policy resolves a location and no signing identity exists yet
- **THEN** it routes the user to the language screen unless they are already on the language or currency screen
- **AND** the currency screen remains reachable pre-identity so the user can move from language to currency
