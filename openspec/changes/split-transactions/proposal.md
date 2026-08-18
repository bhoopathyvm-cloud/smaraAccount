## Why

Amazon = three categories; one category is a lie.

## What Changes

- Split UI: multiple category lines with amounts summing to total.
- One user save posts balanced multi-category journal (multiple expense postings).
- Available on record and import row (later).
- `core-ledger-single-account`'s single-category assumption ("a category"
  singular, in `Record a Transaction`) is explicitly widened to allow
  either one category or a split across several summing to the total —
  this needs a real delta, not just a bolted-on new capability, since the
  existing requirement's wording otherwise stays contradicted.
- The register's per-row display currently resolves a transaction's
  "other side" via a single lookup (`entry.postings.firstWhere(...)`),
  so a split entry with several category legs would silently show only
  one category on its row while the amount stays correct — this change
  fixes that display, it isn't free from the split posting change alone.

## Capabilities

### New Capabilities

- `split-transactions`

### Modified Capabilities

- `core-ledger-single-account`: `Record a Transaction` explicitly allows
  a split across multiple categories, not only a single one.
- `multi-account-ledger`: register row display shows every category leg
  of a split entry, not just the first one found.
- `user-guide`

## Impact

- Repository: new `recordSplitTransaction` (or widen `recordTransaction`
  to accept multiple category postings).
- `RegisterViewModel`/`RegisterRow`: replace the single "other posting"
  lookup with a list, and `RegisterRowTile` renders a summarized label
  (e.g. "Food, Household +1 more") for multi-leg entries.
- Summary and reversal need **no** change: `watchSummary` already joins
  and sums at the individual posting level (not per-entry), so a split's
  separate category legs already land in their own categories' totals
  correctly; `reverseEntry` already negates every posting on an entry
  generically (`for (final p in originalPostings) ...`), so it already
  reverses a split entry's full set of legs correctly.
- Tests and user guide.
