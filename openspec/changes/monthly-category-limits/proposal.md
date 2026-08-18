## Why

Summary totals without ceilings don't change behavior.

## What Changes

- Per expense category, an optional monthly spending limit in minor units.
- The category management screen shows progress toward each category's
  limit for the current month, with a calm (not alarming) over-limit
  indication — the always-available home for this, since it doesn't
  depend on any other child change shipping first.
- If `home-hub-capture`'s "this month by category" section has shipped,
  the same progress indication SHALL also appear there, next to that
  category's total — a soft, additive integration, not a hard dependency
  in either direction.
- Not full envelope budgeting.

## Capabilities

### New Capabilities

- `monthly-category-limits`

### Modified Capabilities

- `core-ledger-single-account`: `Category Management` gains an optional
  monthly limit per category.
- `user-guide`

**Not modified** as its own delta: `accounts-home-overview`. The
category-management screen is this feature's primary, always-available
home; showing progress on Home's category-totals section (if present)
is described as an additive behavior of `monthly-category-limits`
itself, not a change to `accounts-home-overview`'s own requirements.

## Impact

- `core-ledger-single-account` schema: optional `monthlyLimitMinor` on
  Expense categories.
- Category management screen: progress display per category.
- Tests and user guide.
