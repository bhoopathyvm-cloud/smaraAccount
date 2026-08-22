## Why

Pending transfers read like FX settlement homework.

## What Changes

- Home pending lines: a human sentence (e.g. "You sent X to Y — tap when
  you know what arrived") instead of FX settlement vocabulary.
- The settle screen uses the same plain language, hiding fee/settlement
  jargon from the copy.

## Capabilities

### New Capabilities

(none)

### Modified Capabilities

- `accounts-home-overview`
- `user-guide`

**Not modified**, checked before scoping this: `foreign-currency-settlement`.
This change is copy/wording only — the settlement mechanism, its pending
records, and its requirement text (which describes developer-facing
behavior, not UI copy) are unchanged, matching the principle
`household-language-voice` already established: internal specs keep
their existing vocabulary; only user-facing copy changes.

**Deferred, not in this change:** a gentle reminder after N days
unsettled (local notification) — a genuinely separate feature (needs its
own notification-permission and scheduling design), not a copy change.
If wanted, it's a follow-on change, not silently bundled into this one.

## Impact

- As described in What Changes.
- Tests and user guide.
