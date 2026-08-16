## 1. Register order spec (no list-order code change)

- [ ] 1.1 Confirm the `multi-account-ledger` delta states reverse-chronological, newest first, with running balance still computed oldest-to-newest.
- [ ] 1.2 Confirm existing register view-model / widget tests still assert newest-first; add a comment pointing at both specs if a test name still says "chronological."

## 2. Import skipped-row reasons

- [ ] 2.1 Expose the parsed `StatementSkippedRow` list (not only a count) from `StatementImportViewModel` for OFX and CSV.
- [ ] 2.2 Show each skipped row's reason on the import flow (account-select and/or mapping/preview) without blocking Continue.
- [ ] 2.3 View-model and widget tests: a file with one bad row lists that reason and still offers the good rows.

## 3. Shared UI reuse

- [ ] 3.1 Category archive calls `confirmDestructiveAction` before `archiveCategory`; cancel does not archive.
- [ ] 3.2 Import target-account step uses `EntityPickerField<Account>` instead of a raw `DropdownButtonFormField`.
- [ ] 3.3 CSV profile delete calls `confirmDestructiveAction` before `deleteProfile`.
- [ ] 3.4 Widget tests for confirm/cancel on category archive and profile delete.

## 4. Record-transaction layering

- [ ] 4.1 `RecordTransactionViewModel` watches categories (active only) and exposes the filtered list for the current direction.
- [ ] 4.2 `RecordTransactionView` reads categories from the ViewModel; remove `ledgerRepository` from the view and from `app_router.dart`.
- [ ] 4.3 Update record-transaction widget / view-model tests for the new subscription.

## 5. Superseded register rows

- [ ] 5.1 Add a superseded/historical flag on `RegisterRow` from `entry.isSupersededByMigration`.
- [ ] 5.2 `RegisterRowTile` shows a muted historical label, distinct from the quarantine lock/signal treatment.
- [ ] 5.3 Widget or view-model test: a superseded row is visible, labeled, and excluded from running balance.

## 6. Docs

- [ ] 6.1 Add import category rules (keyword match, group assign, rule-over-memo) to `docs/user-guide.md`. Do not document closeout here.
- [ ] 6.2 Update `Specs/architecture/smara-architecture.md`: current feature tree, `domain/` subpackages, and network only for optional FX lookup when enabled.
- [ ] 6.3 Replace the Flutter-template `SECURITY.md` with a short local-first policy consistent with README (no telemetry, key in OS storage, report via GitHub issues).

## 7. Coverage leftovers from the review

- [ ] 7.1 Widget test: account-management rename dialog survives dismissal (`pumpAndSettle` after Save), matching the create-dialog tests.
- [ ] 7.2 Widget test for `settings_view.dart` (enable/disable lookup, provider list is the enum only).
- [ ] 7.3 Repository test: a settled pending transfer no longer appears in `watchHomeOverview`'s pending list.

## 8. Verification

- [ ] 8.1 Run `dart analyze` and the full test suite; fix any new warnings.
