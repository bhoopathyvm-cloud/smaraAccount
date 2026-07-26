## Context

`RegisterViewModel._recompute` (`lib/ui/features/register/view_models/register_view_model.dart:85-144`) iterates the entries supplied by `LedgerRepository.watchEntriesForAccount`, which itself is ordered ascending by `transactionDate` (`watchEntries()` at `lib/data/repositories/ledger_repository.dart:613-630`, `OrderingTerm.asc`). The loop accumulates `runningBalance` in that same ascending order and appends one `RegisterRow` per entry in the order visited, so `_rows` ends up oldest-first, and `RegisterView`'s `ListView.builder` renders them in that order unchanged. The account's current balance only appears on the last (bottom) row.

## Goals / Non-Goals

**Goals:**
- The newest entry - and the account's current balance - appears at the top of the register, visible without scrolling.
- No change to the balance math: each row must still show exactly the same running-balance value it shows today, just in a different row order.

**Non-Goals:**
- No change to `watchEntries()`/`watchEntriesForAccount`'s underlying query order - other consumers (e.g. `displayBalanceMinor`, `watchHomeOverview`, `watchSummary`) rely on ascending iteration for their own accumulation and are out of scope.
- No change to how entries within the same transaction date are ordered relative to each other (still `createdAt` then `lineNumber` ascending, per the existing query) beyond the same reversal implied by reversing the whole list.
- No change to any other screen's ordering (Home, Accounts, Summary).

## Decisions

**Decision 1: Reverse for display, not for computation.**
`_recompute` keeps accumulating `runningBalance` from the existing ascending-ordered `entries` list exactly as today - that's the only order in which the running-balance math is correct without rewriting it to work backwards. Only the final assignment changes: `_rows = rows.reversed.toList()` instead of `_rows = rows`. This keeps the change to a single line in `_recompute`, with the rest of the loop, `RegisterRow` construction, and `runningBalanceMinor` values untouched.

**Decision 2: `RegisterView` needs no changes.**
It already renders `viewModel.rows` via a plain `ListView.builder` with no ordering assumption of its own - reversing the ViewModel's exposed list is sufficient to reorder the screen.

## Risks / Trade-offs

- Existing tests assert `rows[0]`/`rows[1]` against the old (ascending) order (`test/ui/features/register/view_models/register_view_model_test.dart`); these need updating to the new order as part of this change, not left as regressions.
- Users accustomed to the current oldest-first order will see the list flip; this matches the user's explicit request and common statement conventions (bank/card statements list newest first), so no further mitigation is needed.
