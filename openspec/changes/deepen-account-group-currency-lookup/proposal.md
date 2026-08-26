## Why

Five view models each subscribe to `watchFinancialAccounts` + `watchAccountGroups` and implement identical `currencyFor(accountId)` join logic; statement import uses a third variant (`groupCurrencyFor`). These are shallow UI modules whose interface (two streams + lookup) nearly matches their implementation — no leverage, and cross-currency rules in Transfer/Register depend on copy-paste staying in sync.

## What Changes

- Deepen `AccountRepository` (or a small catalog read model) with a reactive group-currency lookup for an account.
- Replace duplicated `currencyFor` / `groupCurrencyFor` joins in record, register, transfer, settle-pending, recurring-template, and statement-import flows with that one seam.
- Preserve existing FX / same-currency guard behavior.

## Capabilities

### New Capabilities
- `account-group-currency-lookup`: one repository (or catalog) interface for resolving an account’s group currency reactively.

### Modified Capabilities
- (none — product multi-currency and transfer requirements unchanged)

## Impact

- `lib/data/repositories/account_repository.dart`, `statement_import_repository.dart`
- View models: `record_transaction`, `register`, `transfer`, `settle_pending_transfer`, `recurring_template_management`
- View-model unit tests that assert `currencyFor`
