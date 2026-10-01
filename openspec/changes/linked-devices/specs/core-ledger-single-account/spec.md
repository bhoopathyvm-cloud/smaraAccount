## MODIFIED Requirements

### Requirement: Starter Chart of Accounts
The system SHALL provide a small starter set of Income and Expense categories on first use of a new set of books, so the user is not required to define every category before recording a transaction. The default Expense set SHALL include common household categories beyond the original minimal set, including Food out, Phone, and Health, seeded unconditionally regardless of which accounts the user creates during onboarding or the first-week setup wizard. A device that joins existing books as a Linked Device, or restores a Books Copy, SHALL NOT seed starter categories, and SHALL use the categories in the books it receives.

#### Scenario: First launch provides starter categories
- **WHEN** the user opens the application for the first time
- **THEN** a small default set of Income and Expense categories exists and is available for use without any setup step

#### Scenario: Household expense categories are included by default
- **WHEN** the user opens the category picker after first launch
- **THEN** Food out, Phone, and Health are available alongside the rest of the default starter set

#### Scenario: A joining device seeds nothing
- **WHEN** a new phone joins existing books as a Linked Device
- **THEN** it shows exactly the categories of the shared books, with no second set of starter categories

### Requirement: Category Management
The user SHALL be able to rename a category, add a new category, archive a category that is no longer needed, and merge two categories of the same type. Categories SHALL NOT be permanently deleted. An Expense category SHALL optionally have a monthly spending limit in minor units, which the user can set or clear like any other category field. An Income category SHALL NOT have a monthly limit. Merging SHALL show the two categories as one in every list and total while every entry keeps its original category link.

#### Scenario: Rename a category
- **WHEN** the user renames an existing category
- **THEN** the category's new name is used going forward, and previously posted entries retain the description they were given at posting time

#### Scenario: Add a new category
- **WHEN** the user creates a new Income or Expense category
- **THEN** the category becomes available for selection when recording a transaction

#### Scenario: Archive a category
- **WHEN** the user archives a category
- **THEN** the category is no longer offered when recording a new transaction
- **AND** the category and any entries that reference it remain fully visible in read-only views (register, summary)

#### Scenario: Set a monthly limit
- **WHEN** the user sets a monthly limit of 15000 on an Expense category
- **THEN** the category's limit is stored and used for month-to-date progress display

#### Scenario: Clear a monthly limit
- **WHEN** the user clears a category's monthly limit
- **THEN** no progress or over-limit indication is shown for that category going forward

#### Scenario: Income categories have no limit
- **WHEN** the user views an Income category's settings
- **THEN** no monthly-limit field is offered

#### Scenario: Merge two categories
- **WHEN** the user merges Expense category "Kinder" into "Kids"
- **THEN** one category is listed, its totals include both categories' entries, and every entry still verifies
