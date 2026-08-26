## Context

Architecture review (round 2, 2026-08-26) marked this "Speculative" — small and low-risk, but a genuine leftover: `finish-chart-catalog-seams` (archived) built `AccountChartReader.requireActiveCategoryOfType` specifically so callers would stop hand-rolling "active category of type X" checks, and migrated `InvestmentRepository`'s expense-category check onto it, but not its income-category sibling three methods away in the same file.

## Goals / Non-Goals

**Goals:**
- Zero hand-rolled category-activity checks left in `InvestmentRepository`.
- No change to `InvestmentException`'s type, `code`, or message for the non-cash-buy income-category-invalid case.

**Non-Goals:**
- Any other chart-catalog-seam follow-through — this change touches exactly one method.
- Changing `requireActiveCategoryOfType`'s signature on `AccountChartReader`.

## Decisions

### Decision 1 — Mirror `_requireActiveExpenseCategory`'s delegation exactly

`_requireActiveExpenseCategory` (`investment_repository.dart:583-584`) is a one-line delegation to `_chart.requireActiveExpenseCategory(id)`, which itself calls `requireActiveCategoryOfType(id, AccountType.expense, onInvalid: ...)`. There's no `requireActiveIncomeCategory` convenience method on `AccountChartReader` (only the expense one exists, since posting only ever needed expense until now) — this change calls `requireActiveCategoryOfType` directly with `AccountType.income` and an inline `onInvalid`, rather than adding a new `AccountChartReader.requireActiveIncomeCategory` convenience method with a single caller. If a second income-category caller appears later, promote it to a named method then (two adapters justify the seam; one doesn't yet).

## Risks / Trade-offs

- **[Risk]** None identified — the change is a literal behavior-preserving delegation, verified by existing unit tests asserting `InvestmentException(code: AppErrorCode.notActiveIncomeCategory)` for a missing/wrong-type/archived income category on non-cash buy.

## Migration Plan

1. Replace `_requireActiveIncomeCategory`'s body with a call to `_chart.requireActiveCategoryOfType(id, AccountType.income, onInvalid: (id) => InvestmentException('$id is not an active Income category.', code: AppErrorCode.notActiveIncomeCategory))`.
2. Run existing investment unit tests unchanged — they should pass without modification since the exception type/code/message is preserved.
3. Rollback = revert; no data migration.

## Open Questions

- None outstanding.
