## Context

Category CRUD (`Category Management`) lives in
`core-ledger-single-account`, not a separate capability — checked before
scoping this, so the limit itself is a modification there, not a
standalone requirement floating with no owner. Display was originally
scoped to "Home or category row" as an open either/or; resolved below to
avoid an unnecessary hard dependency on `home-hub-capture`.

## Goals / Non-Goals

**Goals:** A simple ceiling per expense category with month-to-date
progress, visible without depending on another in-flight change landing
first.

**Non-Goals:** Full envelope budgeting (rollover, per-account budgets,
multi-month planning) — a calm progress indicator, not a budgeting app.

## Decisions

### 1. The limit is a `core-ledger-single-account` category field, not a new capability's own data model
Modifies `Category Management` directly: an optional
`monthlyLimitMinor` on an Expense category, set/cleared like renaming
one.

### 2. Category management screen is the primary display; Home is additive, not required
Resolves the "Home or category row" either/or: the category management
screen (always reachable, no dependency on other child changes) shows
each limited category's month-to-date spent-vs-limit. If
`home-hub-capture`'s category-totals section exists when this ships, the
same indicator appears there too — described as this change's own
behavior, not a delta on `accounts-home-overview`, so this change doesn't
block on or get blocked by that one's ship order.

### 3. Over-limit is informational, not blocking
Recording a transaction that would push a category over its limit still
posts normally — this is a glance-and-decide tool, not a hard budget
enforcement mechanism (which would need its own, larger design: does it
block the transaction, warn-then-allow, require override, etc. — out of
scope for v1).

## Risks / Trade-offs

- [Risk] Coupling to `home-hub-capture`'s ship order. → Mitigation:
  Decision 2 makes the category-management surfacing the only required
  one; Home surfacing is additive and doesn't gate this change's own
  apply/archive.
- [Risk] Scope creep toward full budgeting. → Mitigation: explicit
  Non-Goal.

## Open Questions

None that block apply.
