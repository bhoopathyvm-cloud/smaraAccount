# SMARA Account

Household and small-business books on one or more Linked devices: a
signed, double-entry ledger under the hood, surfaced to the user as a
plain record of what they spent and received. History never quietly
rewrites itself — corrections are new entries, not edits. Devices that
share the same books catch up over the same Wi-Fi (Peer Sync) with no
server. See `docs/household-term-map.md` for the mapping from the ledger
vocabulary below to the household words the UI actually shows.

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

**Archive**:
Marking an Account, Category, or Account Group so it accepts no new entries
and drops out of pickers, while its existing history stays intact and
counted. Never a deletion (household wording: "Hide from new entries").
_Avoid_: delete, remove, close (archiving hides going forward; it keeps the
past).

**Closeout**:
Moving an archived Financial Account's remaining balance out to another
account via a Transfer, so the hidden account reads zero. A same-currency
closeout moves the full balance; a cross-currency one records a known
destination amount (see Settlement). For an Investment Account the cash
closeout is repeatable — a late dividend or sell can leave residual cash to
sweep again.
_Avoid_: withdrawal, payout (a closeout is an internal Transfer between the
user's own accounts, not money leaving the books).

**Opening Balance**:
The starting amount a Financial Account is created with, recorded as a real
Journal Entry whose counter-leg posts against the Opening Balance Equity
system Account — never an income Category, since it is money the user
already had rather than new income (posting it to income would inflate the
income/expense summary). An opening-balance entry is not a single-Category
ordinary transaction, so it is not fixable through the Correction flow.
_Avoid_: initial deposit, starting income (it is equity, not a
transaction with an outside party).

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
Chain from genesis again. Continuation keeps the existing chain tip (or
trusted tip) and does not rewrite history.

**Device Chain Sequence**:
The unique, monotonic per-device counter (`deviceChainSequence`) stamped on
every Journal Entry, which orders the Chain. It continues across a Migration
rather than resetting — only the hash chain returns to Genesis; the counter
never reuses a number.
_Avoid_: index, row number (it is device-wide and never reset, unlike a
per-Chain position).

**Integrity Event**:
An append-only audit-log row recording a chain break, re-anchor,
Continuation, or (historically) key migration. Distinct from a Journal
Entry — it records something that happened to the ledger's trust chain,
never a movement of money.

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

**Books Copy**:
A passphrase-encrypted file of the complete books (ledger database plus
books settings such as reference rates) — never the private signing key,
and never device settings (language, App Lock, reminder state, research
tool). Saving and restoring is how books move between phones or are
backed up. Restoring always replaces this phone's books; it does not
merge.
_Avoid_: snapshot, bundle, sync file, ledger backup (retired name).

**Restore** (from a Books Copy):
Replacing this phone's books with a saved Books Copy (from first launch
or Settings). After a successful restore this phone Continues under its
own new Signing Identity. Later entries made on the other device do not
appear here; bringing them over means saving a new copy there and
restoring it here (which replaces again).
_Avoid_: sync, merge, import key, adoption, pairing, transfer.

**Continuation**:
Starting a new this-device-only Signing Identity that continues earlier
books when this phone holds books without a matching private key (for
example after a keychain reset, or after restoring a Books Copy). Earlier
entries keep verifying under their original identities; new entries are
signed by the new identity. Recorded as an `IDENTITY_CONTINUED` Integrity
Event and shown in Device history.
_Avoid_: migration, adoption, pairing, transfer, re-sign history.

**Migration** (historical key migration):
Earlier versions could re-create a Signing Identity's entries under a new
identity after true key loss. Entries superseded by that process
(`isSupersededByMigration`) still verify and remain visible, but are
excluded from active balances. New key loss uses Continuation instead —
history is not rewritten.
_Avoid_: using Migration for current Continuations or Books Copy restore.

### Linked devices & books sets

**Linked Device**:
A phone, tablet, or computer that is a member of the same books. Each
Linked Device keeps its own Signing Identity and signs only the entries it
records; Peer Sync *adds* the others' signed records and never edits them.
_Avoid_: paired device, synced account, shared login, multi-user account,
cloud member.

**Peer Sync**:
Catching up Linked Devices over the same Wi-Fi — discovery and transfer
stay on the local network, device to device, with no server, cloud, or
relay. Runs when both apps are open on that Wi-Fi, and when someone taps
Sync now.
_Avoid_: cloud sync, internet sync, relay, push sync, background server.

**Owner**:
A Linked Device role that may add and remove devices or people, decide who
may add others, erase a removed device, and make other devices Owners.
_Avoid_: admin, superuser, account holder (Owner is a device role on these
books, not a cloud login).

**Member**:
A Linked Device role that records and Fixes entries and manages categories,
but does not perform Owner-only membership actions unless the Owner has
granted that device permission to add others.
_Avoid_: user, guest, collaborator (prefer Member).

**Books Set**:
One fully separate set of books on a device (its own database file, Signing
Identity key material, Linked Devices, and Books Copies). The books
switcher lists sets by a user-visible name (for example "My household" and
"Acme Ltd – travel") and switches which set Home, Register, and Linked
devices refer to.
_Avoid_: workspace, tenant, profile, multi-account (a Books Set is separate
books, not a login profile).

### App lock

**App Lock**:
The optional PIN gate on app entry. The PIN hash is stored in the same OS
secure storage as signing keys (ADR 0001), and verification runs off the UI
isolate (PBKDF2) via `AppLockService` — never an acceptance-only in-memory
bypass.
_Avoid_: password, passcode screen (the domain concept is the lock; the PIN
is the credential it checks).

**Lock Session**:
The single session-policy module that decides whether the app is currently
locked, whether a timeout after backgrounding requires relock, and whether
snapshot hiding applies. The router's redirects and the lock screen read
this module rather than re-deriving policy from ad hoc settings reads.
_Avoid_: login, auth session (there is no account or server sign-in — this
is a local device gate).

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
A cached last price for one Instrument, sourced from a Quote Provider
(Stooq or Yahoo Finance), with its currency — reported by the provider or,
for Stooq, inferred from the market-symbol suffix (`.ch` → CHF). A quote
whose currency differs from the account's is unusable (shown as "price
currency differs"), and the holding falls back to cost. Never posted to
the journal — used only to compute Market Value.

**Exchange** (Default Exchange):
One entry in a fixed, code-defined registry of stock exchanges (name,
market identifier, market-symbol suffix, trading currency). The Default
Exchange setting biases which listing a new Instrument resolves to; no
custom exchange, endpoint, or API key can be added.

**Listing** (listing confirmation):
One market listing of an Instrument (exchange + currency + canonical
market symbol). When an Instrument is saved online, one identifier search
returns candidate Listings and the user confirms one (the Default
Exchange's is pre-selected); offline, resolution is retried on the next
quote refresh. The confirmed Listing's currency is what Quotes must match.
_Avoid_: ticker (the user-typed identifier; the Listing's market symbol
may differ, e.g. `UBSG.SW`).

**Research Tool**:
One of the predefined consumer AI assistants (ChatGPT, Claude, Gemini,
Meta AI) the user can pick as a favourite to research an Instrument, and
to look up an Instrument's identifiers (ISIN, exchange, ticker, currency)
from the Add-instrument form using only the typed name. No API key and no
custom URL — each tool has at most a public `?q=` query-URL template;
tools without one are copy-only.
_Avoid_: AI provider, API, integration (nothing is called server-side —
see Investment Research Prompt).

**Investment Research Prompt**:
The packed text handed to the selected Research Tool, built from an
Instrument's identifiers **only** — name, ticker, ISIN — and never its
quantity, cost, or owning account. Delivered by opening the tool's query
URL externally, or copied to the clipboard when the tool has no query URL
or the launch fails. The identifiers-only rule is the privacy boundary
between the on-device ledger and any third-party assistant.
_Avoid_: export, sync (the app hands off a prompt; it never uploads
holdings).

### Statement import

**Statement Import**:
The wizard that brings external bank-statement rows into the ledger as
ordinary Journal Entries. One shared review/posting pipeline behind two
sources (`StatementSource`): OFX (parsed immediately) and CSV (which needs
a column-mapping step first). Rows are account-selected, categorized,
duplicate-checked, and only the accepted ones post.
_Avoid_: sync, bank feed (import is a one-shot file the user picks, not a
live connection).

**Category Rule**:
A saved keyword→Category mapping that auto-suggests a Category for imported
rows whose description matches, so the same payee need not be re-tagged on
every import. Optionally paired with a Payee.

**Import Profile** (CSV Import Profile):
A saved CSV column mapping — which columns hold the date, description, and
amount, plus the amount convention, decimal separator, and currency —
matched to a statement by its header-row fingerprint so a recognized layout
pre-fills the mapping step. CSV-only; OFX carries its own structure and
needs no profile.
_Avoid_: template (that word is taken by Recurring Template).

### Onboarding

**Setup Choice**:
The first-launch screen, shown before any Signing Identity exists:
**New setup** (ordinary onboarding) or **Restore from a copy** (restore a
Books Copy and land in verified books, continued under this phone's own
new key).

**Onboarding** (New setup):
Language (mandatory pick, device language pre-highlighted) → base
currency → name the main Financial Account → record the guided First
Entry, then straight into the app. The Signing Identity is generated
silently for this device only; there is no recovery-phrase or keystore
step.

**Deferred Onboarding** (historical):
The earlier flow that let a new user record a First Entry *before* a
mandatory recovery-phrase acknowledgment. Superseded: the signing key
never leaves the device, and onboarding has no phrase step. The term
survives only in the `deferred-onboarding` spec name.
_Avoid_: using it for current onboarding (say Onboarding).

**First Entry**:
The very first transaction a new user records, during Onboarding.
Distinct from Genesis, which is the first *Journal Entry's* previous-hash
root: the First Entry is the user-facing "record your first Spent or
Received", the genesis entry is its ledger representation.

**First-Week Setup**:
A short post-onboarding wizard that guides a new user to name their main
Financial Account and optionally add a credit card and a cash account, each
created through the existing account-creation path with no new validation.
Distinct from Onboarding, which it follows.

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
