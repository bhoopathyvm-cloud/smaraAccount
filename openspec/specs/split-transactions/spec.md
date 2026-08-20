# split-transactions

## Purpose

The split-entry UI and its running-total feedback, on top of the
underlying multi-category posting mechanics `core-ledger-single-account`
defines. This capability owns how a user *builds* a split; the posting
outcome itself (one entry, one financial-account leg, N category legs)
is `core-ledger-single-account`'s "Record a Transaction" requirement, so
the two don't duplicate the same SHALL from two directions.

## Requirements

### Requirement: Split Entry Form Shows a Running Remainder
The record-transaction screen SHALL let the user add, edit, and remove
category lines within a split, each with its own amount, and SHALL show
the remaining unallocated amount (transaction total minus the sum of
entered lines) as the user edits. Save SHALL be disabled while the
remainder is nonzero.

#### Scenario: Remainder updates as lines are edited
- **WHEN** the user has entered a 100 transaction and allocated 60 to one category line
- **THEN** the form shows 40 remaining
- **AND** save is disabled until the remainder reaches zero

#### Scenario: Removing a line is possible before save
- **WHEN** the user removes a category line from an in-progress split
- **THEN** the remainder recalculates without that line's amount
- **AND** no journal entry has been posted yet

### Requirement: A Non-Split Transaction Is the One-Line Case
Recording an ordinary, single-category transaction SHALL use the same
entry screen as a split, with a single category line implicitly
representing the whole amount — splitting is an in-place expansion from
one line to several, not a separate screen the user must navigate to.

#### Scenario: Single category needs no split UI
- **WHEN** the user records an ordinary transaction with one category
- **THEN** they see the same experience as before this change, with no
  visible "split" concept unless they add a second line
