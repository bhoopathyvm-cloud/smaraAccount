# Proposal: extract-ledger-summary-engine

## Why
`watchSummary` and `watchCategoryTotals` duplicate quarantine / supersession / income-expense magnitude rules. Architecture cycle 12: one Flutter-free engine.

## What Changes
- Add `ledger_summary_engine.dart` with `SummaryPostingLine`, `buildLedgerSummary`, `buildCategoryTotals`.
- Rewire both repository watches onto the engine.

## Impact
- Spec: `ledger-summary-engine`. Behavior unchanged.
