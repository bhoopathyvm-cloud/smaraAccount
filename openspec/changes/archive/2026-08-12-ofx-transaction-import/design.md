## Context

The ledger's transaction posting path is `LedgerRepository.recordTransaction` / `recordTransfer` (`lib/data/repositories/ledger_repository.dart`), which validates inputs and appends a signed, hash-chained row to the append-only `journal_entries` table (`ledger-integrity-signing` capability). Nothing in the current codebase parses external files or tracks an external transaction id. OFX comes in two wire formats from the same logical schema:

- **OFX 1.x**: SGML-like — tags may be unclosed (`<TRNAMT>12.34` with no `</TRNAMT>`), header is a flat key:value block before the body, not XML-valid.
- **OFX 2.x**: well-formed XML with an XML declaration, same element names/structure as 1.x.

Both carry a `CURDEF` (statement currency) and, per transaction, a `FITID` — the bank's own stable id for that transaction, which is the standard way OFX-consuming software de-duplicates re-imports of overlapping date ranges.

## Goals / Non-Goals

**Goals:**
- Parse both OFX 1.x and 2.x bank/credit-card statement transactions into a normalized in-memory model.
- Let the user review, edit, categorize, and selectively accept parsed transactions before anything posts.
- Prevent re-importing the same bank transaction twice, per financial account, using `FITID`.
- Post accepted rows through the existing, unmodified `recordTransaction`/`recordTransfer` calls so every import-created entry is an ordinary, correctly signed journal entry indistinguishable in the ledger core from a manually entered one.

**Non-Goals:**
- Investment transactions (`INVSTMTTRN`/`INVBANKTRN`) — statement-only (`STMTTRN`/`CCSTMTTRN`) for this change.
- Automatic bank connectivity (OFX DirectConnect/AggAPI) — file import only.
- IFX (Interactive Financial Exchange) — unrelated standard, not covered.
- Automatic categorization/ML suggestion beyond a simple "remember last category used for this payee string" convenience — full rules-based auto-categorization is a candidate for a later change.
- Multi-account statements in one file that span more than one currency — the importer requires the whole file to match one financial account's currency (see Decisions).

## Decisions

**1. Parsing: `xml` package for OFX 2.x, plus a small tolerant pre-pass for OFX 1.x SGML.**
OFX 1.x's unclosed tags aren't valid XML. Rather than pull in a full SGML parser dependency, pre-process 1.x input with a line-based pass that auto-closes known leaf tags (`<FITID>...` → `<FITID>...</FITID>`) before handing the result to the `xml` package, which then parses both formats through one code path. Alternative considered: a hand-rolled line/regex tokenizer for the whole document — rejected because it'd duplicate what a real XML parser already does well for the (already well-formed) 2.x case and for the aggregate/statement-wrapper structure common to both.

**2. De-duplication: separate `ofx_import_records` table, not a column on `journal_entries`.**
`journal_entries` is append-only and every row is part of a signed hash chain (`ledger-integrity-signing`); adding an import-specific column there would mean every future non-import entry carries a meaningless null column, and would entangle this change with the signing/migration machinery. Instead, add one new additive table: `ofx_import_records(id, financial_account_id, fitid, journal_entry_id, imported_at)` with a unique index on `(financial_account_id, fitid)`. A row here is written in the same local transaction as the `journal_entries` insert it corresponds to, but the signed table itself is untouched by this change. Alternative considered: hashing (date, amount, memo) as a fuzzy dedupe key when `FITID` is absent — kept as a fallback (see below) but `FITID` is authoritative when present, since OFX guarantees it's stable per bank per account.
- Fallback when `FITID` is missing or blank (some smaller institutions omit it): fall back to a composite key of `(financial_account_id, transaction_date, amount, memo)`. Flagged as "possible duplicate" rather than silently skipped, so the user decides.

**3. Currency handling: require the file to match the target account's currency.**
`multi-account-ledger`'s existing "Record Transaction Against a Selected Financial Account" requirement already defines what happens when a transaction's native currency differs from the account's group currency (immediate foreign-currency posting or a provisional entry). Reusing that path unmodified is simplest and keeps this change from having to invent new cross-currency import semantics; a mismatched `CURDEF` is surfaced to the user as a warning, not a hard block, since the underlying recordTransaction call already handles it correctly either way.

**4. Account matching is manual, not automatic.**
OFX's `<ACCTID>`/`<BANKID>` don't reliably map to any identifier this app already stores (accounts here are user-named, not bank-linked). Rather than attempt fragile automatic matching, the import flow always asks the user to pick which existing financial account the file's transactions apply to, defaulting to the account currently in view if the import was launched from a register (mirroring the existing register→transfer pre-selection pattern in `multi-account-ledger`).

**5. Posting granularity: one `recordTransaction`/`recordTransfer` call per accepted row, sequential.**
No new bulk-posting primitive is added to `LedgerRepository`. Each accepted row becomes one ordinary call, so failures are isolated per-row (one bad row doesn't roll back the batch) and every posted entry gets its own correct `deviceChainSequence`/hash link exactly as if entered by hand. The preview screen surfaces per-row success/failure after posting completes.

**6. Category assignment is required before posting, no "uncategorized" bucket.**
Consistent with the existing manual-entry flow, which always requires a category. The preview screen pre-fills a per-row suggestion (last category used for an exact-memo match in this account, if any) that the user can accept or change; rows without a category selected are excluded from the postable set rather than blocked entirely, so the user can post the rest of the batch immediately and finish categorizing stragglers later via a saved partial import.

## Risks / Trade-offs

- [Risk] OFX is a loosely-specified format; real-world bank exports vary in tag casing, whitespace, and rarely-used optional fields → Mitigation: parser is tolerant (case-insensitive tag matching, ignores unrecognized tags/aggregates) and any unparseable transaction row is surfaced to the user as a skipped/error row rather than aborting the whole file.
- [Risk] `FITID` collisions across different institutions if a financial account's import history is later merged/renamed → Mitigation: the dedupe key is scoped to `(financial_account_id, fitid)`, not global.
- [Risk] Large statement files (multi-year history) could make the preview screen unwieldy → Mitigation: paginate/virtualize the preview list; out of scope to set a hard row limit in this change.
- [Trade-off] Requiring manual account selection (Decision 4) is less "magic" than auto-detection but avoids silently posting a statement against the wrong account, which would be a hard-to-notice, hard-to-undo mistake in an append-only ledger.

## Migration Plan

Additive only: one new Drift table (`ofx_import_records`) via a normal schema-version bump and migration step, no changes to existing tables. No data backfill needed — de-duplication only applies going forward, to imports performed after this change ships.
