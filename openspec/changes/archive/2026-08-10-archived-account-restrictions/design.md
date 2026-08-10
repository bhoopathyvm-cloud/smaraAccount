## Context

Financial-account archiving already exists (`archiveFinancialAccount` in `lib/data/repositories/ledger_repository.dart`, driven from `account_management_view.dart`). Today, archiving:
- Sets `accounts.archivedAt`, is blocked only when it would archive the last active financial account.
- Excludes the account from `watchFinancialAccounts()` by default, which already keeps archived accounts out of the record-transaction and general-transfer pickers (`record_transaction_view_model.dart`, `transfer_view_model.dart` both call `watchFinancialAccounts()` with the default `includeArchived: false`).
- Leaves the account and its full history visible in the register (`RegisterViewModel` calls `watchFinancialAccounts(includeArchived: true)`) and on the home overview.
- Is enforced at the repository boundary via `_requireActiveFinancialAccount`, used by `recordTransaction`, `recordTransfer`, and `archiveFinancialAccount` itself — so an archived account can never be a party to a new transaction or transfer today, including as a transfer source.

That last point is the gap: there is currently no way to move a leftover balance out of an archived account. The account stays visible with a nonzero balance forever. This change adds one narrow, self-terminating exception (a single full-balance closeout transfer out of an archived account) and closes a UI gap (the register's add-transaction FAB is currently always enabled, even when the viewed account is archived).

This branch also carries the in-progress `multi-currency-support` change, which already gives `recordTransfer` cross-currency behavior (a same-currency single entry, or a cross-currency entry that's either complete when `destinationAmountMinor` is known or provisional/pending settlement otherwise). The closeout transfer reuses that same posting logic rather than inventing a parallel code path.

## Goals / Non-Goals

**Goals:**
- Let a user with a positive-balance archived account drain it to a different, active financial account in exactly one transfer, then never again.
- Keep every other archived-account restriction exactly as strict as it is today (no other transactions, no other transfers, not offered in entry pickers).
- Disable the register's "+" add-transaction affordance whenever the account currently being viewed is archived.
- Reuse existing balance computation (`displayBalanceMinor`) and transfer-posting logic rather than duplicating it.

**Non-Goals:**
- Un-archiving / restoring an account is out of scope.
- Bulk closeout across multiple archived accounts is out of scope — this is a one-account-at-a-time affordance.
- Negative or zero balances are not eligible for closeout; there is nothing to move, so the archived account simply stays fully read-only (matches the literal "if there is positive amount" condition from the request).
- No change to how archiving itself is triggered or to the last-active-account guard.

## Decisions

### 1. One `AccountRow`-resolution helper gains a "closeout" mode instead of bypassing the archived check entirely
`_requireActiveFinancialAccount` stays as-is (still used by `recordTransaction` and as the destination check for transfers). Add a sibling, `_requireCloseoutEligibleFinancialAccount(id)`, that requires the account to be a financial account, archived, and to have a strictly positive `displayBalanceMinor`. This keeps the "why archived is rejected" reasoning (`AccountGroupException`) intact for every other call site, and makes the closeout eligibility check (archived + positive balance) a single reusable, testable unit instead of scattering `if (archived && balance > 0)` checks across the UI layer.

**Alternative considered**: add an `allowArchivedSource: bool` flag to `_requireActiveFinancialAccount` / `recordTransfer`. Rejected — it would let any caller silently loosen the archived check for both source and destination, and it conflates "not found / wrong type" with "archived but eligible for exactly this one flow."

### 2. Extract the posting core of `recordTransfer` so closeout can reuse it verbatim
`recordTransfer` currently does validation (amount positive, accounts distinct, both active) and then posts (same-currency single entry, or cross-currency complete/provisional entry per multi-currency-support design). Extract the posting half into a private `_postTransfer({required AccountRow fromAccount, required AccountRow toAccount, required int amountMinor, required DateTime transactionDate, String? description, int? destinationAmountMinor})`. `recordTransfer` keeps its existing validation and calls `_postTransfer`. The new `recordArchivedAccountCloseoutTransfer` does its own validation (closeout-eligible source, active distinct destination, amount fixed to the source's current balance) and also calls `_postTransfer`.

**Alternative considered**: have the closeout method call `recordTransfer` directly after temporarily "unlocking" the source. Rejected — `recordTransfer` re-derives the amount from the caller instead of the ledger, which would let a caller pass an amount that doesn't match the account's actual balance; forcing the amount server-side (repository-computed, not UI-supplied) is the whole point of "one last transfer with all the amount."

### 3. Amount is server-computed, not user-entered
The closeout dialog shows the current balance as a read-only figure; the repository re-derives it from `displayBalanceMinor` at submit time (not trusting a value passed from the UI) and posts exactly that amount. If the balance changed between opening the dialog and confirming (shouldn't normally happen since archived accounts reject all other postings, but defends against a second closeout attempt after a first succeeded), the second call simply finds balance <= 0 and rejects via `_requireCloseoutEligibleFinancialAccount`, which also makes the exception self-terminating without an extra "already settled" flag.

### 4. Closeout is surfaced from the account register (details) view, not the general Transfer screen
The general Transfer screen's account pickers stay exactly as they are (`watchFinancialAccounts()`, archived excluded from both sides) — this change does not touch that screen. Instead, `RegisterView` — already the "account details" screen per the routing (`/register/:accountId`), already showing archived accounts read-only — gains a "Transfer remaining balance" action, visible only when the selected account is archived and its balance is positive, opening a small dialog (destination-account dropdown limited to active accounts + fixed amount + optional description/date) styled like the existing `_confirmArchive` dialog in `account_management_view.dart`.

**Alternative considered**: extend `TransferViewModel`/`TransferView` to conditionally accept an archived source. Rejected — that screen's account list intentionally represents "accounts you can freely move money between," and threading a one-off eligibility rule through its general-purpose picker (which also drives `isCrossCurrency`, destination-amount entry, etc.) is more invasive than a small purpose-built dialog scoped to the one place the archived account is actually being looked at.

### 5. FAB disabling is driven by the same `archived` flag already on `Account`
`RegisterViewModel` already exposes the selected account via `_accountsById`; add a `bool get isSelectedAccountArchived` derived from it. `RegisterView` passes `onAddTransaction: viewModel.isSelectedAccountArchived ? null : onAddTransaction`. Passing `null` to `FloatingActionButton.onPressed` renders it disabled (dimmed, non-interactive) — no new state needed.

## Risks / Trade-offs

- [Risk] A user could interpret "positive amount" as "any nonzero amount" and expect a closeout affordance for an archived liability account showing a negative display balance. → Mitigation: this change follows the request literally (positive balance only); if liability payoff-on-archive turns out to be needed, it's a separate, explicit follow-up rather than an assumption baked in here.
- [Risk] Cross-currency closeout inherits the existing provisional/pending-settlement path from multi-currency-support, meaning a closeout into a different-currency account might not fully zero the source balance in one step if the rate isn't supplied up front. → Mitigation: require `destinationAmountMinor` (i.e. only allow the "known rate" complete-entry path) for closeout specifically, so the source leg is always a single, terminal entry — no pending state left behind on an account the user just tried to fully retire.
- [Risk] Extracting `_postTransfer` touches a well-exercised code path (`recordTransfer`). → Mitigation: pure extraction, no behavior change to `recordTransfer` itself; existing `ledger_repository_test.dart` transfer tests continue to cover it unchanged, plus new tests for the extracted method via both call sites.

## Open Questions

None — proceeding with the decisions above; revisit if the user wants liability payoff-on-archive or bulk closeout later.
