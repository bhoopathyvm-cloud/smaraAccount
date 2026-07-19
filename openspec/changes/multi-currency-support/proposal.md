## Why

The user holds financial accounts across multiple countries and currencies. Their working model is deliberately simple: no auto-conversion, no blended totals — each account group is single-currency, and a account's displayed currency is just whichever group it belongs to. `multi-account-support` (in progress, not yet implemented) ships a single blended "Overall Net Position" number and a `recordTransfer` that assumes both sides settle atomically in the same currency — neither survives once accounts span currencies. Capturing this now, before `multi-account-support`'s schema and transfer/home-overview behavior ship, means the follow-on lands cleanly on top instead of requiring rework of an already-shipped feature.

## What Changes

- `account_groups` gains a `currency` field (ISO 4217 code). Financial accounts stay currency-agnostic in schema — an account's *display* currency is derived by joining to its group, never stored redundantly on the account itself.
- Home overview's net worth becomes **per-currency** (one net position per currency present, not one blended figure) — no FX conversion anywhere in the app.
- A same-currency transfer (both accounts' groups share a currency) is unchanged from `multi-account-support`'s design: one balanced entry, two postings.
- A cross-currency transfer or foreign-currency income/expense transaction where the final amount is known upfront (e.g. a Wise-style quoted-rate transfer) posts as a single complete entry immediately — two postings, each in its own currency, not required to numerically sum to zero.
- A cross-currency transfer or foreign-currency transaction where the final amount is **not** known upfront (e.g. an international wire pending fees, or a credit-card purchase abroad that settles days later at an unknown rate) posts as two linked, individually-balanced entries instead of one:
  - **Provisional entry** (now): the known side posts for real — the source account debits (transfer) or the category posts (transaction) — balanced against a new internal system "Transfers in transit" clearing account, in the known/source currency.
  - **Settlement entry** (later, manual): once the actual amount is known, the user settles it — the clearing position closes out against the actual destination (which may be the original destination, or the original source account itself if the transfer bounced back), in the destination currency.
- Settlement and cancellation are the same action: settling to the original destination is a normal completion; settling to the source account for less than the original amount (a bounced/failed transfer with a retained fee) is a "cancellation," auto-deriving the shortfall as a fee/expense entry that closes the remaining clearing position. No separate cancel code path.
- Home overview gains a "Pending transfers" section: one line item per unsettled transfer/transaction, counted toward that currency's net worth while pending (it's still the user's money, just in motion).
- The "Transfers in transit" system account is never user-selectable (same treatment as the `equity` opening-balance offset account from `multi-account-support`), and its balance is never summed as a single figure — always viewed itemized, one row per pending item.

## Capabilities

### New Capabilities
- `account-currency`: currency lives on `account_groups`; accounts are currency-agnostic in schema; an account's and its entries' display currency is derived from group membership; home overview net worth is computed per-currency instead of as one blended figure.
- `foreign-currency-settlement`: the two-phase provisional/settled posting model — the internal clearing account, the pending-transfer/pending-transaction lifecycle (pending → settled), the unified settle-or-cancel action with fee derivation, and the "Pending transfers" home overview section.

### Modified Capabilities
- `multi-account-ledger` (introduced by `multi-account-support`, not yet archived): `recordTransfer` branches into same-currency (unchanged), cross-currency-known-upfront (single entry), and cross-currency-unknown (provisional + later settlement via `foreign-currency-settlement`). Foreign-currency income/expense transactions get the same provisional/settlement treatment when the account's group currency doesn't match the transaction's native currency.
- `accounts-home-overview` (introduced by `multi-account-support`, not yet archived): "Overall Net Position" becomes one net position per currency; adds the "Pending transfers" section.

## Impact

- Depends on `multi-account-support` shipping and being archived first — `account_groups`, `recordTransfer`, and the home overview must exist before this change's delta specs (which target `multi-account-ledger` and `accounts-home-overview` by their post-archive names) can apply.
- New `schemaVersion` bump (5th; sequenced after `multi-account-support`'s 3rd — see design.md for the exact number once `multi-account-support` archives), adding `account_groups.currency`, a system "Transfers in transit" account, and a new pending-transfer/pending-settlement table.
- `LedgerRepository` gains provisional-post and settle/cancel write paths, through the same signed hash-chained path as `recordTransaction`/`recordTransfer`/`reverseEntry` — no new ad hoc write mechanism.
- Home overview UI and ViewModel change from one net-position figure to a per-currency list, plus a new pending-transfers list.
- No FX rate lookup, conversion library, or exchange-rate storage is introduced anywhere — deliberately out of scope per the user's stated philosophy (no conversion, ever).
