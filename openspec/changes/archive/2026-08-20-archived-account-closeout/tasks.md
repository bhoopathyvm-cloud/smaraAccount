## 1. Repository: closeout-eligible account and shared posting

- [x] 1.1 Add `_requireCloseoutEligibleFinancialAccount(id)` to `LedgerRepository`: financial account, `archivedAt != null`, `displayBalanceMinor(id) > 0`; throw `AccountGroupException` otherwise.
- [x] 1.2 Extract the posting half of `recordTransfer` into private `_postTransfer` (same-currency / known-rate cross-currency / provisional cross-currency). `recordTransfer` validation stays as-is and calls `_postTransfer`.

## 2. Repository: closeout method

- [x] 2.1 Add `recordArchivedAccountCloseoutTransfer({required String fromAccountId, required String toAccountId, required DateTime transactionDate, String? description, int? destinationAmountMinor})`: closeout-eligible source, active distinct destination, `amountMinor` from `displayBalanceMinor(fromAccountId)`, then `_postTransfer`.
- [x] 2.2 If source and destination group currencies differ, require `destinationAmountMinor`; reject a missing or non-positive destination amount so no pending transfer is created.
- [x] 2.3 Confirm `recordTransaction` and `recordTransfer` still reject an archived account on every path except the new closeout method.

## 3. Repository tests

- [x] 3.1 Closeout from an archived account with a positive balance to an active account posts and zeroes the source display balance.
- [x] 3.2 Closeout rejected when the archived account's balance is zero or negative.
- [x] 3.3 Closeout rejected when the destination is also archived.
- [x] 3.4 Closeout rejected when `fromAccountId == toAccountId`.
- [x] 3.5 A second closeout after a successful first is rejected.
- [x] 3.6 `recordTransaction` against an archived account is still rejected.
- [x] 3.7 `recordTransfer` still rejects an archived account as source or destination.
- [x] 3.8 Cross-currency closeout without `destinationAmountMinor` is rejected; with it, one complete entry and no pending row.

## 4. Register view model and view

- [x] 4.1 Expose `selectedAccountBalanceMinor` and `canCloseoutSelectedAccount` (`isSelectedAccountArchived && selectedAccountBalanceMinor > 0`) on `RegisterViewModel`.
- [x] 4.2 Expose `closeoutDestinationCandidates`: active financial accounts excluding the selected one.
- [x] 4.3 Add `closeoutSelectedAccount` on `RegisterViewModel` calling `recordArchivedAccountCloseoutTransfer`, surfacing domain exceptions the same way `reverseEntry` does.
- [x] 4.4 Disable the plus FAB when `isSelectedAccountArchived` (`onPressed: null`), matching import/transfer FABs.
- [x] 4.5 When `canCloseoutSelectedAccount`, show a "Transfer remaining balance" action that opens a dispose-safe dialog: destination `EntityPickerField`, read-only full-balance amount, optional description/date, and a destination-amount field only when the chosen destination's group currency differs.

## 5. View / view-model tests

- [x] 5.1 Widget test: plus FAB has no `onPressed` when the selected account is archived; enabled when active.
- [x] 5.2 Widget test: closeout affordance is shown only when the selected account is archived and has a positive balance.
- [x] 5.3 View-model test: `closeoutSelectedAccount` success notifies listeners; failure surfaces an error without changing `selectedAccountId`.

## 6. User guide and verification

- [x] 6.1 Document archived-account restrictions and the register closeout flow in `docs/user-guide.md` (do not describe it as available before this change ships).
- [x] 6.2 Run `dart analyze` and the full test suite; fix any new warnings.
