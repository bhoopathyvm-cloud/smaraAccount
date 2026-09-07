## Why

`extract-statement-import-session` only moved step/source/`CsvMappingDraft`. Preview rows, grouping, category assignment, currency mismatch, and accepted-row selection still live on `StatementImportViewModel` (~520 lines). Architecture review cycle 6 finishes that unfinished seam (same pattern as `finish-chart-catalog-seams`).

## What Changes

- Expand `StatementImportSession` to own file/parse context, selected account, currency mismatch, skipped rows, editable preview rows, and pure mutations (`toggleRowSelected`, `setRowCategory`, `setCategoryForGroup`, `applyPreview`, `acceptedRows`, `skippedOrExcludedRowCount`).
- ViewModel keeps repository I/O, streams, loading flags, and orchestration that feeds the session.
- Preserve import behavior.

## Capabilities

### New Capabilities
- (none — finishing existing `statement-import-session`)

### Modified Capabilities
- `statement-import-session`: session owns preview/review state; ViewModel does not inline those mutations.

## Impact

- `lib/domain/statement_import/statement_import_session.dart`
- `lib/ui/features/statement_import/view_models/statement_import_view_model.dart`
- Domain + VM tests
