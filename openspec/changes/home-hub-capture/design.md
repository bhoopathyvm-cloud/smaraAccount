## Context

An earlier draft left "consolidate register FABs to a single Add" at
three different confidence levels across its own artifacts: committed in
proposal.md's What Changes, hedged as "(optional single menu)" in
tasks.md, and entirely absent from spec.md. Resolved as a decided
requirement (see spec.md) rather than left ambiguous for an implementer
to guess at.

Checked the current register FABs before writing the resolution: all
three (import, transfer, add) already disable uniformly
(`onPressed: viewModel.isSelectedAccountArchived ? null : ...`) when the
viewed account is archived, and the existing "Transfer remaining
balance" closeout affordance is a separate, non-FAB control. Consolidating
the three FABs into one doesn't need to reinvent that archived-account
handling — the single consolidated action just inherits the same
disabled condition, and closeout is untouched.

## Goals / Non-Goals

**Goals:** Glance + capture from Home; register stops duplicating
capture entry points once Home owns them.

**Non-Goals:** Removing the register screen itself, or changing what
closeout does for an archived account with a balance — those are
unrelated to consolidating capture entry points.

## Decisions

### 1. `HomeViewModel` reuses the Summary query, scoped to the current month
No new aggregation logic — the same income/expense-by-category query
Summary already runs, called with this calendar month's date range and
no account filter (or optionally the same filter Summary supports).

### 2. Register's three FABs become one, decided (not optional)
Resolves the ambiguity described in Context. The single Add action opens
the same Spent/Received/Moved money/Import choice as Home's Add, with
the currently-viewed account pre-selected — not a new, register-specific
flow. This keeps Home and Register consistent rather than adding a
second capture-entry design to maintain.

## Risks / Trade-offs

- [Risk] A future investment-account-aware change (`investment-holdings`,
  not yet implemented) may need per-action archived-state nuance inside
  a single consolidated Add menu (e.g. Sell remains available on an
  archived investment account while Buy doesn't, per that change's own
  design) that a single on/off FAB doesn't obviously support. →
  Mitigation: not this change's problem to solve now — noted so
  `investment-holdings`, if and when it lands, revisits this menu's
  internal structure rather than being surprised by it. Today's register
  has no such asymmetry (all three current FABs disable uniformly), so
  the simple decided design here is correct for what exists now.
- [Risk] Interaction with other child changes. → See
  household-product-repositioning waves.

## Open Questions

None for v1.

## Correction, found during implementation

Decision 1's premise ("no new aggregation logic — reuses Summary's
existing by-category query") did not hold once the actual code was
read: `LedgerRepository.watchSummary`/`LedgerSummary` only ever
collapse a date range into two totals (income, expense) — there was no
existing by-category breakdown to call into. Summary itself doesn't
break down by category either.

Resolved by adding genuinely new repository surface,
`LedgerRepository.watchCategoryTotals({required start, required end})`
returning `List<CategoryTotal>` (`domain/models/summary.dart`), which
mirrors `watchSummary`'s own join/account-exclusion logic but groups by
category instead of collapsing to a single total. `HomeViewModel`
subscribes to it scoped to the current calendar month and exposes
`thisMonthExpenseTotals`/`thisMonthIncomeTotals` (filtered by
`isIncome`, sorted descending by `totalMinor`). Everything else in
Decision 1 (no account filter, current month only) held as designed.
