    ## 1. OFX Parsing

- [x] 1.1 Add `xml` package dependency to `pubspec.yaml`
- [x] 1.2 Implement an OFX 1.x → well-formed-XML pre-pass (auto-close known leaf tags) in `lib/domain/ofx/ofx_sgml_normalizer.dart`
- [x] 1.3 Implement the normalized parsed-transaction model (`lib/domain/ofx/parsed_ofx_transaction.dart`): date, amount minor units, direction, memo/payee, `fitid` (nullable), source currency
- [x] 1.4 Implement the OFX document parser (`lib/domain/ofx/ofx_parser.dart`) that walks `STMTTRN`/`CCSTMTTRN` aggregates and `CURDEF`, using the `xml` package for both 1.x (post-normalization) and 2.x input
- [x] 1.5 Skip `INVSTMTTRN`/investment aggregates during parsing
- [x] 1.6 Report unparseable files (root-level failure) vs. skipped individual rows (row-level failure) as distinct result types
- [x] 1.7 Unit tests: OFX 2.x fixture, OFX 1.x (unclosed-tag) fixture, file with mixed investment + bank transactions, file with one malformed row, non-OFX file

## 2. Duplicate-Detection Storage

- [x] 2.1 Add `ofx_import_records` Drift table: `id`, `financial_account_id`, `fitid` (nullable), `fallback_match_key` (nullable), `journal_entry_id`, `imported_at`; unique index on `(financial_account_id, fitid)` where `fitid` is not null
- [x] 2.2 Bump schema version and add the additive migration step
- [x] 2.3 Add a repository method to look up existing `(financial_account_id, fitid)` and `(financial_account_id, fallback_match_key)` matches for a batch of parsed transactions
- [x] 2.4 Unit tests: migration applies cleanly on top of the current schema; lookup correctly flags a repeat `FITID` and a repeat fallback-key match, and does not flag an unrelated transaction

## 3. Import Repository

- [x] 3.1 Create `OfxImportRepository` (or extend `LedgerRepository`) with `parseFile(bytes) -> OfxParseResult`
- [x] 3.2 Implement account-matching support: list active financial accounts as candidates, expose the selected account's group currency for the mismatch-warning check against the file's `CURDEF`
- [x] 3.3 Implement category suggestion: given the target account and a row's memo, look up the most recent posted transaction (manual or imported) with an exact memo match against that account and return its category, if any
- [x] 3.4 Implement `postAcceptedRows(financialAccountId, rows)` that, per row, calls the existing `recordTransaction`/`recordTransfer` and on success writes the corresponding `ofx_import_records` row in the same local transaction; continues past a single row's failure and collects per-row results
- [x] 3.5 Ensure excluded/deselected/uncategorized/unparseable rows are never posted and never written to `ofx_import_records`
- [x] 3.6 Unit tests: posting a mix of valid/invalid rows posts the valid ones and reports the invalid ones; a posted row's `FITID` is recorded; a same-currency and a foreign-currency row both post through the existing currency-handling path unmodified

## 4. Import UI Flow

- [x] 4.1 Add an "Import OFX" entry point (e.g. from the accounts overview and from an account's register)
- [x] 4.2 File picker screen: select an `.ofx`/`.qfx` file, show parse errors for an unrecognized file
- [x] 4.3 Account-selection step: choose target account, pre-selected when launched from a register, archived accounts excluded from the list, currency-mismatch warning banner when applicable
- [x] 4.4 Preview/review screen: list parsed rows with date, amount, memo, category picker (pre-filled with suggestion), duplicate-flag indicator, per-row select/deselect checkbox (duplicates default unselected)
- [x] 4.5 Wire "Confirm Import" to `postAcceptedRows` and show a post-import summary (posted count, skipped/duplicate count, failed rows with reasons)
- [x] 4.6 Disable/hide the import entry point when the currently viewed account (register-launched case) is archived, consistent with other register actions
- [x] 4.7 Widget tests: preview screen row selection/deselection, category override, duplicate default-exclusion, post-import summary rendering

## 5. Validation

- [x] 5.1 Run `dart analyze` and `dart format --set-exit-if-changed`
- [x] 5.2 Run the full test suite (`flutter test`) and confirm no regressions in existing ledger/register/transfer tests
- [x] 5.3 Import a real-world-shaped sample OFX file end to end against the real (non-mocked) repository/database stack - one clean run, one re-import of the same file to confirm duplicate flagging - and verify posted entries in the register. Also confirmed the app builds and boots on macOS after all changes. NOTE: this sandbox has no display, so literal interactive GUI tap-through (file picker dialog, on-screen wizard) could not be performed - recommend a quick manual pass before shipping.
