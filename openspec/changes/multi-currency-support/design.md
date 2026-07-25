## Context

`multi-account-support` (in progress, not yet implemented) introduces `account_groups`, extends `accounts` with `group_id`, adds `recordTransfer`, and adds a Home overview with a single blended net-position figure. It explicitly listed multi-currency as a non-goal and left a forward-reference note under its Decision 1 pointing at this change. `ledger-integrity-signing` (implemented) requires every journal write to go through the same signed, hash-chained path, and posted entries are immutable (Golden Rule #7) — corrections are new entries, never edits.

This design comes out of a direct exploration conversation with the user, not a research survey. The user's stated model, verbatim in spirit: no automatic currency conversion anywhere, ever; a group is single-currency; an account has no currency of its own beyond "which group it's in"; a transfer or foreign transaction whose final settled amount isn't known yet posts what's known now and gets completed manually later; when the rate/fee *is* known upfront (e.g. a Wise-style quoted transfer), it can post as one complete entry immediately.

## Goals / Non-Goals

**Goals:**
- Currency as a property of `account_groups`, not `accounts` — one group, one currency, always.
- Home overview net worth reported per-currency, never blended or converted.
- A same-currency transfer/transaction is unchanged from `multi-account-support`.
- A cross-currency movement with a known upfront rate posts as one complete entry.
- A cross-currency movement with an unknown final amount posts as a provisional entry now, settled manually later, through a system "Transfers-in-transit" clearing account.
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

**Interaction with `multi-account-support`'s existing group-reassignment feature.** `multi-account-support` already allows reassigning a financial account to a different group of the same kind (asset/liability), written before currency existed. Once a group has a currency, reassigning an account to a *different-currency* group would silently reinterpret its entire historical balance and postings in a new currency, which is meaningless — a $500 balance doesn't become €500 by relabeling its group. This change MUST restrict reassignment to same-currency groups only; see the accompanying delta spec against `multi-account-ledger`'s "Account Groups for Financial Accounts" requirement.

### 2. Home overview net worth becomes per-currency

Net position is computed once per currency present, `Σ asset display balances − Σ liability display balances` for all financial accounts in that currency (including archived, matching `multi-account-support`'s no-exclude-toggle rule for individual accounts). No conversion, no single blended number. This supersedes `multi-account-support`'s "Overall Net Position" requirement (see the accompanying delta spec against `accounts-home-overview`).

**A pending transfer's net-worth contribution follows the same quarantine/supersession exclusion as every other balance query.** `multi-account-support`'s design explicitly calls out that every balance/aggregate query must exclude entries where `entry_verification_cache.is_verified = 0` (a detected chain break) or that are migration-superseded — the same rule applies here: if a pending transfer's provisional entry is itself quarantined or superseded, its amount MUST be excluded from its currency's net position (and from the clearing account's implicit contribution to it), the same way it would be for a normal account balance. The pending transfer still appears in the Pending Transfers list for review — it just doesn't distort net worth, mirroring how a quarantined entry stays visible in a register without counting toward the balance.

**Alternative considered:** keep one blended figure using a fixed or periodically-updated conversion rate. Rejected — directly contradicts the user's stated model ("no convert and show balance in any other currency").

**Group totals and account balances must display their currency.** Once more than one currency can exist, an unlabeled figure ("Cash & cash equivalents: 500") is ambiguous. Every group total, account balance, and pending-transfer amount shown on the home overview or in a register must be labeled with its currency (code or symbol) — a small addition to `multi-account-support`'s existing "Group Totals for Assets and Liabilities" and "Per-Account Balance and Register" requirements, not a new behavior of its own.

### 3. System "Transfers-in-transit" clearing account

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

`category_id` and `destination_account_id` are conditionally required based on `kind` (SQLite has no portable CHECK for "exactly one of these two is set based on a sibling column" that's worth fighting for here); the Repository, not a SQL constraint, enforces that exactly the right one is populated for each `kind` when constructing the row — consistent with how this codebase already leans on Repository-level invariant enforcement over SQL-level constraints elsewhere (e.g. the settlement-closes-the-position invariant in Decision 5).

One row per transfer or foreign-currency transaction that couldn't post as a single complete entry (Decision 6 covers the case that can). `provisional_entry_id` is a normal immutable, signed, chained journal entry — no special-casing in the signing/chain path. Settlement adds up to two more immutable entries; it never edits the provisional entry, consistent with Golden Rule #7. `pending_transfers` itself is a lightweight index over which entries belong together and whether the second half has happened — not a ledger fact in its own right.

**A provisional entry cannot be reversed directly while its pending transfer is still pending.** `multi-account-support` already offers a general reversal action on any posted entry. Because a provisional entry is a normal signed entry, nothing stops a user from reversing it through that generic path — but doing so would leave `pending_transfers` pointing at a reversed entry while still reporting status `pending` and still counting the (now reversed) amount toward net worth, silently corrupting the Home overview. `settlePendingTransfer` (Decision 5) with `settledToAccountId` = the original source account and `settledAmountMinor` = the full provisional amount already produces the same economic outcome (money back where it started, no fee) through the one sanctioned closing path. The Repository must reject a direct reversal attempt on an entry that is still the open provisional leg of a pending transfer, with a message pointing the user at settlement instead. Once settled, the provisional entry (like any posted entry) can be reversed normally — that reopens no state, since a reversal is just a new, independent entry.

### 5. Settlement and cancellation are the same action

```
settlePendingTransfer({
  pendingTransferId,
  settledToAccountId,   // original destination (normal) OR the original source account (bounced/returned)
  settledAmountMinor,   // the real, known amount that actually arrived
  feeCategoryId,        // only valid, and required, when settling to the source account for less than the provisional amount
})
```

**The shortfall/fee comparison only applies when settling back to the source account — never when delivering to the destination.** This needs to be precise, because it's easy to state the general rule ("if settled amount < provisional amount, post a fee") in a way that silently assumes both amounts are in the same currency:
- **Settling to the original source account** (bounced/returned): `settledAmountMinor` is in the *same* currency as the provisional entry, so comparing it to the provisional amount is meaningful. If it's less, the shortfall auto-posts as a second balanced entry — debit the user-chosen expense category / credit clearing, both in the source currency — closing the remainder of the clearing position. If it's zero, only the fee entry posts (total loss).
- **Settling to the original destination** (normal delivery): `settledAmountMinor` is in the *destination* currency, which was never recorded as a promised figure in the first place — only the source-currency amount was ever "expected." There is nothing to compare it against, so no shortfall/fee logic applies here at all: whatever amount the user reports as received is simply posted, and that alone closes the pending transfer. A `feeCategoryId` supplied together with a destination settlement is rejected as a meaningless combination, not silently ignored.

Either way, the Repository enforces, as an invariant, that the settlement (and fee entry, when one applies) always closes the pending transfer; the user never has to reconcile that manually — "closes" means the `pending_transfers` row transitions to `settled` once its second entry is recorded, not that the differently-currencied legs numerically net to zero (they never will, and aren't meant to).

**Why not a separate `cancelPendingTransfer`?** A bounced transfer is structurally identical to a settlement — the money just lands back at the source account instead of the planned destination, for less than it left. Two methods would duplicate the same closing-invariant logic. `status` stays `pending | settled`; "delivered" vs. "returned" is a display-only distinction derived by comparing `settledToAccountId` to the original destination, not a separate state.

**`settledToAccountId` only offers a real choice for `kind = transfer`.** A transfer has two candidate accounts (the planned destination, or the source if it bounced). A `foreignTransaction` pending item has no equivalent "somewhere else it could have landed" — the card/account charged is fixed at record time, and settlement only ever finalizes the *amount* charged to that same `source_account_id`, using the same-currency shortfall/fee comparison described above (never the destination-delivery path, since a transaction has no destination). For `kind = foreignTransaction`, the Repository resolves `settledToAccountId` to `source_account_id` itself rather than accepting it as a caller-supplied parameter.

**Settlement input validation the Repository must enforce, beyond the happy path above:**
- `settledAmountMinor` MUST NOT be negative (zero is valid — total loss, only meaningful on the source-account path).
- A pending transfer that is already `settled` MUST NOT be settled again — reject with a clear "already settled" error rather than silently double-posting.
- `feeCategoryId`, when supplied, MUST reference an active Expense-type category — not an Income category, not a financial account, not the Transfers-in-transit account itself — and MUST only be supplied when settling back to the source account.
- On the source-account path, `settledAmountMinor` MUST NOT exceed the provisional amount. More coming back than was sent (a refund, goodwill credit, or favorable rate) isn't modeled as a "negative fee" — reject it, and let the user settle for exactly the provisional amount (closing the pending transfer cleanly) and record any extra as an ordinary income transaction on the source account afterward, through the existing `recordTransaction` path. This has no equivalent restriction on the destination-account path, since there both the "provisional" and "settled" amounts are only ever compared within their own currency, never against each other.
- `settledToAccountId`, on the transfer path, MUST be either the pending transfer's own `source_account_id` or `destination_account_id` — no third account. Settlement does not need the account to still be *active*: a pending transfer initiated against an account that has since been archived can still be settled normally, since settlement is a normal signed entry, not a new recording action gated the way `recordTransfer`/`recordTransaction` are.

**Alternative considered:** a seeded default "Transfer fees" expense category, forced for the fee leg. Rejected for v1 — the user picks any expense category at settlement time, same as any other expense; a seeded default can be added later without a migration if it proves to be friction.

### 6. Cross-currency, rate-known-upfront: single entry, no pending state

When both amounts are known at record time (a Wise-style quoted transfer, or any case where the user already knows the exact converted amount), `recordTransfer`/`recordTransaction` posts one complete entry immediately — two postings, each in its own currency — and never creates a `pending_transfers` row. This relaxes the "postings sum to zero" construction rule that same-currency entries rely on, but **only** for entries explicitly of this kind; the invariant continues to hold everywhere else, including same-currency transfers and both legs of a settled pending transfer (each of which is individually same-currency and balanced). Both the source-currency and destination-currency amounts MUST be positive — the existing "non-positive amount is rejected" rule extends to the destination-currency amount here too, not just the source-currency one.

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
2. `schemaVersion` bump (next after `multi-account-support`'s; confirm the exact number once that change archives). Adds `account_groups.currency`, seeds the "Transfers-in-transit" system account (alongside the existing `equity` row and starter groups, in `confirmFirstIdentity` and the matching `onUpgrade` path), and adds `pending_transfers`.
3. Existing `account_groups` rows (created under `multi-account-support`, pre-dating this change) need a currency backfilled on upgrade. Proposed default: prompt the user once during the upgrade flow for a single currency applied to all existing groups (a real installation up to this point is presumably already single-currency) rather than guessing or requiring a per-group prompt — see Open Questions.
4. No journal rewrite required — existing entries are untouched; only newly-created cross-currency entries use the relaxed construction rule.
5. Rollback: forward-only schema, same discipline as prior changes (`ledger-integrity-signing`, `multi-account-support`).

## Open Questions

- Can an `account_group`'s currency be changed after creation? Proposed default: only if it currently has zero active member accounts — this is a new rule specific to currency (not analogous to any existing group-archiving rule; `multi-account-support`'s system groups are never archived at all), justified purely by avoiding retroactively reinterpreting historical balances in a different currency.
- Exact posting shape for a cross-currency-known-upfront single entry (Decision 6): does the posting row need a second amount+currency pair, or can each posting simply derive its currency from its own account's group (no new column needed)? Leaning toward the latter since currency is already derivable per-account; final call belongs in tasks.md / apply.
- Does a `pending_transfers` row of kind `foreignTransaction` ever need a `destination_account_id`, given transactions don't have a natural "to" account the way transfers do? Proposed default: leave it `NULL` for that kind; settlement simply asks "which account received the settled amount" with no planned value to compare against.
- Single-currency-prompt vs. per-group-prompt for the upgrade backfill (Migration Plan step 3) — proposed default is the single prompt; revisit if real users report existing multi-currency-in-one-group setups (shouldn't be possible under `multi-account-support`'s v1, since groups didn't have currency at all yet, but flagging the assumption).
