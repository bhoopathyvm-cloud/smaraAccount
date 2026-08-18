## Why

A generic starter category set makes a household user re-create common
categories (a phone bill, healthcare) before the app feels tailored to
them. A short post-onboarding wizard — name your main bank account,
optionally add a credit card or cash account — gets someone from "just
onboarded" to "ready to record real life" in under a minute, using
account creation the app already supports.

## What Changes

- Post-onboarding wizard: name the main bank account, optionally add a
  credit card and/or cash account. Each uses the existing
  `createFinancialAccount` flow (asset or liability, a group, a name) —
  the wizard is a guided sequence over what already exists, not a new
  account-creation mechanism.
- Expand the starter category set with a few more common Expense
  categories (Food out, Phone, Health) alongside the existing default
  set, so a new user's category picker isn't immediately empty of common
  cases.

## Capabilities

### New Capabilities

- `first-week-setup`: the wizard flow itself.

### Modified Capabilities

- `core-ledger-single-account`: `Starter Chart of Accounts` gains a few
  more default categories.
- `user-guide`

**Not modified**, checked against the current implementation before
scoping this: `multi-account-ledger` (the wizard calls existing
account-creation with no new validation or posting behavior) and
`accounts-home-overview` (an empty account group is already fully
omitted from Home's sections — `if (members.isEmpty) continue;` in
`watchHomeOverview` — not merely de-emphasized; there is also no
hardcoded generic starter account like "Cash & Bank" seeded today, so
"seed only accounts the user claims" already describes current behavior,
not a gap this change needs to close).

## Impact

- Onboarding flow: one additional guided screen sequence after existing
  onboarding, calling existing account-creation.
- `core-ledger-single-account`'s starter-category seed list.
- Tests and user guide.
