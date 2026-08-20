
## Purpose

Household-facing vocabulary for SMARA Account: plain language that hides
double-entry jargon while preserving accurate meaning.

## ADDED Requirements

### Requirement: Primary Capture Uses Spent and Received
The system SHALL label the two transaction directions as **Spent** and
**Received** in all primary capture UI (segmented controls, buttons, and
home add hub when shipped). The system SHALL NOT require the user to
understand debit, credit, or journal entry terminology to record money.

#### Scenario: Record screen shows household direction labels
- **WHEN** the user opens the add spent/received flow
- **THEN** the direction control shows Spent and Received
- **AND** does not show Money in or Money out as the primary labels

### Requirement: Household Term Map
The repository SHALL maintain a documented term map from household UI
labels to internal concepts, used by contributors and by
`i18n-foundation` when extracting ARB keys.

#### Scenario: Contributor adds a new button
- **WHEN** a contributor adds user-visible copy for a money action
- **THEN** they consult the term map so labels stay consistent

### Requirement: Integrity Explained in Plain Language
Settings or onboarding SHALL include a short explanation that old
entries are not edited in place; corrections add new lines so history
stays honest.

#### Scenario: User reads why Fix exists
- **WHEN** the user opens Settings (or the Fix flow intro)
- **THEN** they see a plain-language explanation of correction without
  debit/credit vocabulary
