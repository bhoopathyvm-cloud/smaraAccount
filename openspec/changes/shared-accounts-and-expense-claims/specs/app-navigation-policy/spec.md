## ADDED Requirements

### Requirement: Claimant-Only Role Gates Bookkeeping Routes
When the active Books Set membership is Claimant only, the navigation policy SHALL prevent routes that expose company bank accounts, other people's data, full registers, or Owner membership admin, and SHALL allow Claims, own-claim detail, and Claimant balance surfaces.

#### Scenario: Bank route blocked for Claimant
- **WHEN** the policy resolves a location while the active set role is Claimant only and the target is a company bank register
- **THEN** it does not allow that route

#### Scenario: Claims route allowed for Claimant
- **WHEN** the policy resolves a location while the active set role is Claimant only and the target is the Claims list or a Claim editor for their own Claim
- **THEN** it allows that route
