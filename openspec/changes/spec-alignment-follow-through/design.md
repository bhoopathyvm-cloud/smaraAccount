## Context

See proposal.md for why. This change is a bundle of small, already-diagnosed alignments. It does not add product features beyond making existing specs and guidelines true in the UI and docs.

Current facts that shape the work:
- `RegisterViewModel` already accumulates running balance oldest-to-newest and then `reversed` the list. Only the `multi-account-ledger` wording is wrong.
- `StatementSkippedRow.reason` is populated by both parsers; the ViewModel keeps `_skippedRowCount` only.
- `confirmDestructiveAction`, `EntityPickerField`, and `StatusBanner` already exist in `lib/ui/core/`.
- `RecordTransactionViewModel` already watches financial accounts and groups; categories are the leftover View-layer stream.
- `RegisterRow` has `isVerified` / `breakReason` but no superseded flag; balances already skip `isSupersededByMigration`.
- `i18n-foundation` is an active, unimplemented change — this change does not start localization.

## Goals / Non-Goals

**Goals:**
- One SHALL for register order (newest first).
- Skipped-row reasons visible on the shared import flow.
- Shared-widget call sites that the review named (category archive, import account picker, CSV profile delete).
- Views do not call repositories.
- Superseded register rows have a distinct historical mark.
- User guide, architecture doc, and SECURITY.md match what has shipped.

**Non-Goals:**
- Implementing `i18n-foundation` or any locale pack.
- Adding a logging package (no `print()` exists; not a runtime defect).
- Forcing `EntityPickerField` onto the Settings provider dropdown (a closed enum, not an entity-id list).
- Changing import column-mapping dropdowns (those are positional indexes, not entities).
- Implementing archived-account closeout or changing foreign-transaction settlement (sibling changes).

## Decisions

### 1. Register order: amend `multi-account-ledger`, do not flip the list
`core-ledger-single-account`, the user guide, and the ViewModel already agree. The multi-account sentence is the leftover. No code change to sort order.

### 2. Skip reasons on the shared import ViewModel
Expose `List<StatementSkippedRow> skippedRows` (or a display projection) from `StatementImportViewModel` for both OFX and CSV. Render them with `StatusBanner` or a short list on the account-select / mapping / preview step that already shows the count. Do not invent a second review pipeline.

### 3. Shared widgets only at the named call sites
- Category archive: `confirmDestructiveAction` before `archiveCategory`.
- Import target account: `EntityPickerField<Account>` replacing the raw `DropdownButtonFormField`.
- CSV profile delete: `confirmDestructiveAction` before `deleteProfile`.
Leave Settings provider and CSV column-index dropdowns alone.

### 4. Categories live on `RecordTransactionViewModel`
Mirror the existing accounts subscription. Drop `ledgerRepository` from `RecordTransactionView` and from the router's view constructor.

### 5. Superseded mark is not the quarantine mark
Add `isSupersededByMigration` (or equivalent) on `RegisterRow`. Tile shows a muted historical label, not the signal-red lock used for unverifiable entries. Do not hide the row.

### 6. Docs
- User guide: add category-rule behavior under Importing bank statements. Do not document closeout here (sibling change, not shipped).
- Architecture: list current features, `domain/crypto|ofx|csv|statement_import`, and "network only for optional FX lookup when enabled."
- SECURITY.md: replace the 5.1.x template with a short local-first policy (no telemetry, key in OS storage, report via GitHub issues) consistent with README.

## Risks / Trade-offs

- [Risk] Bundling several small alignments in one change. → Mitigation: tasks are grouped by area; each group is independently testable. Do not mix in closeout or settlement.
- [Risk] Showing many skip reasons on a large CSV. → Mitigation: list reasons in a scrollable block; do not block Continue.
- [Risk] Architecture doc and OpenSpec specs can drift again. → Mitigation: the architecture update states that later capabilities (FX, import) override the original "NETWORK: None" sentence.

## Migration Plan

No schema change. Docs and UI only.

## Open Questions

None.
