## ADDED Requirements

### Requirement: Claimant-Only Surface for Company Books Set
When the active Books Set is company books and the person's membership role on that set is Claimant only, the books switcher SHALL still list the set, and after switching the UI SHALL present the Claimant surface (own claims, balance, allowed categories) rather than full bookkeeping Home and registers.

#### Scenario: Switch to company books as Claimant
- **WHEN** a user who has household books and company Claimant membership switches the active set to the company books
- **THEN** they see the Claimant claims surface for that set
- **AND** they do not see the full company accounts overview

#### Scenario: Household set remains full books
- **WHEN** the same user switches back to their household Books Set where they are Owner or Member
- **THEN** Home and Register show ordinary household bookkeeping for that set
