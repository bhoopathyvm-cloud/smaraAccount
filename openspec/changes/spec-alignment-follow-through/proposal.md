## Why

A spec-alignment review found several remaining gaps that are not the
closeout or foreign-transaction settlement problems: two specs disagree
on register sort order; skipped import rows are stored with reasons but
the UI shows only a count; category archive and a few pickers bypass
shared widgets; `RecordTransactionView` calls the repository directly;
migration-superseded register rows have no historical mark; the user
guide never mentions import category rules; and `smara-architecture.md`
still describes a three-feature, no-network app. None of these should
wait for a later "cleanup someday" change — they are the same class of
spec-first drift as the two product gaps.

## What Changes

- Reconcile `multi-account-ledger`'s register order with
  `core-ledger-single-account`, the implementation, and the user guide:
  reverse-chronological, newest first. Running-balance math stays
  oldest-to-newest internally.
- Show each skipped OFX/CSV row's reason to the user, not only a count.
- Route category archive through `confirmDestructiveAction`; use
  `EntityPickerField` for the import target-account picker; confirm CSV
  profile delete.
- Move category watching from `RecordTransactionView` into
  `RecordTransactionViewModel` so the View does not call the repository.
- Mark migration-superseded register rows as historical, the way
  quarantined rows are already marked unverifiable.
- Document import category rules in `docs/user-guide.md`.
- Refresh `Specs/architecture/smara-architecture.md` so it matches the
  shipped feature tree and the optional FX network exception.
- Replace the leftover Flutter-template `SECURITY.md` with a short
  policy that matches this project's local-first, no-telemetry stance.

## Capabilities

### New Capabilities

(none)

### Modified Capabilities

- `multi-account-ledger`: register listing order becomes
  reverse-chronological (newest transaction date first), matching
  `core-ledger-single-account`.
- `ledger-integrity-signing`: legacy entries superseded by true key-loss
  migration remain visible and SHALL be marked as historical/superseded
  in the register, not only excluded from totals.
- `ofx-transaction-import`: skipped-row reasons are displayed to the
  user, not only counted.
- `csv-transaction-import`: same skipped-row display rule (shared import
  UI).
- `user-guide`: the shipped-feature list includes import category rules.

## Impact

- `lib/ui/features/register/view_models/register_row.dart` and
  `register_row_tile.dart`: superseded badge.
- `lib/ui/features/statement_import/*`: skip-reason list; shared pickers
  and confirms.
- `lib/ui/features/record_transaction/*` and `lib/ui/app_router.dart`:
  categories via the ViewModel.
- `lib/ui/features/category_management/views/category_management_view.dart`:
  shared destructive confirm.
- `docs/user-guide.md`, `Specs/architecture/smara-architecture.md`,
  `SECURITY.md`.
- Widget tests for rename-dialog stability, settings, and the new
  skip-reason / superseded / confirm paths.
