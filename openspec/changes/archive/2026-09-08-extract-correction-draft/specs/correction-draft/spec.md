## ADDED Requirements

### Requirement: Correction form rules live behind a domain draft
The system SHALL hold Fix-this correction form state (amount, direction, category, financial account, date, description, direction-filtered categories, submit readiness) in a Flutter-free `CorrectionDraft`. `CorrectionViewModel` MUST update catalog snapshots from repositories and orchestrate `fixPostedTransaction` rather than owning those form rules inline.

#### Scenario: Direction change clears category
- **WHEN** the draft direction changes from money-in to money-out (or vice versa)
- **THEN** `categoryId` becomes null so an income category is not kept for an expense direction

#### Scenario: Categories match direction
- **WHEN** direction is money-in
- **THEN** `categories` lists only income-type catalog entries (and expense-type when money-out)

### Requirement: Correction behavior preserved
Extracting the draft SHALL NOT change fix posting outcomes or validation error mapping.

#### Scenario: Existing correction VM/view tests still pass
- **WHEN** correction wizard tests run after the migration
- **THEN** they pass without weakening assertions
