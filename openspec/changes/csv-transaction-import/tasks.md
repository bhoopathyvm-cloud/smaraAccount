## 1. Generalize the Shared Import Pipeline (rename layer, no behavior change)

- [x] 1.1 Rename `lib/domain/ofx/parsed_ofx_transaction.dart`'s types to source-agnostic names in a new `lib/domain/statement_import/` home: `ParsedOfxTransaction` -> `ParsedStatementTransaction`, `OfxParseResult` -> `StatementParseResult`, `OfxSkippedRow` -> `StatementSkippedRow`
- [x] 1.2 Rename `lib/domain/ofx/ofx_import_batch.dart`'s types similarly: `OfxAcceptedRow`/`OfxPostedRow`/`OfxImportBatchResult` -> `Statement*` equivalents, moved to `lib/domain/statement_import/`
- [x] 1.3 Update `lib/domain/ofx/ofx_parser.dart` to import/return the new generic types instead of the old OFX-named ones (its own internal OFX-specific parsing logic is unchanged)
- [x] 1.4 Rename `OfxImportRepository` -> `StatementImportRepository` (`lib/data/repositories/`), keeping `parseFile`/`groupCurrencyFor`/`findDuplicateIndexes`/`suggestCategoryFor`/`postAcceptedRows` behavior identical, retyped to the generic types
- [x] 1.5 Add a nullable `source` column (`'ofx'` | `'csv'`) to the existing `ofx_import_records` table (additive migration; existing rows default to `'ofx'`) - table itself keeps its SQL name (design.md Decision 5)
- [x] 1.6 Rename `OfxImportViewModel`/`OfxImportView` and the `/import-ofx` route to source-agnostic names (`StatementImportViewModel`/`StatementImportView`, route becomes e.g. `/import-statement`) - the explicit OFX-vs-CSV choice step itself is task 4.1
- [x] 1.7 Re-run the full existing OFX-import test suite (parser, repository, widget, end-to-end) against the renamed types and confirm zero behavior regressions

## 2. CSV Parsing

- [x] 2.1 Add the `csv` package dependency to `pubspec.yaml`
- [x] 2.2 Define the column-mapping model (`lib/domain/csv/csv_column_mapping.dart`): date column + date format, description column(s), amount convention (signed column vs. debit/credit columns), optional reference-id column, header-row presence flag, currency
- [x] 2.3 Implement the CSV parser (`lib/domain/csv/csv_parser.dart`) that applies a `CsvColumnMapping` to file bytes and produces a `StatementParseResult`, using the `csv` package for RFC 4180 parsing
- [x] 2.4 Apply permissive decoding (BOM stripping, tolerant UTF-8) matching the approach already used for OFX's non-clean-UTF-8 files
- [x] 2.5 Report unparseable-as-CSV files (root-level failure) vs. individual rows that don't fit the mapping (row-level skip) as distinct result types, mirroring the OFX parser's error model
- [x] 2.6 Unit tests: header-row file, headerless positional file, signed-amount-column convention, separate debit/credit-column convention, malformed row skipped without aborting, non-CSV file rejected, BOM-prefixed file

## 3. Import Profiles

- [x] 3.1 Add a `csv_import_profiles` Drift table: `id`, `name`, `header_fingerprint` (JSON-encoded ordered header list), `column_mapping` (JSON-encoded `CsvColumnMapping`), `created_at`; additive migration
- [x] 3.2 Add repository methods on `StatementImportRepository`: `saveProfile(name, mapping, headerRow)`, `findProfileForHeaderRow(headerRow)` (exact-match lookup), `watchProfiles()` (streaming, matching this repo's `watch*` convention rather than a one-shot `listProfiles()`), `renameProfile`, `deleteProfile`
- [x] 3.3 Unit tests: save and exact-match lookup succeeds; a file with a differing header row does not match; rename and delete work and are reflected in `watchProfiles()`

## 4. CSV Import UI Flow

- [x] 4.1 Add a source-choice step to the renamed statement-import entry flow: "Import OFX/QFX file" vs "Import CSV file"
- [x] 4.2 Column-mapping screen: pick the target account first (so currency can default), map columns (date + format, description, amount convention, optional reference id), toggle header-row presence, live preview of the first several parsed rows, "save as profile" option
- [x] 4.3 When a file's header row matches a saved profile, pre-fill the mapping screen from it and let the user jump straight to preview without re-mapping (implemented as: pre-filled screen, a plain "Continue" tap confirms - matches spec.md's "confirming it skips directly to the preview step" exactly, not a fully silent auto-skip)
- [x] 4.4 Profile management: list, rename, delete saved profiles (on the mapping screen itself: a picker to apply one manually, plus per-profile rename/delete)
- [x] 4.5 Wire mapped/parsed CSV rows into the existing (renamed) preview/select/categorize/confirm screen unchanged - no CSV-specific preview UI
- [x] 4.6 Widget tests: column-mapping screen field validation, live preview rendering, profile auto-offered on header match, profile not offered on mismatch, manual profile selection, rename/delete profile

## 5. Validation

- [x] 5.1 Run `dart analyze` and `dart format --set-exit-if-changed` (clean across `lib`, `test`, `integration_test`); also confirmed `flutter build macos --debug` succeeds
- [x] 5.2 Run the full test suite (`flutter test`) and confirm no regressions in the renamed statement-import code or any other existing tests (295 passing, up from 264 at ofx-transaction-import baseline)
- [x] 5.3 Import a real-world-shaped CSV fixture end to end against the real repository/database stack: map columns, save as a profile, post, re-import the same file and confirm the profile auto-offers and duplicates are flagged. Used an ICICI-style debit/credit-column export for the full E2E round trip; the UBS-style signed-amount convention is covered thoroughly at the parser-unit-test level instead of a second full E2E pass (same convention already exercised end-to-end by the reused OFX E2E test's signed-amount posting path)
