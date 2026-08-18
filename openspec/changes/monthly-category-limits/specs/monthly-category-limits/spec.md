## Purpose

Month-to-date progress display for a category's optional monthly limit
(the limit field itself is `core-ledger-single-account`'s) — the
category management screen is the always-available home for this;
surfacing on Home's category-totals section, if present, is additive.

## ADDED Requirements

### Requirement: Month-to-Date Progress on the Category Management Screen
For each Expense category with a monthly limit set, the category management screen SHALL show that category's month-to-date spent amount against its limit, with a calm (non-alarming) indication when spent exceeds the limit. Recording a transaction that would exceed a category's limit SHALL NOT be blocked.

#### Scenario: Progress shown for a limited category
- **WHEN** the user opens category management and a category has a monthly limit set
- **THEN** that category's row shows month-to-date spent against the limit

#### Scenario: Over limit is informational only
- **WHEN** spent exceeds the category's limit this month
- **THEN** the UI shows a calm over-limit indication
- **AND** the user can still record further transactions against that category

### Requirement: Home Surfacing Is Additive When Available
If the Home overview shows month-to-date category totals (as `home-hub-capture` may add), the same progress-versus-limit indication SHALL also appear there for limited categories. This capability does not require that section to exist.

#### Scenario: Home shows the same progress when the section exists
- **WHEN** Home's category-totals section is present and a category has a monthly limit
- **THEN** that category's entry shows the same progress indication as the category management screen

#### Scenario: Absence of the Home section does not block this feature
- **WHEN** Home has no category-totals section
- **THEN** monthly limits and their progress remain fully usable from category management alone
