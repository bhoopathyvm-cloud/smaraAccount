## Why

The project needs a working accounting core before any device sync, multi-account, or business-feature work begins. Earlier exploration (see `Specs/IntialThoughts.md`) jumped straight to sync protocols, hub architecture, and tech-stack choices before the basic bookkeeping requirement was ever pinned down. This change scopes the smallest complete slice: a single user, on a single device, recording double-entry transactions against one financial account — no networking, no multi-account, no business features.

## What Changes

- Introduce a chart of accounts with a small starter set of Income/Expense categories (renameable, extendable, archivable).
- Introduce one financial account (e.g. a bank account) that the user records money in/out against.
- Recording a transaction captures a transaction date, amount, direction, and category from the user; a recorded-at timestamp is captured automatically by the system (not user-entered). The system produces a balanced double-entry journal entry underneath (user is never asked to pick debit/credit sides directly).
- Posted journal entries are strictly immutable — no edit, no delete. A correction is made by posting a reversing entry as one ordinary action; entering the corrected transaction (if needed) is a separate, independent ordinary transaction — not a single guided/combined flow. The original stays visible.
- Archiving a category removes it from pickers for new entries; it remains visible, in read-only form, on historical entries and summaries that already reference it.
- Provide a chronological transaction register for the account with a running balance.
- Provide an income-vs-expense summary total for a user-selected date range.

## Capabilities

### New Capabilities
- `core-ledger-single-account`: double-entry journal, chart of accounts (starter categories), transaction recording, immutability/correction model, register view, income-vs-expense summary — all scoped to one account on one device, no sync.

### Modified Capabilities
- (none — first change in the project)

## Impact

- Establishes the foundational domain model (accounts, categories, journal entries, postings) that later changes (`multi-account-support`, `lan-device-discovery-pairing`, `lan-sync`, `receipts-attachments`) will build on without needing to reshape it.
- No sync, networking, multi-user, tax, receipt, or period-closing behavior is introduced here — explicitly deferred to later changes.
