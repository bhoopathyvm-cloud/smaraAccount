## 1. Repository: closeout-eligible account resolution

- [ ] 1.1 Add `_requireCloseoutEligibleFinancialAccount(id)` to `LedgerRepository`: resolves the account, requires it to be a financial account, requires `archivedAt != null`, requires `displayBalanceMinor(id) > 0`; throws `AccountGroupException` otherwise (mirroring `_requireActiveFinancialAccount`'s error style).
- [ ] 1.2 Extract the posting half of `recordTransfer` (same-currency single entry / cross-currency complete entry / cross-currency provisional entry) into a private `_postTransfer({required AccountRow fromAccount, required AccountRow toAccount, required int amountMinor, required DateTime transactionDate, String? description, int? destinationAmountMinor})`, called by the existing `recordTransfer` validation path with no behavior change.

## 2. Repository: closeout transfer method

- [ ] 2.1 Add `recordArchivedAccountCloseoutTransfer({required String fromAccountId, required String toAccountId, required DateTime transactionDate, String? description, int? destinationAmountMinor})` to `LedgerRepository`: resolves `fromAccount` via `_requireCloseoutEligibleFinancialAccount`, resolves `toAccount` via `_requireActiveFinancialAccount`, rejects `fromAccountId == toAccountId`, re-derives `amountMinor` from `displayBalanceMinor(fromAccountId)` (never trusts a caller-supplied amount), and calls `_postTransfer`.
- [ ] 2.2 If `fromAccount`'s group currency differs from `toAccount`'s group currency, require `destinationAmountMinor` to be supplied (reject a provisional/pending-settlement closeout) so the source leg always posts as a single terminal entry.
- [ ] 2.3 Confirm `recordTransaction` and `recordTransfer` (both sides, both source and destination) are unaffected — an archived account remains rejected via `_requireActiveFinancialAccount` for every path except the new closeout method.

## 3. Repository tests

- [ ] 3.1 Test: closeout transfer from an archived account with a positive balance to an active account posts and zeroes the source balance.
- [ ] 3.2 Test: closeout transfer rejected when the archived account's balance is zero or negative.
- [ ] 3.3 Test: closeout transfer rejected when the destination account is also archived.
- [ ] 3.4 Test: closeout transfer rejected when `fromAccountId == toAccountId`.
- [ ] 3.5 Test: a second closeout attempt after the first succeeds is rejected (balance is no longer positive).
- [ ] 3.6 Test: `recordTransaction` against an archived account is still rejected (regression).
- [ ] 3.7 Test: `recordTransfer` still rejects an archived account as source or destination (regression, exercised through the public method, not the closeout method).
- [ ] 3.8 Test: cross-currency closeout without `destinationAmountMinor` is rejected.

## 4. Register (account details) view model and view

- [ ] 4.1 Add `bool get isSelectedAccountArchived` to `RegisterViewModel`, derived from `_accountsById[_selectedAccountId]?.archived`.
- [ ] 4.2 Add `int get selectedAccountBalanceMinor` (or equivalent) to `RegisterViewModel` sourced from the existing balance computation, and `bool get canCloseoutSelectedAccount` true only when `isSelectedAccountArchived && selectedAccountBalanceMinor > 0`.
- [ ] 4.3 Add `List<Account> get closeoutDestinationCandidates` to `RegisterViewModel`: active financial accounts excluding the selected one.
- [ ] 4.4 Add `Future<bool> closeoutSelectedAccount(String toAccountId)` to `RegisterViewModel` calling `ledgerRepository.recordArchivedAccountCloseoutTransfer`, surfacing `AccountGroupException`/`InvalidTransferException` messages the same way `reverseEntry` and other view-model methods do.
- [ ] 4.5 In `RegisterView`, pass `onAddTransaction: viewModel.isSelectedAccountArchived ? null : onAddTransaction` to the `FloatingActionButton` so it renders disabled for an archived account.
- [ ] 4.6 In `RegisterView`, when `viewModel.canCloseoutSelectedAccount` is true, show a "Transfer remaining balance" affordance (banner or app-bar action) that opens a dialog styled like `_confirmArchive` in `account_management_view.dart`: destination-account dropdown (`closeoutDestinationCandidates`), read-only full-balance amount, optional description/date, Confirm/Cancel actions calling `closeoutSelectedAccount`.

## 5. View / view-model tests

- [ ] 5.1 Widget test: register FAB is disabled (no `onPressed`) when the selected account is archived.
- [ ] 5.2 Widget test: register FAB is enabled when the selected account is active.
- [ ] 5.3 Widget test: closeout affordance is shown only when the selected account is archived and has a positive balance, and hidden otherwise (active account, archived with zero/negative balance).
- [ ] 5.4 View-model test: `closeoutSelectedAccount` success path notifies listeners and clears any error; failure path surfaces an error message without mutating `selectedAccountId`.

## 6. Verification

- [ ] 6.1 Run `dart analyze` and fix any new warnings.
- [ ] 6.2 Run the full test suite (`flutter test`) and confirm no regressions in existing transfer/transaction/archive coverage.
- [ ] 6.3 Manually exercise the golden path in the running app: archive an account with a positive balance, confirm the register shows it read-only with the FAB disabled, run the closeout transfer, confirm the balance is zero and the affordance disappears.
