## MODIFIED Requirements

### Requirement: Category Management
The user SHALL be able to rename a category, add a new category, and archive a category that is no longer needed. Categories SHALL NOT be permanently deleted. An Expense category SHALL optionally have a monthly spending limit in minor units, which the user can set or clear like any other category field. An Income category SHALL NOT have a monthly limit.

#### Scenario: Set a monthly limit
- **WHEN** the user sets a monthly limit of 15000 on an Expense category
- **THEN** the category's limit is stored and used for month-to-date progress display

#### Scenario: Clear a monthly limit
- **WHEN** the user clears a category's monthly limit
- **THEN** no progress or over-limit indication is shown for that category going forward

#### Scenario: Income categories have no limit
- **WHEN** the user views an Income category's settings
- **THEN** no monthly-limit field is offered
