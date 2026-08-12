## Why

Wise, UBS, and ICICI Bank — the institutions motivating this change — don't export OFX/QFX, the format `ofx-transaction-import` covers. All three do export CSV natively (UBS also offers camt.053, mainly for business accounts). CSV is the one statement format common across them, but every bank's CSV layout differs (column order, headers, date format), so a raw CSV importer needs a mapping step OFX never did — and asking the user to remap columns on every import of the same bank is bad enough to defeat the point. This change adds CSV import plus reusable, named "profiles" that remember a bank's column layout.

## What Changes

- Add a CSV parser that reads user-supplied CSV files into the same normalized transaction shape `ofx-transaction-import` already established (date, amount/direction, description, currency, optional external id) — no separate preview/dedupe/categorize/post pipeline; CSV rows flow through the existing one.
- Add **import profiles**: named, reusable presets that store a file's column-to-field mapping (which column is the date, amount, description, etc.), a date format, an amount sign/format convention (e.g. separate debit/credit columns vs. one signed column), and a decimal separator. A profile is created once per bank/export layout and offered again on the next import from that source.
- Add a mapping step to the import flow: on first import from an unrecognized layout, the user maps columns and optionally saves it as a named profile; on a later import, if a saved profile's column headers match, it's offered as the default and the mapping step can be skipped entirely.
- Reuse `ofx-transaction-import`'s account-matching, duplicate-detection, category-suggestion, and posting logic as-is — CSV rows differ only in *how they're acquired and parsed*, not in how they're reviewed or posted. (Depends on `ofx-transaction-import` landing first or in parallel; see design.md for the sequencing decision.)
- Out of scope for this change: OFX/QFX (already covered), direct bank APIs (Wise/UBS/ICICI connectivity — a separate, much larger change explored but not started), PDF statement parsing.

## Capabilities

### New Capabilities
- `csv-transaction-import`: parsing user-supplied CSV statement files via a column-mapping step, saving/reusing named import profiles, and feeding the resulting rows through the existing OFX-import review/dedupe/categorize/post pipeline.

### Modified Capabilities
(none — this reuses `ofx-transaction-import`'s account-matching, duplicate-detection, category-suggestion, and posting behavior unchanged; no other capability's requirements change)

## Impact

- New CSV parsing code, likely a small dependency (or hand-rolled RFC 4180 parser — plain CSV without embedded newlines/quoting complexity is a small surface).
- New Drift table for saved import profiles (name, source-column mapping, date format, amount convention), additive migration only.
- Generalizes some `ofx-transaction-import` types (e.g. `ParsedOfxTransaction` → a source-agnostic name) so both OFX and CSV rows flow through one review/post pipeline — an implementation-level refactor of already-shipped code, not a requirements change to that capability.
- New UI: column-mapping screen (map file columns to fields, preview first few rows, save-as-profile option), profile picker/management (rename, delete, re-map).
