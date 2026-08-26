## Why

`AccountChartReader` and `AccountCurrencyCatalog` exist, but callers still bypass them. Posting and `InvestmentRepository` each query `accounts` for “active expense category” (different exception types). Holdings and correction still join `watchAccountGroups` for currency; transfer/record/settle already use the catalog. Catalog leverage is incomplete.

## What Changes

- Add `requireActiveCategoryOfType` / `requireActiveExpenseCategory` (with explicit exception policy per caller) to the chart-reader seam; posting and investment use it.
- Point holdings and correction view models at `watchAccountCurrencies` / `currencyFor`; drop leftover group joins used only for currency.
- Drop unused Account/Category constructor fields on `InvestmentRepository` if DI no longer needs the phantom D1a edges.

## Capabilities

### New Capabilities
- `chart-catalog-seam-followthrough`: remaining callers use the chart reader and currency catalog instead of private account joins.

### Modified Capabilities
- (none — product investment, correction, and FX requirements unchanged)

## Impact

- `lib/data/repositories/account_chart_reader.dart`, `ledger_posting.dart`, `investment_repository.dart`
- `lib/ui/features/holdings/view_models/holdings_view_model.dart`
- `lib/ui/features/correction_wizard/view_models/correction_view_model.dart`
- Holdings/correction/investment unit tests
