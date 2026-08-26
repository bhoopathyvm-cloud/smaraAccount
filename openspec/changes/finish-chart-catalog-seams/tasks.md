## 1. Chart category seam

- [x] 1.1 Add require-active category helpers on `AccountChartReader` with explicit exception policy
- [x] 1.2 Switch `LedgerPosting` and `InvestmentRepository` off private copies

## 2. Catalog callers

- [x] 2.1 Holdings ViewModel uses `watchAccountCurrencies` / `currencyFor`
- [x] 2.2 Correction ViewModel uses the catalog; drop group join used only for currency
- [x] 2.3 Remove unused Account/Category constructor deps on InvestmentRepository if DI allows

## 3. Verify

- [x] 3.1 Holdings, correction, investment, and posting unit tests green
- [x] 3.2 `dart analyze` clean
