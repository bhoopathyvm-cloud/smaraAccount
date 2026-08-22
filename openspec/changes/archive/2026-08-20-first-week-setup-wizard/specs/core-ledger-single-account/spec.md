## MODIFIED Requirements

### Requirement: Starter Chart of Accounts
The system SHALL provide a small starter set of Income and Expense categories on first use, so the user is not required to define every category before recording a transaction. The default Expense set SHALL include common household categories beyond the original minimal set, including Food out, Phone, and Health, seeded unconditionally regardless of which accounts the user creates during onboarding or the first-week setup wizard.

#### Scenario: First launch provides starter categories
- **WHEN** the user opens the application for the first time
- **THEN** a small default set of Income and Expense categories exists and is available for use without any setup step

#### Scenario: Household expense categories are included by default
- **WHEN** the user opens the category picker after first launch
- **THEN** Food out, Phone, and Health are available alongside the rest of the default starter set
