## Why

The archived `chart-catalog-seam-followthrough` capability (`openspec/specs/chart-catalog-seam-followthrough/spec.md`) requires: "The system SHALL validate active income/expense categories through `AccountChartReader` ... not private `_requireActiveCategoryOfType` / `_requireActiveExpenseCategory` copies in posting and investment." Its implementation only migrated the *expense* side: `InvestmentRepository._requireActiveExpenseCategory` (`investment_repository.dart:583-584`) delegates to `_chart.requireActiveExpenseCategory(id)`, but `_requireActiveIncomeCategory` (lines 543-559), three methods away in the same file, still hand-rolls the identical check — `row.type != AccountType.income` and `row.archivedAt != null` — against a private Drift select. The requirement says "income/expense"; only "expense" was finished.

This is the one caller `finish-chart-catalog-seams` (already archived and implemented) missed, not a re-opening of that change's scope.

## What Changes

- `_requireActiveIncomeCategory` delegates to `_chart.requireActiveCategoryOfType(id, AccountType.income, onInvalid: ...)`, mirroring `_requireActiveExpenseCategory`'s existing delegation exactly.
- `onInvalid` constructs `InvestmentException('$id is not an active Income category.', code: AppErrorCode.notActiveIncomeCategory)` — the same exception type and message the hand-rolled version throws today, so no caller-visible behavior changes.
- Delete the private hand-rolled check.

## Capabilities

### Modified Capabilities
- `chart-catalog-seam-followthrough`: "Category activity checks use the chart seam" now holds for income categories too, not only expense.

## Impact

- `lib/data/repositories/investment_repository.dart` (`_requireActiveIncomeCategory`)
- Existing investment unit tests covering non-cash buy validation (`InvestmentException` type/code/message unchanged, so no test assertions should need to change)
- No Drift schema change; no ADR conflict
