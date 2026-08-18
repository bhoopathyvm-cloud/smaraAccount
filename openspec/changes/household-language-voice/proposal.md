## Why

The app speaks like a general ledger (“money in/out”, “net position”,
“financial account”, “reverse”) while the repositioned product is
**household books**. Users who do not know double-entry should never need
to learn it to record lunch. English household voice must land before or
with `i18n-foundation` so ARB keys encode the right semantics.

## What Changes

- Replace primary UI labels with household terms: **Spent / Received**
  (not Money in/out), **account / wallet** (not financial account in
  chrome), **what you have minus what you owe** (not net position in
  hero text), **Fix** (not reverse), **Hide from new entries** (not
  archive in user confirmations where possible).
- Update seeded display defaults where the user has not renamed: e.g.
  starter account prompt “Name your main bank account” instead of
  leaving only `Cash & Bank`.
- Add a short in-app glossary link or Settings note: “Why we don’t edit
  old rows” (one paragraph, not ledger lecture).
- Update `docs/user-guide.md` and README lead positioning to household
  books.
- Define a **household term map** document (or ARB comment convention)
  for `i18n-foundation` to follow.

## Capabilities

### New Capabilities

- `household-language`: user-facing vocabulary rules and term map for
  primary navigation, capture flows, and error tone.

### Modified Capabilities

- `user-guide`: household voice in guide prose.

**Not modified**, checked before scoping this: `shared-ui-components`.
This change updates the *string arguments* passed into existing shared
widgets (e.g. `confirmDestructiveAction`'s `confirmLabel: 'Archive'`
becoming `'Hide'` at call sites), not the widgets' own behavior or
requirements — `shared-ui-components`'s own spec is about which shared
widget to use, not what label text call sites pass it.

## Impact

- `lib/ui/**` string changes (pre-ARB hardcoded, or first ARB keys if
  i18n lands in parallel).
- `docs/user-guide.md`, `README.md`.
- No ledger schema change.
