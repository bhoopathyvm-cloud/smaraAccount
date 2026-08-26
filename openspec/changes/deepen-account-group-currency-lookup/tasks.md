## 1. Repository seam

- [x] 1.1 Design `AccountRepository` (or catalog) API for account→group currency (stream and/or snapshot)
- [x] 1.2 Implement lookup with unit tests (known account, missing account, group currency change)

## 2. Migrate callers

- [x] 2.1 Replace `currencyFor` in record-transaction, register, transfer, settle-pending, recurring-template view models
- [x] 2.2 Replace statement-import `groupCurrencyFor` with the shared lookup
- [x] 2.3 Delete duplicate local join helpers and unused dual subscriptions where safe

## 3. Verify

- [x] 3.1 View-model unit tests updated and green
- [x] 3.2 Spot-check currency/transfers acceptance on macOS if transfer flows changed construction
