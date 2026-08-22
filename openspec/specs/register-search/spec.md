# register-search

## Purpose

Text search and optional filters over the currently selected account's
register rows — a display-layer narrowing, not a change to what's posted
or how the register orders it.

## Requirements

### Requirement: Register Search
The register SHALL provide a search box matching description, category, and amount for the selected account's rows. The register SHALL additionally support optional, combinable filters: a date range, and direction (spent only or received only). Search and filters narrow which already-displayed rows are visible; they SHALL NOT change posting order or which entries exist.

#### Scenario: Search by text
- **WHEN** the user types a substring matching a row's description, category, or amount
- **THEN** matching rows remain visible and others are hidden

#### Scenario: Date range filter combines with text search
- **WHEN** the user sets a date range filter alongside a text search
- **THEN** only rows matching both the text and the date range remain visible

#### Scenario: Direction filter shows only spent or only received
- **WHEN** the user selects "spent only" or "received only"
- **THEN** only rows of that direction remain visible, combinable with any active text search or date range

#### Scenario: Clearing search restores the full register
- **WHEN** the user clears the search text and any active filters
- **THEN** the register shows every row for the selected account again, in its normal order
