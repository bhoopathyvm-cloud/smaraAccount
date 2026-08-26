## Why

`buildPreviewRows` deepened preview matching, but `StatementImportViewModel` (~616 lines) still owns the wizard step machine, CSV mapping draft, grouping, and transitions. The ViewModel interface is nearly as wide as its implementation; step widgets cannot get simpler until session state moves down.

## What Changes

- Extract a Flutter-free `StatementImportSession` module: step, CSV mapping draft, `loadFile` / `selectAccount` / `confirmCsvMapping` / `confirmImport`.
- ViewModel becomes a thin `ChangeNotifier` adapter (subscribe accounts/categories, forward calls, expose a read-only snapshot).
- Keep `StatementImportRepository.buildPreviewRows` / `postAcceptedRows` as the data seam — this change does not re-do preview batching.

## Capabilities

### New Capabilities
- `statement-import-session`: wizard session state and transitions behind a small interface, testable without widgets.

### Modified Capabilities
- (none — product CSV/OFX import requirements unchanged)

## Impact

- `lib/ui/features/statement_import/view_models/statement_import_view_model.dart`
- New `lib/domain/statement_import/` (or similar) session module
- Statement-import view-model and widget tests retargeted to session + thin adapter
