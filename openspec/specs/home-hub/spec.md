# home-hub

## Purpose

Make Home the app's primary capture surface: a single Add action for
Spent/Received/Moved money/Import, plus this month's category totals,
replacing the register's three separate floating action buttons.

## Requirements

### Requirement: Home Capture Hub
The home overview SHALL provide a primary Add action that opens spent received moved money or import paths. The home overview SHALL show this calendar month's spent totals grouped by expense category and received totals by income category.

#### Scenario: Add from home
- **WHEN** the user taps Add on Home
- **THEN** they can choose Spent Received Moved money or Import

#### Scenario: This month categories
- **WHEN** the user views Home
- **THEN** they see category totals for the current calendar month

### Requirement: Register's Capture Actions Consolidate Into One
The register screen's three separate floating action buttons (import, transfer, add) SHALL be replaced by a single Add action that opens the same Spent/Received/Moved money/Import choice Home's Add action opens, with the currently-viewed account pre-selected. This is a decided consolidation, not optional — Home becomes the primary capture surface and the register no longer duplicates it with three separate icon-only buttons.

#### Scenario: Register has one Add action, not three
- **WHEN** the user opens a financial account's register after this change
- **THEN** they see a single Add action instead of three separate floating action buttons
- **AND** choosing an action opens the same Spent/Received/Moved money/Import choice Home offers, with this account pre-selected

#### Scenario: The consolidated action still respects archived-account rules
- **WHEN** the currently-viewed account is archived
- **THEN** the consolidated Add action is disabled, exactly as the three separate FABs already were
- **AND** the existing closeout ("Transfer remaining balance") affordance for an archived account with a positive balance is unaffected by this consolidation
