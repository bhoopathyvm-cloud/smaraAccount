# chart-catalog-seam-followthrough

## Purpose

TBD

## Requirements

### Requirement: Category activity checks use the chart seam
The system SHALL validate active income/expense categories through `AccountChartReader` (or the shared chart seam), not private `_requireActiveCategoryOfType` / `_requireActiveExpenseCategory` / `_requireActiveIncomeCategory` copies in posting and investment. Exception type per caller MAY stay distinct via an explicit policy argument.

#### Scenario: Posting and investment share the chart lookup for expense categories
- **WHEN** a brokerage fee or split category must be an active expense
- **THEN** both posting and investment resolve that through the chart seam, not a second Drift `accounts` select copied in each file

#### Scenario: Investment shares the chart lookup for income categories too
- **WHEN** a non-cash buy or dividend requires an active income category
- **THEN** `InvestmentRepository` resolves that through `AccountChartReader.requireActiveCategoryOfType`, not a private hand-rolled `accounts` select

### Requirement: Holdings and correction use the currency catalog
Holdings and correction ViewModels SHALL resolve account currency via `watchAccountCurrencies` / `currencyFor`, not by joining `watchAccountGroups` locally.

#### Scenario: No leftover group join for currency
- **WHEN** holdings or correction needs the viewed account's ISO currency
- **THEN** it reads the catalog, matching record/register/transfer/settle

### Requirement: Product outcomes unchanged
Follow-through SHALL NOT change investment buy/sell validation messages' user-visible meaning, correction prefill, or FX guards.

#### Scenario: Existing tests still pass
- **WHEN** holdings, correction, and investment unit/widget tests run after the migration
- **THEN** they pass; only subscriptions/construction may change
