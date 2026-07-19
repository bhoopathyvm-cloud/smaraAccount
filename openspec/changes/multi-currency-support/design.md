## Context

`multi-account-support` (in progress, not yet implemented) introduces `account_groups`, extends `accounts` with `group_id`, adds `recordTransfer`, and adds a Home overview with a single blended net-position figure. It explicitly listed multi-currency as a non-goal and left a forward-reference note under its Decision 1 pointing at this change. `ledger-integrity-signing` (implemented) requires every journal write to go through the same signed, hash-chained path, and posted entries are immutable (Golden Rule #7) — corrections are new entries, never edits.

This design comes out of a direct exploration conversation with the user, not a research survey. The user's stated model, verbatim in spirit: no automatic currency conversion anywhere, ever; a group is single-currency; an account has no currency of its own beyond "which group it's in"; a transfer or foreign transaction whose final settled amount isn't known yet posts what's known now and gets completed manually later; when the rate/fee *is* known upfront (e.g. a Wise-style quoted transfer), it can post as one complete entry immediately.

## Goals / Non-Goals

**Goals:**
- Currency as a property of `account_groups`, not `accounts` — one group, one currency, always.
- Home overview net worth reported per-currency, never blended or converted.
- A same-currency transfer/transaction is unchanged from `multi-account-support`.
- A cross-currency movement with a known upfront rate posts as one complete entry.
- A cross-currency movement with an unknown final amount posts as a provisional entry now, settled manually later, through a system "Transfers in transit" clearing account.
- One settlement mechanism handles both normal completion and a bounced/failed transfer that returns less than it sent (fee retained), rather than two separate flows.
- "Pending transfers" surfaced on the Home overview, one line item per pending item, counted toward that currency's net worth while pending.

**Non-Goals:**
- Any FX rate lookup, conversion library, or exchange-rate storage — deliberately never converts between currencies for display.
- Automatic settlement-amount estimation — settlement is always a manual entry of the real, known amount.
- Investment/brokerage accounts — already deferred by `multi-account-support`.
- Reminder/expiry UX for stale pending transfers, or tax/reporting treatment of realized FX gains or losses.
- Multi-device sync.

## Decisions

### 1. Currency lives on `account_groups` only

```
account_groups  (extended)
  ...existing columns from multi-account-support...
  currency      TEXT NOT NULL   -- ISO 4217 code, e.g. 'USD', 'EUR'

accounts        (unchanged from multi-account-support)
  -- no currency column; display currency is derived by joining accounts.group_id -> account_groups.currency
```

**Why not currency on the account?** The user was explicit: "at account no currency needed... it is only money incoming and money outgoing, nothing more." Storing it on the account would also let two accounts in the same group disagree on currency, breaking the "one group, one currency" invariant the group boundary exists to enforce.

**Why not currency on entries/postings?** Redundant with the account's group for every normal posting. The one place currency genuinely needs to vary within a single entry — the clearing-account legs — is handled explicitly in Decisions 3–4, not by making currency a general posting-level field.

### 2. Home overview net worth becomes per-currency

Net position is computed once per currency present among included groups: `Σ asset balances in that currency − Σ liability balances in that currency`. No conversion, no single blended number. This supersedes `multi-account-support`'s "Overall Net Position" requirement (see the accompanying delta spec against `accounts-home-overview`).

**Alternative considered:** keep one blended figure using a fixed or periodically-updated conversion rate. Rejected — directly contradicts the user's stated model ("no convert and show balance in any other currency").

### 3. System "Transfers in transit" clearing account

A single system account (`group_id = NULL`), seeded alongside the existing `equity` opening-balance offset account from `multi-account-support`'s Decision 4. Never appears in any user-facing picker (transaction, transfer, account management) or the Home overview's account rows.

**Its balance is never queried or displayed as one number.** It legitimately holds a source-currency credit from one transfer's provisional leg and a destination-currency debit from a different transfer's settlement leg at the same time — summing those is meaningless. The Repository must not expose a `watchBalance`-style query for this account the way it does for normal financial accounts; the only supported view into it is the itemized `pending_transfers` list (Decision 4).

### 4. `pending_transfers` tracks the two-phase lifecycle

```
pending_transfers
  id                      TEXT PRIMARY KEY
  kind                    TEXT NOT NULL  -- PendingTransferKind { transfer, foreignTransaction } via textEnum<T>(), per Golden Rule #5
  source_account_id       TEXT NOT NULL REFERENCES accounts(id)
  category_id             TEXT NULL REFERENCES accounts(id)   -- set only when kind = foreignTransaction
  destination_account_id  TEXT NULL REFERENCES accounts(id)   -- planned destination; set only when kind = transfer
  provisional_entry_id    TEXT NOT NULL REFERENCES journal_entries(id)
  status                  TEXT NOT NULL  -- PendingTransferStatus { pending, settled } via textEnum<T>()
  settlement_entry_id     TEXT NULL REFERENCES journal_entries(id)
  fee_entry_id            TEXT NULL REFERENCES journal_entries(id)
  initiated_at            INTEGER NOT NULL
  settled_at              INTEGER NULL
```

One row per transfer or foreign-currency transaction that couldn't post as a single complete entry (Decision 6 covers the case that can). `provisional_entry_id` is a normal immutable, signed, chained journal entry — no special-casing in the signing/chain path. Settlement adds up to two more immutable entries; it never edits the provisional entry, consistent with Golden Rule #7. `pending_transfers` itself is a lightweight index over which entries belong together and whether the second half has happened — not a ledger fact in its own right.

### 5. Settlement and cancellation are the same action

```
settlePendingTransfer({
  pendingTransferId,
  settledToAccountId,   // original destination (normal) OR the original source account (bounced/returned)
  settledAmountMinor,   // the real, known amount that actually arrived
  feeCategoryId,        // required only if settledAmountMinor < provisional amount
})
```

If `settledAmountMinor` is less than the provisional entry's amount, the shortfall auto-posts as a second balanced entry — debit the user-chosen expense category / credit clearing — closing the remainder of the clearing position. If `settledAmountMinor` is zero, only the fee entry posts (total loss). The Repository enforces, as an invariant, that settlement + fee amounts always fully close the clearing position opened by the provisional entry; the user never has to reconcile that manually.

**Why not a separate `cancelPendingTransfer`?** A bounced transfer is structurally identical to a settlement — the money just lands back at the source account instead of the planned destination, for less than it left. Two methods would duplicate the same closing-invariant logic. `status` stays `pending | settled`; "delivered" vs. "returned" is a display-only distinction derived by comparing `settledToAccountId` to the original destination, not a separate state.

**Alternative considered:** a seeded default "Transfer fees" expense category, forced for the fee leg. Rejected for v1 — the user picks any expense category at settlement time, same as any other expense; a seeded default can be added later without a migration if it proves to be friction.

### 6. Cross-currency, rate-known-upfront: single entry, no pending state

When both amounts are known at record time (a Wise-style quoted transfer, or any case where the user already knows the exact converted amount), `recordTransfer`/`recordTransaction` posts one complete entry immediately — two postings, each in its own currency — and never creates a `pending_transfers` row. This relaxes the "postings sum to zero" construction rule that same-currency entries rely on, but **only** for entries explicitly of this kind; the invariant continues to hold everywhere else, including same-currency transfers and both legs of a settled pending transfer (each of which is individually same-currency and balanced).

### 7. Foreign-currency income/expense transactions reuse the identical mechanism

Not just transfers: recording an expense or income against a financial account whose group currency differs from the transaction's native currency (e.g. a credit-card purchase made abroad) follows the same split as Decision 6/4 — a known-upfront rate posts as one entry, an unknown final amount posts provisional-then-settled.

The **category leg always posts immediately, in the transaction's native currency**, for the amount that's actually certain (e.g. "spent 50 EUR on Dining today") — categories aren't group-scoped and don't need single-currency consistency, so this leg never needs later adjustment. Only the **account leg** (which must match its group's currency) goes through the provisional/settlement machinery.

The provisional entry's transaction date — not the later settlement date — is what income/expense summaries key on, so a purchase made on one date counts toward that date's spending even if it settles days later. This matters for monthly reporting matching what the user actually expects to see.

## Risks / Trade-offs

- **[Risk] `pending_transfers` introduces stateful lifecycle into an otherwise append-only ledger** → Mitigation: `journal_entries` stay fully immutable throughout; `pending_transfers` only tracks which entries belong together and whether settlement has happened — never mutates or supersedes a posted entry the way the true-key-loss migration path does.
- **[Risk] Users forget to settle a pending transfer, leaving it open indefinitely** → Mitigation: no auto-expiry proposed (would be arbitrary); the Home overview's dedicated Pending Transfers section keeps it visible. Reminder/nudge UX is explicitly out of scope for this change.
- **[Risk] Relaxing "postings sum to zero" for cross-currency entries could be misread as a universal relaxation by a future maintainer** → Mitigation: scope it narrowly to entries explicitly flagged as cross-currency-known-upfront or a pending transfer's individual legs (each of which stays balanced on its own); document the exception prominently at the schema/entry-construction level, not only here.
- **[Risk] The clearing account, if ever queried like a normal account, produces a meaningless multi-currency sum** → Mitigation: Decision 3 — no single-balance query is exposed for it; the only supported view is the itemized `pending_transfers` list.
- **[Trade-off] No seeded default fee category** → Acceptable for v1; revisit if user friction shows up in practice.
- **[Trade-off] Manual settlement only, no FX data source ever** → Matches the user's explicit philosophy; the cost is the user must type the real settled amount every time rather than the app estimating it.

## Migration Plan

1. Hard dependency: ship only after `multi-account-support` archives — `account_groups` must exist first.
2. `schemaVersion` bump (next after `multi-account-support`'s; confirm the exact number once that change archives). Adds `account_groups.currency`, seeds the "Transfers in transit" system account (alongside the existing `equity` row and starter groups, in `confirmFirstIdentity` and the matching `onUpgrade` path), and adds `pending_transfers`.
3. Existing `account_groups` rows (created under `multi-account-support`, pre-dating this change) need a currency backfilled on upgrade. Proposed default: prompt the user once during the upgrade flow for a single currency applied to all existing groups (a real installation up to this point is presumably already single-currency) rather than guessing or requiring a per-group prompt — see Open Questions.
4. No journal rewrite required — existing entries are untouched; only newly-created cross-currency entries use the relaxed construction rule.
5. Rollback: forward-only schema, same discipline as prior changes (`ledger-integrity-signing`, `multi-account-support`).

## Open Questions

- Can an `account_group`'s currency be changed after creation? Proposed default: only if it currently has zero member accounts — mirrors the system-group-archiving rule already established in `multi-account-support`, and avoids retroactively reinterpreting historical balances in a different currency.
- Exact posting shape for a cross-currency-known-upfront single entry (Decision 6): does the posting row need a second amount+currency pair, or can each posting simply derive its currency from its own account's group (no new column needed)? Leaning toward the latter since currency is already derivable per-account; final call belongs in tasks.md / apply.
- Does a `pending_transfers` row of kind `foreignTransaction` ever need a `destination_account_id`, given transactions don't have a natural "to" account the way transfers do? Proposed default: leave it `NULL` for that kind; settlement simply asks "which account received the settled amount" with no planned value to compare against.
- Single-currency-prompt vs. per-group-prompt for the upgrade backfill (Migration Plan step 3) — proposed default is the single prompt; revisit if real users report existing multi-currency-in-one-group setups (shouldn't be possible under `multi-account-support`'s v1, since groups didn't have currency at all yet, but flagging the assumption).
