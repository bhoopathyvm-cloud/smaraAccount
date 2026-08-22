## Why

Investment accounting has shipped (`investment-holdings`, plus related
rules on `multi-account-ledger`, `accounts-home-overview`, and
`foreign-currency-settlement`), but no full-app GUI test drives it. The
repository layer is well covered by
`test/data/repositories/investment_holdings_test.dart`; the holdings
screen has two isolated widget tests. `integration_test/app_test.dart`
and `integration_test/acceptance/` have zero mentions of investment
accounts, Buy/Sell/Dividend, lots, or portfolio value. The in-progress
`acceptance-test-suite` change predates this capability and does not
list it. A real-build journey is the only way to prove create-account →
holdings → cash/trades → home portfolio hang together the way `main()`
assembles them.

## What Changes

- Add a new **acceptance** capability group for investment accounting,
  reusing the existing real-build harness in
  `integration_test/acceptance/support/acceptance_harness.dart` (already
  landed by `acceptance-test-suite`).
- Drive the real GUI through the user-visible `investment-holdings`
  requirements: create an investment account (including opening cash),
  cash in/out, ordinary expense against cash, cash-funded and non-cash
  buys (brokerage, lock-until, employer-match), sell (gain and
  lock-until rejection), dividend (held and after a full sell),
  inventory display, archive + repeatable cash closeout, and home
  portfolio value as a labeled market estimate.
- Extract small shared helpers onto the existing harness (create
  investment account, open holdings) so a follow-on research group can
  reuse them without duplicating onboarding.
- Do **not** change any shipped product behavior, CI, or dependencies.

## Capabilities

### New Capabilities
- `acceptance-investment-holdings`: real-build, GUI-driven acceptance
  coverage of investment-account cash, inventory, buy/sell/dividend,
  archive/closeout, and home portfolio value, using the existing
  acceptance harness.

### Modified Capabilities
(none — this adds a testing group; `investment-holdings` product
requirements stay unchanged)

## Impact

- **Affected code**: new
  `integration_test/acceptance/investment_holdings_test.dart`; small
  helpers on `integration_test/acceptance/support/acceptance_harness.dart`.
  No `lib/` changes unless a finder has no stable label (prefer existing
  l10n strings).
- **Docs**: none required beyond this change's artifacts; the parent
  `acceptance-test-suite` docs tasks still own the Testing Rules
  section.
- **Dependencies**: none — same `integration_test` stack.
- **CI**: no changes. Manual-only, same as the parent acceptance tier.
- **Sibling change**: `acceptance-investment-research` covers tap-to-
  browser research and the favourite-tool setting, which are a separate
  shipped spec.
