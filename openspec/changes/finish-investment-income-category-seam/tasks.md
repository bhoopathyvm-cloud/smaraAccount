## 1. Finish the seam

- [ ] 1.1 Replace `InvestmentRepository._requireActiveIncomeCategory`'s hand-rolled check with a call to `_chart.requireActiveCategoryOfType(id, AccountType.income, onInvalid: ...)`, preserving the existing `InvestmentException` message and `AppErrorCode.notActiveIncomeCategory` code
- [ ] 1.2 Delete the now-unused private Drift select

## 2. Verify

- [ ] 2.1 `dart analyze` clean
- [ ] 2.2 Existing investment unit tests covering non-cash buy with a missing/wrong-type/archived income category still pass unmodified
