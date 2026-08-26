## MODIFIED Requirements

### Requirement: Category activity checks use the chart seam
The system SHALL validate active income/expense categories through `AccountChartReader` (or the shared chart seam), not private `_requireActiveCategoryOfType` / `_requireActiveExpenseCategory` / `_requireActiveIncomeCategory` copies in posting and investment. Exception type per caller MAY stay distinct via an explicit policy argument.

#### Scenario: Posting and investment share the chart lookup for expense categories
- **WHEN** a brokerage fee or split category must be an active expense
- **THEN** both posting and investment resolve that through the chart seam, not a second Drift `accounts` select copied in each file

#### Scenario: Investment shares the chart lookup for income categories too
- **WHEN** a non-cash buy or dividend requires an active income category
- **THEN** `InvestmentRepository` resolves that through `AccountChartReader.requireActiveCategoryOfType`, not a private hand-rolled `accounts` select
