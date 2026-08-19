## Context

See proposal.md.

## Goals / Non-Goals

**Goals:** Habit without autopilot.

**Non-Goals:** See proposal.

## Decisions

`recurring_templates` table; `recordTransaction` on confirm.

## Risks / Trade-offs

- [Risk] Interaction with other child changes. → See household-product-repositioning waves.

## Open Questions

None for v1.

## Filled in during implementation

This design.md predated any concrete schema/UI decisions - the following
resolves what the one-line Decisions bullet left open, since "recurring
templates table" alone doesn't specify identity, cadence semantics, or
where CRUD/due-surfacing live.

### Schema
`recurring_templates(id, name, direction, financial_account_id,
category_id, amount_minor, day_of_month, last_recorded_year_month,
created_at)`. No FK/link column on `journal_entries` - recording a due
template calls the exact same `recordTransaction` a manual entry would,
so a recorded instance is an ordinary transaction with no special
relationship back to its template (consistent with `payees-and-spending-memory`'s
same choice for its own table).

### "Due" semantics
`day_of_month` is 1-31; a shorter month clamps to its own last day
(`effectiveDayOfMonth`), so a day-31 template is due on Feb 28/29, not
silently skipped. A template stays "due" (not just on the exact day, but
every day after until acted on) until recorded once in the current
calendar month, tracked via `last_recorded_year_month` - this covers the
realistic case of not opening the app on the exact due date without
needing a scheduled reminder (out of scope per proposal.md's own
"Deferred, not in this change").

### CRUD UI placement
A minimal add/edit/delete screen (`RecurringTemplateManagementView`),
reachable via a "Manage recurring templates" button in Settings -
matching `payees-and-spending-memory`'s established placement for a
similar secondary-management screen, rather than inventing a new
navigation surface.

### Recording a due item
One tap on Home's "DUE TODAY" row calls `recordDueTemplate` directly, no
confirmation dialog - the tap itself is the confirmation the proposal
describes ("does not auto-post without tap"), and the template's
own fields (account/category/amount) are already fixed at creation time,
so there's nothing left to confirm inline.
