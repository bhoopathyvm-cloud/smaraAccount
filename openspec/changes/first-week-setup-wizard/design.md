## Context

An earlier draft of this change claimed `multi-account-ledger` and
`accounts-home-overview` as modified capabilities without an actual
delta for either. Checking the real behavior before writing one:

- `watchHomeOverview` already skips any account group with zero member
  accounts (`if (members.isEmpty) continue;`) — an empty system group
  (Pension & retirement, Loans & mortgages, etc. before the user has an
  account in it) is already fully absent from Home, not merely shown
  de-emphasized. The stated problem ("Empty Pension/Loans groups...
  dominate Home") doesn't reproduce against the current implementation.
- There is no hardcoded starter financial account (no "Cash & Bank" row
  gets created automatically) — the only thing seeded automatically
  today is the starter *category* set (`Starter Chart of Accounts`).
  Every financial account, including the very first one, is
  user-created and user-named during existing onboarding.

Both findings mean this change doesn't need to touch
`accounts-home-overview` or add any new account-creation mechanics to
`multi-account-ledger` — it needs a short wizard UI that calls
`createFinancialAccount` a few more times with user-supplied names, and
a slightly larger starter category list.

## Goals / Non-Goals

**Goals:** A one-minute post-onboarding step that leaves a new user with
a correctly named main account, optionally a card and cash account, and
a category list that already covers common household spending.

**Non-Goals:** Any new account-creation validation, group-seeding
behavior, or Home-display behavior beyond what already exists.

## Decisions

### 1. The wizard is a UI sequence over existing account creation
No new repository method. The wizard screen collects a name for the main
account (asset, an existing group) and optionally repeats
`createFinancialAccount` for a credit card (liability, credit group) and
a cash account (asset, cash group).

### 2. Starter categories gain a few more defaults, not a conditional set
`core-ledger-single-account`'s `Starter Chart of Accounts` requirement is
modified to name the expanded default list explicitly (Food out, Phone,
Health added to whatever the existing default set already is), seeded
unconditionally on first use — not gated on wizard answers, since the
category list isn't tied to which accounts the user chose to create.

## Risks / Trade-offs

- [Risk] Duplicating scope with `deferred-onboarding-first-entry` (this
  wizard runs "after deferred onboarding protect step" per that change).
  → Mitigation: this wizard is strictly post-protect; it doesn't touch
  the first-entry or acknowledgment sequencing that change owns.
- [Risk] Scope creep. → Mitigation: child change stays focused on the
  wizard and the category list; no Home-display or account-model change.

## Open Questions

None that block apply.

## Correction, found during implementation

The Context section's claim "There is no hardcoded starter financial
account (no 'Cash & Bank' row gets created automatically)... every
financial account, including the very first one, is user-created and
user-named during existing onboarding" does not hold against the actual
code: `LedgerRepository.confirmFirstIdentity` seeds exactly one asset
account named `financialAccountName` ('Cash & Bank') into
`groupCashEquivalentsId`, unconditionally, as part of committing the
signing identity - before this wizard or any onboarding UI the user
interacts with even runs.

This changes what the wizard's "main account" step actually does:
instead of *creating* a new financial account (Decision 1's original
framing), it **renames** that already-seeded account to whatever the
user types, via the existing `renameFinancialAccount`, prefilled with
the seeded account's current name so leaving it untouched is harmless.
The optional credit-card and cash-account steps are unaffected by this
correction - nothing is seeded in `groupCreditShortTermId`, or a second
account in `groupCashEquivalentsId`, so those two steps still call
`createFinancialAccount` for real, exactly as designed.

## Correction, found during a later review

The Risks section's mitigation for the `deferred-onboarding-first-entry`
overlap ("this wizard is strictly post-protect; it doesn't touch the
first-entry or acknowledgment sequencing that change owns") turned out
to be insufficient: it addressed *sequencing* but not *content*.
`deferred-onboarding-first-entry`'s own implementation later added
`FirstAccountNameView` - a screen that renames the exact same seeded
account, shown strictly *before* the recovery-phrase screen (i.e.
before this wizard, which is gated to run strictly *after* it). Since
this wizard's "main account" step independently prefilled and renamed
that same account again, every first-time user was asked to name the
one seeded account twice in a row, with no functional difference
between the two prompts.

Fixed by removing the main-account naming step from this wizard
entirely - `FirstWeekSetupViewModel`/`FirstWeekSetupView` now only
cover the optional credit-card and cash-account steps, which remain
unaffected (nothing seeds those accounts, so they still need real
creation). Naming the seeded account is owned solely by
`deferred-onboarding-first-entry`'s `FirstAccountNameView` from here
on. `firstWeekBlurb`'s copy was updated to describe only the optional
steps that remain.
