# shared-ui-components

## Purpose

A small set of reusable widgets in `lib/ui/core/` for destructive-action
confirmation, money amount entry, entity picking, and status banners, used
consistently everywhere that shape of UI appears instead of being
reimplemented per screen, plus the stated Golden Rule requiring that
reuse. (Purpose derived from the `shared-ui-components` change; refine as
the capability evolves.)

## Requirements

### Requirement: Single Shared Destructive-Confirmation Dialog
The system SHALL provide one shared function for confirming a destructive action (title, message, and confirm label configurable per call site) that shows a dialog styled per the design system's "Destructive" button pattern (red outlined, red text, transparent background) and resolves to whether the user confirmed. Every screen that confirms a destructive action before proceeding SHALL use this shared function rather than an independently implemented dialog.

#### Scenario: Confirming archives a group
- **WHEN** the user confirms archiving an account group via the shared destructive-confirmation dialog
- **THEN** the dialog resolves to confirmed, and the calling screen proceeds with the archive

#### Scenario: Cancelling declines the action
- **WHEN** the user cancels the shared destructive-confirmation dialog
- **THEN** the dialog resolves to not-confirmed, and the calling screen does not proceed with the action

#### Scenario: Every confirmation dialog uses the shared implementation
- **WHEN** a screen needs to confirm a destructive action before proceeding
- **THEN** it calls the shared confirmation function rather than building its own `AlertDialog`

### Requirement: Single Shared Money Amount Input Field
The system SHALL provide one shared widget for entering a monetary amount, accepting a label, an optional currency suffix, an optional helper text, and a callback that receives the parsed amount already converted to minor units (or null for an empty/unparseable value). Every screen that accepts a monetary amount from the user SHALL use this shared widget rather than an independently implemented text field and parsing callback.

#### Scenario: Entering a valid amount yields minor units
- **WHEN** the user types a valid decimal amount into the shared money amount field
- **THEN** the field's callback receives that amount converted to minor units

#### Scenario: Clearing the field yields null
- **WHEN** the user clears the shared money amount field
- **THEN** the field's callback receives null

#### Scenario: An unparseable value yields null
- **WHEN** the user types a value that cannot be parsed as a decimal amount into the shared money amount field
- **THEN** the field's callback receives null

### Requirement: Single Shared Entity Picker Field
The system SHALL provide one shared, generic widget for picking an entity (such as a financial account or category) by id from a supplied list, rendering each item's display label and reporting the selected id via a callback. Every screen that lets the user pick one entity by id from a list SHALL use this shared widget rather than an independently implemented dropdown.

#### Scenario: Selecting an item reports its id
- **WHEN** the user selects an item from the shared entity picker field
- **THEN** the field's callback receives that item's id

#### Scenario: Caller-side filtering is respected
- **WHEN** a caller supplies a pre-filtered list of items to the shared entity picker field (for example, excluding an already-selected account)
- **THEN** only the supplied items are offered for selection

### Requirement: Single Shared Status Banner
The system SHALL provide one shared widget for displaying a status or error message as a banner, with an optional dismiss action and an optional error styling flag. Every screen that displays such a banner SHALL use this shared widget rather than an independently implemented `MaterialBanner`.

#### Scenario: A dismissible banner shows a Dismiss action
- **WHEN** a screen shows the shared status banner with a dismiss callback supplied
- **THEN** the banner displays a Dismiss action that invokes that callback when tapped

#### Scenario: A non-dismissible banner shows no dismiss action
- **WHEN** a screen shows the shared status banner without a dismiss callback
- **THEN** the banner displays no Dismiss action

### Requirement: UI Component Reuse Is a Stated Architectural Rule
The project's engineering guidelines SHALL state that a new dialog, input field, picker, or banner is only implemented independently after confirming no existing shared widget in `lib/ui/core/` already covers the same shape, matching the discipline already applied to dependencies.

#### Scenario: Guideline exists and is checkable
- **WHEN** a contributor reads `Specs/architecture/smara-tech-guidelines.md`'s Golden Rules
- **THEN** they find a rule directing them to check `lib/ui/core/` for an existing shared widget before writing a new dialog, input field, picker, or banner
