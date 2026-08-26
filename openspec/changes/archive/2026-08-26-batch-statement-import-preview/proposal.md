## Why

`StatementImportViewModel._checkCurrencyAndBuildPreview` loops transactions in the UI layer, calling `matchCategoryRule` then `await suggestCategoryFor` per row — N+1 async, with categorization policy split across domain, repository, and view model. The repository is shallow for parsing/dedupe/post while deep policy lives in UI orchestration. Hard to unit-test and slow on large statements.

## What Changes

- Move preview-row construction (`buildPreviewRows` or equivalent) behind `StatementImportRepository` or a domain categorizer invoked once from the repository.
- Return ready-to-bind preview DTOs with duplicate flags and suggested categories via batched queries.
- Slim the view model to load → display → confirm; remove the per-row await loop from UI.

## Capabilities

### New Capabilities
- `statement-import-preview`: batched preview categorization at one import seam (rules + suggestions + duplicate flags).

### Modified Capabilities
- (none — CSV/OFX import product scenarios stay the same; implementation depth moves)

## Impact

- `lib/ui/features/statement_import/view_models/statement_import_view_model.dart`
- `lib/data/repositories/statement_import_repository.dart`
- `lib/domain/statement_import/*` (category rules, parsed transactions, batch types)
- Statement-import unit tests; acceptance CSV/OFX files should stay green unmodified
