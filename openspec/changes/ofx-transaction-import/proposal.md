## Why

Users who bank or use cards with institutions that export OFX/QFX statement files currently have no way to bring that history into the ledger except typing every transaction in by hand. An import module removes that friction and is the natural on-ramp for anyone migrating from another finance tool or reconciling a period of missed manual entry.

## What Changes

- Add an OFX (Open Financial Exchange, `.ofx`/`.qfx`) file parser that reads bank (`STMTTRN`) and credit-card (`CCSTMTTRN`) statement transactions: date, amount, memo/payee, and the bank's own transaction id (`FITID`).
- Add an import flow: pick a file → parse it → match it to one existing financial account (by currency; the user confirms or picks the account) → preview the parsed transactions → assign a category to each (or accept a suggested/default one) → post the selected transactions.
- Add duplicate detection: transactions whose `FITID` was already imported before are flagged and excluded from posting by default; the user can still force-include a flagged row. Records only OFX-import metadata for de-duplication — never mutates the append-only, signed journal entries table.
- Preview screen lets the user deselect individual rows, edit the category per row, and see running totals before anything posts.
- Each accepted row posts through the existing `recordTransaction` / `recordTransfer` repository calls (one journal entry per row) — no changes to how entries are posted or signed.
- Out of scope for this change: OFX investment transactions (`INVSTMTTRN`), automatic bank connectivity/downloading (file must be supplied by the user), and IFX (Interactive Financial Exchange) — a different, unrelated standard.

## Capabilities

### New Capabilities
- `ofx-transaction-import`: parsing OFX/QFX files, matching parsed transactions to a financial account, previewing/editing/categorizing rows, duplicate detection against prior imports, and posting accepted rows as ordinary journal entries.

### Modified Capabilities
(none — import posts through the existing `recordTransaction`/`recordTransfer` requirements in `multi-account-ledger` and `core-ledger-single-account` unchanged)

## Impact

- New Dart package dependency for XML/SGML parsing (OFX 1.x is SGML-like, OFX 2.x is XML; needs a parser tolerant of both).
- New Drift table for import de-duplication metadata (bank FITID → posted journal entry, per financial account), additive migration only — the existing `journal_entries` table and its signing/hash chain are untouched.
- New repository methods on top of `LedgerRepository` (or a sibling `OfxImportRepository`) for parse-and-preview and for posting a reviewed batch.
- New UI: file picker entry point, import preview/review screen, per-row category picker, duplicate-flag indicator.
