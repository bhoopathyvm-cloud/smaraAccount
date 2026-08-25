## Context

`investment-holdings` shipped with thorough repository tests and two
isolated `HoldingsView` widget tests. The full-app INTEGRATION suite
(`integration_test/app_test.dart`) and the real-build ACCEPTANCE suite
(`integration_test/acceptance/`) never create an investment account or
open `/holdings/:accountId`. The in-progress `acceptance-test-suite`
change built the real-build harness (`pumpWidget(const
SmaraAccountingApp())`, `resetToFreshDevice`, `tapReliably` /
`enterTextReliably`, `completeOnboardingWithGuidedEntry`) and started
core-ledger and currency groups; it predates investment accounting and
does not list it.

This change adds one independently runnable acceptance file that walks
investment accounting through that existing harness. Product behavior
does not change.

## Goals / Non-Goals

**Goals:**
- Cover every *user-visible* `investment-holdings` requirement with at
  least one real-GUI journey against the real on-disk database.
- Reuse the existing acceptance harness; extract helpers other groups
  (research) can share.
- Keep each `testWidgets` independently runnable from a fresh device
  (onboard itself; no shared in-process identity).

**Non-Goals:**
- Replacing or finishing `acceptance-test-suite` groups 2–12
  (currency remainder, identity, onboarding, import, organization, home
  general, App Lock). Those stay on that change.
- 1:1 GUI duplication of every repository unit test. Cases that need a
  repository fault, HTTP inspection, or a GUI the app does not have
  stay in UNIT:
  - reversing a buy/sell/dividend (no GUI affordance; same exclusion as
    core-ledger acceptance)
  - brokerage fee failing after the buy already posted
  - quote HTTP must not include quantity/cost (already unit-tested)
  - same-day buy/sell recorded-at ordering
  - backdated buy leaving previously posted P/L unchanged
- Live market-data correctness. Acceptance asserts the *labeled
  estimate* path with quotes **disabled** (cost-based, marked not
  current), not a live Yahoo/provider response.
- In-memory INTEGRATION-tier port in `app_test.dart`. This change
  targets the real-build tier that was started.
- Locale packs, household copy, or research tap-to-browser (sibling
  change `acceptance-investment-research`).

## Decisions

### Decision 1 — Real-build acceptance, not a new in-memory suite

The gap that motivated `acceptance-test-suite` is fidelity to
`main.dart`'s widget tree. Investment UI is new surface on that tree
(create-account checkbox, `/holdings/:accountId`, Buy/Sell/Dividend
dialogs, home `onInvestmentAccountTap`). Adding it to the real-build
file layout matches the parent change.

**Alternative considered:** add journeys to `integration_test/app_test.dart`
(faster, in-memory). Rejected as the *primary* deliverable because that
harness still hand-builds `MultiProvider`/`MaterialApp.router` and is
exactly what missed `SnapshotHidingOverlay`. Repository tests already
cover posting math at that speed.

### Decision 2 — One file, several independent scenarios, shared helpers

`integration_test/acceptance/investment_holdings_test.dart` holds every
investment-accounting `testWidgets`. Helpers on
`acceptance_harness.dart`:

- `createInvestmentAccountThroughGui` — Accounts tab → Create → check
  "This account holds investments" → optional opening cash → Investments
  group.
- `openHoldingsFor` — Home (or Accounts) → tap the investment account
  (`onInvestmentAccountTap` pushes `/holdings/:id`).

Each scenario still calls `completeOnboardingWithGuidedEntry` first.
Helpers must not skip cleanup; `resetToFreshDevice` stays in
`setUpAll` / `addTearDown`.

**Alternative considered:** one mega-scenario that does setup, buy,
sell, dividend, archive. Rejected: a failure mid-flow hides later
requirements, and the parent suite already learned that long live-window
runs are flaky.

### Decision 3 — Map product requirements to GUI journeys

| Product requirement | Acceptance journey |
|---|---|
| Cash and inventory wrapper; opening cash | Create investment account with opening cash; holdings shows cash, empty inventory |
| Cash in/out; cash-out cannot exceed cash | Transfer from checking into brokerage; transfer out; oversized out shows an error and cash unchanged |
| Ordinary expense against cash | Record Spent against the investment account; cash down, inventory empty |
| Zero-cash cannot buy until funded | Create with no opening cash; Buy rejected |
| Inventory from lots; kind from fixed list; units held | New instrument (kind Stock) via Buy; inventory lists name and quantity; zero-qty instruments absent |
| Cash-funded buy ± brokerage | Buy 10 @ 100 with brokerage 5 against an expense category; cash and inventory match |
| Non-cash + lock-until + employer match | Cash buy 3 + non-cash 1 with future lock-until; inventory 4; sell of 4 rejected with lock date |
| Sell at a gain; oversell rejected | Sell unlocked units at a higher price; attempt to sell more than held is rejected |
| Dividend without touching inventory | Dividend on a held instrument increases cash, quantity unchanged; after selling all units, a second dividend still posts |
| Trades in account currency | Amounts on holdings/register show the investment group's currency (USD after onboarding) |
| Archive + repeatable closeout; sell/dividend still allowed | Archive with cash → closeout to checking → sell remaining units → closeout offered again. Buy disabled while archived |
| Home portfolio is a labeled market estimate | With quotes disabled, Home shows the investment account's estimate (cash + cost) and tapping it opens holdings |

Archived instrument / rename / never-delete are lower-priority if the
holdings overflow menu is awkward in the live window; include rename if
the overflow is reachable, otherwise document as deferred rather than
faking a repository call.

### Decision 4 — Quotes: disable, do not fetch

Settings already has "Fetch market prices for investments". Scenarios
that care about portfolio math turn that toggle **off** (or leave the
default and assert the labeled-estimate copy) so a network blip cannot
fail the suite. Unrealized gain with a live quote is UNIT + widget, not
acceptance.

### Decision 5 — Dialogs and the 800×600 live window

Buy/Sell/Dividend are `AlertDialog` + `SingleChildScrollView`. The
parent suite's `ensureVisible` / `tapReliably` / `enterTextReliably`
apply. Date pickers (`lock until`, trade date) are OS-ish Flutter
material pickers — use them for lock-until; do not chase backdated-buy
immutability through the picker.

## Risks / Trade-offs

- **[Risk]** Create-account dialog is tall (type, investment checkbox,
  group, opening balance) on the 800×600 macOS window → **Mitigation**:
  `ensureVisible` on the checkbox and Create button; scroll the
  dialog's `SingleChildScrollView` if needed.
- **[Risk]** Buy dialog is taller still (instrument, qty, price, dates,
  brokerage) → **Mitigation**: same; fill fields in order from the top;
  `innerTries: 150` on Record Buy.
- **[Risk]** Transfer to/from investment cash uses the ordinary
  Transfer screen; investment companion inventory account must stay
  hidden from pickers → **Mitigation**: assert the picker never shows
  an inventory companion name; if it does, that is a product bug this
  suite should fail on.
- **[Risk]** Live-window flakiness already documented in
  `acceptance-test-suite` design.md → **Mitigation**: reuse those
  helpers unchanged; 5-minute `testWidgets` timeout; do not invent a
  second wait strategy.
- **[Trade-off]** Not every unit-test branch is a GUI scenario →
  accepted; the product spec remains the source of truth for posting
  math, this change is the source of truth for "a user can do it on
  the real build."

## Migration Plan

No production migration. Tests are additive. Rollback is deleting the
new test file and harness helpers.

## Open Questions

- Whether the holdings overflow offers rename/archive instrument in a
  way `tester` can hit on macOS; settle during implementation (include
  or explicitly skip with a comment pointing at the unit test).
