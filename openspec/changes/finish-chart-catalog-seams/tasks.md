## 1. Chart category seam

- [ ] 1.1 Add require-active category helpers on `AccountChartReader` with explicit exception policy
- [ ] 1.2 Switch `LedgerPosting` and `InvestmentRepository` off private copies

## 2. Catalog callers

- [ ] 2.1 Holdings ViewModel uses `watchAccountCurrencies` / `currencyFor`
- [ ] 2.2 Correction ViewModel uses the catalog; drop group join used only for currency
- [ ] 2.3 Remove unused Account/Category constructor deps on InvestmentRepository if DI allows

## 3. Verify

- [ ] 3.1 Holdings, correction, investment, and posting unit tests green
- [ ] 3.2 `dart analyze` clean
