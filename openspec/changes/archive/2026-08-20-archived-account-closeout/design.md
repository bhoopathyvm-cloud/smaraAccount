## Context

See proposal.md for why. Archiving already sets `archivedAt`, blocks the last active account, hides archived accounts from `watchFinancialAccounts()` (the record-transaction and general-transfer pickers), and keeps them visible on the register and home overview. `_requireActiveFinancialAccount` is used by `recordTransaction` and both sides of `recordTransfer`, so an archived account cannot be a party to any new posting today.

`RegisterViewModel.isSelectedAccountArchived` already exists. The import and transfer FABs already pass `null` when it is true. The plus FAB still always calls `onAddTransaction`. There is no closeout method, dialog, or test.

`recordTransfer` already branches same-currency / known-rate cross-currency / provisional cross-currency. Closeout must reuse that posting core without inventing a parallel write path, and must not leave a pending transfer on an account the user is retiring.

## Goals / Non-Goals

**Goals:**
- One self-terminating closeout from an archived account with a strictly positive display balance to a different active account.
- Amount computed in the repository from `displayBalanceMinor` at submit time.
- Closeout offered only from that account's register.
- Plus FAB disabled when the selected account is archived.
- Cross-currency closeout only via the known-rate complete-entry path.

**Non-Goals:**
- Un-archiving / restoring an account.
- Bulk closeout across many archived accounts.
- Closeout for zero or negative display balances (including a liability that still shows amount owed as a positive display balance is eligible; a negative display balance is not).
- Changing how archiving is triggered or the last-active-account guard.
- Opening the general Transfer screen with an archived source.

## Decisions

### 1. Sibling resolver instead of a flag on `_requireActiveFinancialAccount`
Add `_requireCloseoutEligibleFinancialAccount(id)`: financial account, `archivedAt != null`, `displayBalanceMinor(id) > 0`. `_requireActiveFinancialAccount` stays the default for every other write. A boolean `allowArchivedSource` on the existing helper would let any caller silently loosen both source and destination checks.

### 2. Extract `_postTransfer` and add `recordArchivedAccountCloseoutTransfer`
`recordTransfer` keeps its current validation (both active, amount caller-supplied) and calls `_postTransfer`. The closeout method resolves the source via the closeout helper, the destination via `_requireActiveFinancialAccount`, rejects same-id, re-derives `amountMinor` from `displayBalanceMinor`, and calls `_postTransfer`. If the destination group currency differs, `destinationAmountMinor` is required; omit it and reject rather than posting a provisional entry.

### 3. Amount is repository-computed
The dialog shows the current balance as read-only. A second closeout after a successful first finds balance `<= 0` and is rejected by the closeout helper — no extra "already closed out" flag.

### 4. Register dialog, not TransferView
`RegisterView` already is the account-details surface (`/register/:accountId`) and already lists archived accounts. Add a "Transfer remaining balance" action visible only when `isSelectedAccountArchived && selectedAccountBalanceMinor > 0`. Destination picker is active accounts excluding the selected one. Reuse `EntityPickerField`, `MoneyAmountField` only if a cross-currency destination amount is needed, and `confirmDestructiveAction` is the wrong shape (this is not destructive archive). Style the dialog like the existing account-management create/rename dialogs (dispose-safe controllers).

### 5. Plus FAB uses the existing archived flag
`onPressed: viewModel.isSelectedAccountArchived ? null : onAddTransaction`, matching import/transfer FABs.

## Risks / Trade-offs

- [Risk] A user expects closeout of a negative display balance (e.g. overdrawn asset). → Mitigation: follow the existing main-spec rule (strictly positive only). A payoff-on-archive for liabilities that are "amount owed" is already covered when display balance is positive.
- [Risk] Extracting `_postTransfer` touches a well-tested path. → Mitigation: pure extraction; existing `recordTransfer` tests stay; new tests go through the public closeout method.
- [Risk] Balance changes between opening the dialog and confirm. → Mitigation: archived accounts reject other writes; a stale dialog still re-reads balance at submit and rejects if no longer positive.

## Migration Plan

No schema change. Ship as a normal app update. Rollback is revert; no data migration.

## Open Questions

None. Liability payoff-on-archive for a *negative* display balance is a later change if ever needed.
