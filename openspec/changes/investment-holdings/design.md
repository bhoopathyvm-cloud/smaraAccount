## Context

See proposal.md for why. Today every user-facing financial account is `asset` or `liability`. Pickers allowlist those two types so equity/clearing stay hidden. Pension & retirement is a *group*, not a holdings register. Journal entries are signed and immutable; anything that changes "what I own" in money terms must go through `_appendSignedEntry`. The only existing network feature is opt-in FX lookup. This change stays offline.

The hard accounting problem is double-counting: if a transfer of cost into a brokerage account *and* a marked holding value both enter net worth, the same money is counted twice. v1 keeps the signed ledger as net-worth truth and treats marks as labels.

## Goals / Non-Goals

**Goals:**
- Investment-flagged asset accounts with a holdings schedule.
- Acquire/dispose as user-recorded facts that post through the existing signed transfer / multi-leg write path.
- User-typed display marks that never post.
- A seeded Investments system group, without forcing every investment account into it.

**Non-Goals:**
- Share dealing, broker APIs, live quotes, corporate actions.
- AI/news research (`investment-research-briefs`).
- Mixing marked values into home net position.
- Un-archiving instruments or accounts.
- Changing how ordinary income/expense or transfers work on the investment account (dividends and contributions stay those flows).

## Decisions

### 1. Flag on an asset, not a new `AccountType`
Add an immutable `holdsInvestments` (or equivalent) boolean on `accounts`, allowed only when `type == asset`. A new `AccountType.investment` would require every `type IN (asset, liability)` picker and balance query to be rewritten and would blur "is this a financial account?" A flag keeps investment accounts inside the existing asset path (transfers, archive, home, currency-from-group).

**Alternative considered:** one financial account per instrument. Rejected — a brokerage wrapper is one account with many positions; exploding accounts would wreck the home overview.

### 2. Holdings are a schedule; money movement is the journal
Tables: `instruments` (id, name, kind enum, ticker, isin, archived_at) and `holdings` (investment_account_id, instrument_id, quantity_scaled, cost_minor, optional mark_price_minor, last acquire/dispose entry ids). Quantity is a fixed-scale integer (8 decimal places) so we never store a float. Cost is minor units in the investment account's group currency.

Acquire: call the existing transfer posting path (same-currency or known-rate / provisional cross-currency) from funding → investment for `cost`, then insert/increase the holding in the same Drift transaction as the journal write so a failed sign does not leave an orphan lot.

Dispose: one new repository method that posts a balanced entry:
- destination `+proceeds`
- investment account `-costRemoved` (average cost × qty disposed / qty held)
- if proceeds > costRemoved: income category `-(proceeds-costRemoved)`
- if proceeds < costRemoved: expense category `+(costRemoved-proceeds)`
Zero proceeds is a write-off (full cost to expense). Then reduce/delete the holding row.

**Alternative considered:** marks as journal revaluations. Rejected — that would mint unsigned "income" every time the user types a price and fight the immutability story.

### 3. Average cost, not specific identification
v1 uses average cost on dispose. Specific lots (FIFO/LIFO) are a later change if tax lots are ever specified.

### 4. Seed Investments as a fifth system group
Stable id `group_investments`, asset kind, sort order between Pension and Credit. Migration adds the row; existing databases keep their four groups and gain this one. Users may still assign an investment account to Pension & retirement (a 401k/ISA wrapper) or a custom group. The flag, not the group, gates holdings.

### 5. Net position stays ledger-only
Home may show "marked est. …" as muted secondary text on an investment account. `watchHomeOverview` totals do not add marks. Same philosophy as "no FX blend."

### 6. No quote fetch in this change
A future opt-in quote lookup could follow the FX pattern. It is not in this design so holdings work fully offline.

## Risks / Trade-offs

- [Risk] User funds an acquire from the investment account itself (same-account). → Mitigation: reject; funding account must be distinct, same as transfers.
- [Risk] Holding cost sum drifts from the investment account's ledger (partial history, old lump-sum opening balance). → Mitigation: allowed; show both book (ledger) and schedule cost on the holdings view; do not auto-rewrite the ledger.
- [Risk] Cross-currency acquire inherits provisional settlement. → Mitigation: reuse existing transfer rules; the holding cost is the source-currency cost the user entered; do not invent an FX mark.
- [Risk] Fifth system group surprises existing users. → Mitigation: empty groups stay de-emphasized on home until an account is assigned.

## Migration Plan

Additive schema version: new columns/tables + insert Investments system group on upgrade (shape only, no journal backfill). Rollback is revert; unused tables are harmless if we never ship a downgrade.

## Open Questions

None that block apply. Specific-lot costing and opt-in quotes are later changes if wanted.
