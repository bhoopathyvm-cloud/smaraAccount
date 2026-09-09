# SMARA Account

Household books on one device: a signed, double-entry ledger under the
hood, surfaced to the user as a plain record of what they spent and
received. History never quietly rewrites itself — corrections are new
entries, not edits. See `docs/household-term-map.md` for the mapping from
the ledger vocabulary below to the household words the UI actually shows.

## Language

### Ledger core

**Journal Entry**:
A posted, immutable double-entry entry with **two or more** Postings whose
amounts sum to zero. An ordinary transaction or transfer has two; a Split
has three or more (one Financial Account leg plus one leg per Category).
Once posted, no code path updates or deletes it (Golden Rule #7) — a
correction is a new entry that references the original via `reversesEntryId`.
_Avoid_: Transaction (the household-facing term for this same concept —
used only in UI copy and feature/flow naming like `record_transaction`,
never in domain code), Entry alone.

**Posting**:
One leg of a Journal Entry: a signed amount against one Account. Every
entry has **at least two**, and they always sum to zero — that balance (not
the count) is what makes the ledger double-entry instead of a plain list of
amounts.
_Avoid_: debit, credit, line item.

**Split**:
A single Journal Entry recording one transaction divided across two or more
Categories: one Financial Account leg plus one Posting per Category, still
summing to zero. A Split is not fixable through the Correction flow (only an
ordinary single-Category transaction is) — changing one means reversing the
whole entry and re-recording.
_Avoid_: multi-entry, split transactions as separate entries (a Split is
*one* entry with many legs, not several entries).

**Reversal**:
A Journal Entry that cancels a prior one by referencing it via
`reversesEntryId`, leaving the original row untouched. This is the ledger
mechanism behind the **Correction** flow (household word: "Fix") — the
user never edits an old entry, they add a reversal plus a corrected entry.
_Avoid_: edit, delete, undo (none of these happen to a posted entry).

### Accounts

**Account**:
A row in the chart of accounts. Every Account has a type: a Financial
Account (asset/liability), a Category (income/expense), or a
never-user-facing system row (equity, clearing, inventory). Not every
Account is shown to the user as an "account" — see Financial Account and
Category below.
_Avoid_: using "account" alone when you mean specifically a Financial
Account or a Category — the umbrella term hides which allowlist applies.

**Financial Account**:
An Account of type asset or liability — the kind a user thinks of as "an
account" (checking, credit card, brokerage). Managed through
`AccountRepository`.
_Avoid_: Account (too broad — also covers Categories and system rows).

**Category**:
An Account of type income or expense, used to classify what a Financial
Account transaction was for. Same underlying `accounts` table and domain
class as a Financial Account, but managed through the separate
`CategoryRepository`, which allowlists to income/expense only.
_Avoid_: Account (too broad).

**Account Group**:
A user-organized rollup of Financial Accounts sharing one ISO 4217
currency (an asset group or a liability group), shown as a section on
Home. Distinct from Account Type, which is per-account, not per-group.

**Investment Account**:
A Financial Account with `holdsInvestments` set — it can hold Instrument
Holdings in addition to cash.

**Investment Inventory Account**:
A never-user-facing Account of type `inventory`, paired one-to-one with an
Investment Account (`investmentOwnerAccountId`), used to keep holdings
on-ledger as an asset without exposing that internal posting leg in any
financial-account picker.

**Clearing Account**:
A never-user-facing system Account used as the counter-leg for
cross-currency settlement. A distinct Account type of its own (not a
relabeled asset/liability), so type-based pickers exclude it automatically.

### Corrections & integrity

**Signing Identity**:
The device's current or superseded key pair (public half only ever
stored) used to sign Journal Entries. A device may have more than one
over its lifetime after a key migration.
_Avoid_: key, device key — "Signing Identity" is the row/entity; "key"
refers to the raw key material within it.

**Chain**:
The sequence of Journal Entries signed by one Signing Identity, ordered by
`deviceChainSequence`, each entry's hash linking to the one before it.
Verifying an entry means walking this chain.

**Trusted Tip**:
The Journal Entry the app currently trusts as the head of the Chain — the
entry a new one chains onto. Held in the singleton chain-state row
(`trustedTipEntryId` / `trustedTipHash`). After a break it is the last
entry verified before the break point (see Re-anchor), not the compromised
tip.
_Avoid_: head, latest entry (the latest stored entry may be quarantined and
therefore not the trusted tip).

**Genesis**:
The root of a Chain: the well-defined 32-zero-byte previous-hash
(`genesisPreviousEntryHash`) that the Chain's first entry links back to. A
key Migration establishes a fresh trust root by starting the new identity's
Chain from genesis again.

**Device Chain Sequence**:
The unique, monotonic per-device counter (`deviceChainSequence`) stamped on
every Journal Entry, which orders the Chain. It continues across a Migration
rather than resetting — only the hash chain returns to Genesis; the counter
never reuses a number.
_Avoid_: index, row number (it is device-wide and never reset, unlike a
per-Chain position).

**Integrity Event**:
An append-only audit-log row recording a chain break, re-anchor, or key
migration. Distinct from a Journal Entry — it records something that
happened to the ledger's trust chain, never a movement of money.

**Verification**:
The derived, re-checkable judgment of whether a Journal Entry's hash,
signature, and chain link still hold. Not part of the entry's immutable
identity — it can change across app restarts as the chain is re-walked,
unlike every other field on the entry.

**Quarantine**:
The state of the break-point Journal Entry and every entry chained after
it once a chain break is detected: excluded from all balance and summary
calculations, yet kept **visible** in the register (error treatment — red
border + lock icon), never deleted or hidden. Quarantine is not reversible
by the app — a user who confirms a quarantined entry was legitimate
re-records it as a new entry on the current trusted tip; the original row
stays untrusted. Distinct from a migration-superseded entry, which is not
unverifiable, only historical (see Migration).
_Avoid_: delete, hide, remove (none happen to a quarantined entry — it
stays on the ledger, just uncounted).

**Re-anchor** (re-anchoring):
The recovery that resumes the ledger after a break without a key change:
the next new Journal Entry chains onto the last entry verified *before* the
break point (the trusted tip) rather than the compromised tip, and a
`chainReanchored` Integrity Event records the break and re-anchor point. The
quarantined tail is left behind, not repaired. Distinct from Migration,
which re-creates a whole chain under a new Signing Identity — re-anchoring
keeps the same identity and only steps around the damaged tail.
_Avoid_: repair, restore, heal (re-anchoring abandons the broken tail, it
does not fix it).

**Migration** (key migration):
The process of re-creating a Signing Identity's entries under a new
identity after true key loss. A migrated entry is marked
`isSupersededByMigration` and excluded from active balances, but remains
visible in history.
_Avoid_: Reversal (migration replaces an identity's whole chain;
Reversal cancels one entry).

### Transfers & currency

**Transfer**:
A movement of money between two Financial Accounts (household word:
"Moved money"). Same-currency transfers post directly; cross-currency
ones go through a Pending Transfer.

**Pending Transfer**:
An outstanding provisional entry awaiting settlement — either a Transfer
between accounts of different currencies, or the account-currency leg of
a foreign-currency income/expense transaction. Two kinds
(`PendingTransferKind`), one lifecycle: `pending` → `settled`.
_Avoid_: in-flight transaction, unsettled entry.

**Settlement**:
Closing out a Pending Transfer: either the funds are delivered to the
destination, or returned to the source with any shortfall posted as a
fee.

**Net Position**:
Total assets minus total liabilities, computed and shown **per currency**
— currencies are never combined or converted into one blended figure.

**Book Value** vs **Market Value**:
Book Value is cash plus inventory carried at cost. Market Value marks
holdings to their last usable quote. An Investment Account's display
balance is the market estimate when a usable quote exists, falling back
to book value otherwise (`isMarketEstimate` flags which one is shown).

### Investments

**Instrument**:
A tradeable security definition (stock, ETF, mutual fund, bond, etc.) —
not tied to any one account.

**Investment Lot**:
One acquisition of a quantity of an Instrument in one Investment Account,
at a recorded unit cost, sourced either from a cash purchase or a
non-cash acquisition. Lots are the ledger-level record; Instrument
Holding is derived from them.
_Avoid_: Holding, position (see Instrument Holding — a Lot is the atomic
record, a Holding is the computed rollup).

**Instrument Holding**:
The computed current holding of one Instrument in one Investment Account,
derived by replaying its Lots (and any sells) in transaction-date order.
Not stored directly — always a projection.

**Quote**:
A cached last price for one Instrument, sourced from a Quote Provider.
Never posted to the journal — used only to compute Market Value.

### Recurring & payees

**Recurring Template**:
A user-defined monthly bill/income pattern (day of month, account,
category, amount) the user records with one tap when due. Never posts
automatically — a template, not a scheduled transaction.
_Avoid_: scheduled transaction, standing order (implies automatic
posting, which this deliberately isn't).

**Payee**:
A remembered counterparty name with optional default category and
Financial Account, both of which double as "last used" — updated after
every transaction recorded under that name.
