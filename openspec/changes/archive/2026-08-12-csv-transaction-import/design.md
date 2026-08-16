## Context

`ofx-transaction-import` (shipped, on its own unmerged branch as of this writing) built a full pipeline for turning a parsed statement file into posted journal entries: `ParsedOfxTransaction` → account matching → duplicate detection (`ofx_import_records` table, FITID or fallback-key) → category suggestion → preview/select/categorize UI → `postAcceptedRows` (which threads each row through the existing `LedgerRepository.recordTransaction`, unmodified). None of that logic is OFX-specific in spirit — it only became OFX-specific in naming because OFX was the first source. CSV needs the same pipeline; the only genuinely new problem is that CSV, unlike OFX, has no fixed schema — every bank's export has different column names, order, date format, and amount convention, and there's no `FITID`-equivalent guaranteed to exist.

## Goals / Non-Goals

**Goals:**
- Parse arbitrary bank CSV exports into the same row shape OFX import already produces, via an explicit user-driven column mapping (never guessed/auto-detected).
- Let a mapping be saved as a named, reusable **profile** and offered again automatically when a later file's header row matches.
- Reuse `ofx-transaction-import`'s account-matching, duplicate-detection, category-suggestion, and posting code paths without re-implementing or forking them.
- Generalize the currently-OFX-named domain types just enough that "where did this row come from" stops being baked into type names, without a wasteful full rewrite.

**Non-Goals:**
- Auto-detecting column meaning from header text (e.g. guessing "Amount" means the amount column) - explicit user mapping only, this change's whole reason for existing is that guessing is exactly what goes wrong across differently-shaped bank exports.
- Fuzzy/partial profile matching (e.g. "80% of headers match") - a profile is offered only on an exact header-row match; anything else requires either picking a profile manually or mapping fresh.
- PDF or Excel (.xlsx) statement parsing.
- Renaming the underlying `ofx_import_records` SQL table - see Decision 5.

## Decisions

**1. Branch this change on top of `ofx-transaction-import`, not `main`.**
This change's whole value proposition is reusing that pipeline, including renaming some of its types (Decision 4). Branching from `main` (where `ofx-transaction-import` doesn't exist yet) would mean either duplicating the pipeline temporarily or a painful three-way merge later. Branch from `ofx-transaction-import` and let both land together, or rebase once the OFX branch merges - a repo-workflow choice, not an architecture one, but worth being explicit about since it affects when this change can actually start.

**2. CSV parsing: the `csv` package, not hand-rolled.**
Plain-looking CSV has real edge cases - quoted fields containing commas or embedded newlines, escaped quotes - that a hand-rolled `split(',')` parser gets wrong on real bank exports. The `csv` package is a small, well-maintained RFC 4180 parser; use it rather than repeating OFX's "why not just hand-roll it" reasoning in a case where the naive approach is actually risky, not just noisier code.

**3. Column mapping model.**
A mapping captures: which column is the date (+ an explicit date-format string, e.g. `dd/MM/yyyy` - never inferred, see Risks), which column(s) are the description (allow concatenating two, e.g. "Payee" + "Reference"), the amount convention (a single signed column, or separate debit/credit columns - both are common; ICICI's export uses separate withdrawal/deposit columns), an optional external-reference-id column (reuses the exact-match dedupe path FITID already established; absent by default since most bank CSVs don't have one), and whether the file has a header row at all (assumed yes by default; the user can flag a headerless file, in which case columns are referenced positionally). Currency is not read from the file - CSV exports essentially never embed it - the user confirms the file's currency once per import, same shape as OFX's `CURDEF`-mismatch-warning flow but without a value to compare against until the user supplies one.

**4. Generalize the shipped OFX types, but only the shared layer.**
Rename the source-agnostic parts: `ParsedOfxTransaction` → `ParsedStatementTransaction`, `OfxParseResult` → `StatementParseResult`, `OfxAcceptedRow`/`OfxImportBatchResult`/`OfxPostedRow` → `Statement*` equivalents, `OfxImportRepository` → `StatementImportRepository`. Leave `ofx_parser.dart`/`ofx_sgml_normalizer.dart` as-is internally (still OFX-specific parsing logic) but have them return the new generic type; add `lib/domain/csv/csv_parser.dart` alongside as the CSV-specific counterpart. Both parsers become interchangeable inputs to one shared repository and one shared preview/post UI. Alternative considered: leave everything named `Ofx*` and just have CSV parsing produce `ParsedOfxTransaction` objects too - rejected as confusing debt that gets worse with every future source (a hypothetical Wise-API source would be even more obviously mis-named as "Ofx").

**5. Keep the `ofx_import_records` table name; add a `source` column instead of renaming the table.**
Dart-level renames are free (compile-time checked, no migration). A SQL table rename is not - it would need a new-table-plus-copy migration for zero user-visible benefit, since the table's name was never exposed to users. Add a nullable `source` column (`'ofx'` or `'csv'`, defaulting existing rows to `'ofx'`) purely for future debugging/analytics value, and keep the table itself as `ofx_import_records`.

**6. Profile matching: exact header-row match only, no fuzzy scoring.**
A profile stores its source file's header row (trimmed, case-normalized) as its fingerprint. On a new CSV import, if a saved profile's fingerprint exactly matches the new file's header row, it's offered as the default mapping (skippable straight to preview, same as OFX's happy path). No match → no profile is auto-selected, but all saved profiles remain manually choosable from a picker (at the user's own risk) alongside "map fresh." This keeps the matching behavior predictable - a bank tweaking their export format (a real, semi-frequent occurrence) fails safe into "please confirm the mapping again," not a silently-wrong guess.

## Risks / Trade-offs

- [Risk] Date-format ambiguity (`03/04/2026` = 3 April or March 4?) is a classic source of silently-wrong imported dates → Mitigation: the date format is always an explicit user selection, never inferred, and the mapping screen shows a live preview of the first few parsed rows so the user can visually catch a wrong format before confirming.
- [Risk] Decimal/thousands-separator convention differs by locale (`1.234,56` vs `1,234.56`) - UBS exports in particular may use the European convention → Mitigation: same explicit-selection-plus-preview approach as dates.
- [Risk] Bank CSV exports are inconsistently encoded (BOM markers, CP1252 vs UTF-8) → Mitigation: apply the same permissive decode-with-BOM-stripping approach already proven for OFX's non-UTF-8-clean files.
- [Trade-off] Renaming already-shipped, already-tested OFX-import code (Decision 4) is real churn on working code, not a from-scratch addition - justified here because doing it now (before the OFX branch has real user data riding on today's exact type names) is far cheaper than doing it after a third source shows up.

## Migration Plan

Additive only: new `csv_import_profiles` table (name, header fingerprint, column mapping, date format, amount convention, decimal separator), and one additive nullable `source` column on the existing `ofx_import_records` table. No renames at the SQL level, no backfill required beyond defaulting existing rows' `source` to `'ofx'`.
