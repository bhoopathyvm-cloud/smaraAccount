## 1. Register-scoped Transfer entry point

- [x] 1.1 Add `initialFromAccountId` to `TransferViewModel`, applying it on the first `watchFinancialAccounts` emission while `_fromAccountId` is still null (same timing as `RecordTransactionViewModel.initialFinancialAccountId`). Only accept the id when it appears in the active-accounts list; otherwise fall back to default selection (do not keep a stale/archived source)
- [x] 1.2 Add an `onTransfer` callback to `RegisterView` and a "Transfer" action next to the existing add-transaction FAB (e.g. a `Column` of FABs in the single `floatingActionButton` slot, or an app-bar icon). Existing FABs each set an explicit unique `heroTag` (`'register-fab'`, `'accounts-fab'`, `'categories-fab'`) specifically because `StatefulShellRoute.indexedStack` keeps every tab mounted simultaneously (confirmed by a regression test in `integration_test/app_test.dart` for a Hero-tag collision this app hit before, between two tabs' FABs) - a new `FloatingActionButton` here needs its own distinct tag too (e.g. `'register-transfer-fab'`), not just distinct from `'register-fab'` but from every other screen's FAB tag
- [x] 1.3 Disable or hide the register Transfer action when the selected account is archived (ordinary transfer remains active-accounts-only). Check first whether `RegisterViewModel.isSelectedAccountArchived` already exists (planned by the separate `archived-account-restrictions` change for the same reason, on its own add-transaction FAB) before adding a new getter - reuse it if present rather than duplicating
- [x] 1.4 Wire `onTransfer` in `app_router.dart`'s `_buildRegister`: navigate to `/transfer?fromAccountId=<selectedAccountId>`, mirroring the existing `/record-transaction?accountId=...` pattern and `AccountManagementView.onTransfer`
- [x] 1.5 Update the `/transfer` route builder to read `fromAccountId` from `state.uri.queryParameters` and pass it as `initialFromAccountId`

## 2. Transfer fee (commission)

- [x] 2.1 Add optional fee amount + fee expense-category fields to `TransferViewModel` and `TransferView` (subscribe to `watchCategories()` filtered to expense inside `TransferViewModel` itself, matching `SettlePendingTransferViewModel`'s existing pattern - not `RecordTransactionViewModel`, which instead leaves category fetching to a `StreamBuilder` in its view against a repository reference the view holds directly; `TransferViewModel` already holds `_ledgerRepository` and subscribes to accounts/groups itself, so the ViewModel-side pattern is the better fit here). Fee is always source-currency same-currency money-out — call `recordTransaction` without `nativeCurrency` / `accountCurrencyAmountMinor` so it cannot enter the foreign-currency provisional path.
- [x] 2.2 On submit, when the user opted into a fee: validate positive fee amount + active expense category **before** any repository write; then call `recordTransfer` first, then `recordTransaction` (money-out, source account, chosen category, fee amount) using the same transaction date. `TransferViewModel.submit()` today only catches `InvalidTransferException` and `AccountGroupException`; the new `recordTransaction` call can also throw `InvalidTransactionAmountException`, which must be caught too. If the transfer posts successfully but the fee call then throws, surface that clearly as "transfer saved, fee failed" rather than a generic failure - the transfer must not appear to have failed when it didn't. Orchestration stays in the ViewModel (no new `LedgerRepository` API).
- [x] 2.3 Default the fee entry's description to reference the transfer (e.g. "Fee for transfer to {destination account name}") when the user leaves it blank
- [x] 2.4 Add brief helper copy that this fee is an upfront commission, distinct from any later settlement shortfall fee on provisional cross-currency transfers

## 3. Settings (rate lookup toggle + provider)

- [x] 3.1 Add the `shared_preferences` dependency for non-secret preferences (do not store these in `flutter_secure_storage`)
- [x] 3.2 Define a fixed `ExchangeRateProvider` (or equivalent) enum/list with at least `frankfurter` and `openErApi`, each mapped to its endpoint inside the rate service — no custom URL / API-key UI
- [x] 3.3 Implement a small preferences store/API for (a) reference-rate enabled bool defaulting to **false**, and (b) selected provider defaulting to the first enum entry; persist across restarts. Store the provider as its string name (e.g. `.name`); when reading it back, if the stored value doesn't match any current `ExchangeRateProvider` case (e.g. a future release renamed or removed one the user had selected), fall back to the default provider instead of throwing - don't let `enum.values.byName` crash Settings or the Transfer screen on load
- [x] 3.4 Add a `/settings` route (top-level push, outside the shell branches, like `/transfer`) and a minimal Settings screen with the enable toggle and provider dropdown
- [x] 3.5 Add `onOpenSettings` to `HomeView` as an **optional** `VoidCallback?` (not `required`), matching the existing `onSettlePendingTransfer` precedent on the same widget - `onAccountTap` is `required` but `onSettlePendingTransfer` deliberately isn't, specifically so call sites that don't need it (three existing widget tests construct `HomeView` with only `viewModel` + `onAccountTap`) don't break. Add a gear `IconButton` in its app bar `actions`; wire it in `app_router.dart` to `context.push('/settings')` (do not import go_router into `HomeView`)
- [x] 3.6 When the toggle is off, disable or de-emphasize the provider dropdown (still visible so the user can choose a provider before enabling, or greyed — pick one consistent pattern at apply time) without allowing network calls while disabled

## 4. Reference exchange rate lookup

- [x] 4.1 Add the `http` package dependency
- [x] 4.2 Implement `ExchangeRateService` with `fetchRate(from, to)` that dispatches to the **currently selected** predefined provider; short timeout; returns `null` on any failure (never throws to the caller); normalize to destination units per 1 source unit; request must not include ledger amounts or account identifiers
- [x] 4.3 Make `ExchangeRateService` (and access to the enabled/provider preferences) injectable on `TransferViewModel` for tests, mirroring `LedgerRepository`'s optional `SigningKeyService` injection pattern
- [x] 4.4 In `TransferViewModel`, call `fetchRate` only when: lookup is enabled in Settings, `isCrossCurrency` is true, and both accounts are selected — never on every keystroke; make **zero** network attempts when disabled (check before call, not fetch-then-hide); cancel or ignore in-flight results when the pair changes, preferences change, or the ViewModel is disposed
- [x] 4.5 In `TransferView`, show the reference rate next to the destination-amount field when available; show nothing when `null`/disabled; when both amounts are present, optionally show the implied rate (display-only; allowed even when lookup is disabled)
- [x] 4.6 Confirm the reference rate (and implied rate) never write into `destinationAmountMinor` - display-only

## 5. Tests

- [x] 5.1a Widget test (`test/ui/features/register/views/register_view_test.dart`, matching its existing bare-`MaterialApp`/mocked-repository style): tapping the new Transfer action invokes `RegisterView`'s own callback - this view has no router awareness, so a widget test can only verify the callback fires, not that navigation with a pre-selected account happens
- [x] 5.1b Integration test (`integration_test/app_test.dart`, matching its existing real-router style, e.g. the "navigating from Home to a different account" test): tapping Transfer from an account's register actually opens the Transfer screen with that account pre-selected as the source
- [x] 5.1c Widget test: register Transfer action is not offered (or not tappable) when the selected account is archived
- [x] 5.2 ViewModel/unit test: `TransferViewModel.submit` with a valid fee calls `recordTransfer` then `recordTransaction` with the expected amounts/categories; reversing one entry in the repository leaves the other unchanged (can use a real in-memory repository or verify mock call order plus a small repository reversal regression)
- [x] 5.3 ViewModel/unit test: submit without a fee calls only `recordTransfer` (unchanged behavior)
- [x] 5.3b ViewModel/unit test: invalid fee (missing category or non-positive amount) does not call `recordTransfer` or `recordTransaction`
- [x] 5.3c ViewModel/unit test: when `recordTransfer` succeeds and `recordTransaction` fails, error text indicates transfer saved / fee failed
- [x] 5.4 Unit test `ExchangeRateService` against a fake/mocked HTTP client for **each** predefined provider mapping: success, timeout, non-200, and malformed-response cases all resolve to a rate or `null` without throwing; success asserts destination-per-source normalization
- [x] 5.5 Unit/ViewModel test: when the reference-rate setting is disabled, `fetchRate` is never called for a cross-currency pair
- [x] 5.6 Widget/unit test: Settings defaults to lookup disabled; toggling enable and changing provider persists (use a fake/in-memory preferences layer)
- [x] 5.7 Widget test: the reference rate row is absent when the service returns `null` or lookup is disabled, and its presence never alters the destination-amount field's value
- [x] 5.7b Unit test: reading back an unrecognized/stale persisted provider name falls back to the default provider rather than throwing
- [x] 5.8 Run `dart analyze` and the full test suite; fix any regressions
