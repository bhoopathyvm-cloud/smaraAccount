## Why

Twenty-four words before the first rupee makes most people bounce. Trust should be earned after one successful record, not demanded at the door.

## What Changes

- Reorder onboarding: currency + name first account → record first Spent/Received in a guided empty state → then Protect this ledger (recovery phrase) before second session or before backup.
- Ledger remains unusable for signing until phrase confirmed; exploratory first entry may live in a staging state or post after protect — design picks one.
- Keystore export stays optional after protect step.
- Update user guide onboarding order.

## Capabilities

### New Capabilities

- `deferred-onboarding`

### Modified Capabilities

- `ledger-integrity-signing`
- `user-guide`

## Impact

- UI, repository or settings as described.
- Tests and user guide.
