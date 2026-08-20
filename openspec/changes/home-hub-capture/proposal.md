## Why

Home should be the app: one Add button and this-month insight, not five equal tabs and three mystery FABs.

## What Changes

- Home primary Add action: Spent / Received / Moved money / Import statement.
- This month section: category totals for current calendar month.
- Register's three separate floating action buttons (import, transfer,
  add) are replaced by one Add action opening the same choice, with the
  current account pre-selected — a decided consolidation (see design.md),
  not an optional nice-to-have.
- Update accounts-home-overview spec.

## Capabilities

### New Capabilities

- `home-hub`

### Modified Capabilities

- `accounts-home-overview`
- `user-guide`

## Impact

- As described in What Changes.
- Tests and user guide.
