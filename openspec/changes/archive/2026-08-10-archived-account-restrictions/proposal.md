## Why

Archiving a financial account already hides it from new-transaction pickers, but three gaps remain: an account can be archived while still holding a balance with no way to ever move that money out (archived accounts are excluded from every transfer picker, including as the source), the per-account register's "add transaction" button stays enabled even when the viewed account is archived, and there is no explicit rule closing the loop between "archived accounts are read-only" and "except for a single balance-clearing transfer." Users who archive an account with a leftover balance currently get stuck: the funds are visible but permanently untouchable through the UI.

## What Changes

- Allow exactly one outbound transfer from an archived financial account: only when its current balance is positive, only for the full balance amount, only to a different (active) financial account. After that transfer the balance is zero and the account has no further transfer allowance.
- Reject all other transaction/transfer attempts that reference an archived account as a debit/source, non-full-balance amount, or archived destination — the existing "archived accounts rejected" behavior stays the default; the closeout transfer is the sole carve-out.
- Keep archived accounts fully readable: register history, running balance, and account details remain visible exactly as today (no change needed here, confirmed as a hard requirement).
- Disable the "+" add-transaction floating action button on the account register/details view whenever the currently selected account is archived.
- Keep archived accounts out of the account picker on the transaction-entry screen (already the case) and clarify this is required behavior, not incidental.
- Surface the one-time closeout transfer as an explicit affordance reachable from the archived account's register/details view (rather than only through the general Transfer screen, which excludes archived accounts as a source).

## Capabilities

### New Capabilities
(none)

### Modified Capabilities
- `multi-account-ledger`: "Rename and Archive Financial Accounts" gains a bounded exception — a single full-balance closeout transfer out of an archived account is now permitted — plus an explicit requirement that the register's add-transaction control is disabled for an archived account and that archived accounts stay excluded from transaction/transfer source-and-destination pickers otherwise.

## Impact

- `lib/data/repositories/ledger_repository.dart`: `recordTransfer`/`_requireActiveFinancialAccount` gain a closeout path that permits an archived `fromAccountId` only when the transfer amount equals the account's current full balance and `toAccountId` is active.
- `lib/ui/features/register/views/register_view.dart` and `register_view_model.dart`: expose whether the selected account is archived so the FAB can be disabled, and surface a closeout-transfer entry point when the archived account has a positive balance.
- `lib/ui/features/transfer/...`: either a new lightweight closeout flow or an extension of the existing Transfer screen to accept an archived source account under the closeout constraints.
- `openspec/specs/multi-account-ledger/spec.md`: requirement updates described above.
