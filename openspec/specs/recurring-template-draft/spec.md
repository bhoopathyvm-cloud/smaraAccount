# recurring-template-draft

## Purpose

Flutter-free recurring-template add/edit form draft, plus shared direction→category filtering used by record/correction/recurring drafts.

## Requirements

### Requirement: Recurring template form rules live behind a domain draft
The system SHALL hold recurring-template add/edit form state (name, direction, account, category, amount, day-of-month, direction-filtered categories, submit readiness) in a Flutter-free `RecurringTemplateDraft`. The management dialog MUST use that draft rather than inlining clear-on-direction and readiness checks.

#### Scenario: Direction change clears category
- **WHEN** draft direction changes
- **THEN** `categoryId` becomes null

#### Scenario: Submit readiness
- **WHEN** name is blank or day-of-month is outside 1–31 or amount is not positive
- **THEN** `canSubmit` is false

### Requirement: Direction category filter is shared
Record, Correction, and Recurring drafts SHALL filter categories through one shared `categoriesForDirection` helper.

#### Scenario: Shared filter
- **WHEN** any of those drafts exposes `categories`
- **THEN** the list equals `categoriesForDirection(allCategories, direction)`
