## Why

After import the register is an infinite list with no find.

## What Changes

- Search box on Register: text matches description, category, and amount.
- Optional filters: date range, spent only, received only — combinable
  with the text search, not a separate mode.
- Search and filters apply to the selected account's already-displayed
  rows; nothing about which entries are posted or how they're ordered
  changes.

## Capabilities

### New Capabilities

- `register-search`

### Modified Capabilities

- `user-guide`

**Not modified**, checked before scoping this: `core-ledger-single-account`.
Search and the optional filters are a pure display-layer narrowing of
rows the register already shows in the order it already shows them —
neither the `Transaction Register` requirement nor posting behavior
changes.

## Impact

- As described in What Changes.
- Tests and user guide.
