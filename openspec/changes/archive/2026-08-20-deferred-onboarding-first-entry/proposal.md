## Why

Twenty-four words before the first rupee makes most people bounce. Trust
should be earned after one successful record, not demanded at the door.

## What Changes

- Reorder onboarding: currency + name first account → record one guided
  first Spent/Received → **then** the mandatory Protect this ledger
  (recovery phrase) flow, shown immediately after that first entry posts,
  before the user can do anything else (record a second transaction,
  leave the screen, or close the app).
- The signing identity is generated exactly as it is today — silently,
  automatically, before any account or entry exists (`Device Signing
  Identity` is unchanged). What moves is only the **acknowledgment
  screen**: it still blocks all further ledger use, it's just shown after
  the first entry instead of before it. There is no new "unsigned" or
  "staged" entry concept — the first entry is a real, fully signed,
  permanent journal entry from the moment it posts, identical in every
  way to entry two through N. This keeps the change to a UI-sequencing
  question, not a change to what "signed" means.
- Keystore export stays optional after protect step, as today.
- Update user guide onboarding order.

## Capabilities

### New Capabilities

- `deferred-onboarding`: the resequenced first-run flow (account name →
  first entry → mandatory protect, gated immediately, not deferred to a
  second session).

### Modified Capabilities

- `ledger-integrity-signing`: the `Mandatory Recovery Phrase
  Acknowledgment` requirement's blocking point moves from "before
  recording the first transaction" to "before any action after the first
  transaction." `Device Signing Identity` is explicitly unaffected —
  called out so no implementer reads this change as touching when or how
  the key itself is generated.
- `user-guide`.

## Impact

- `lib/ui/app_router.dart`: route order and the redirect guard that
  currently sends every unacknowledged-identity session straight to
  `/onboarding/recovery-phrase` before `/home`.
- Onboarding view/view-model for the first-account + first-entry guided
  screens.
- Tests and user guide.
