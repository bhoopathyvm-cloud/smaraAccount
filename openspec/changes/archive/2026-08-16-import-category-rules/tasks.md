## 1. Data model and persistence

- [x] 1.1 Add a `CategoryRules` Drift table (`id`, `keyword`, `categoryId`, `createdAt`) in `lib/data/database/tables/`, following `csv_import_profiles_table.dart`'s shape
- [x] 1.2 Register the table in `app_database.dart` and add an additive migration step (bump `schemaVersion`, `onUpgrade` `if (from < N) { m.createTable(...) }`)
- [x] 1.3 Add a `CategoryRule` domain model (id, keyword, categoryId, createdAt), following `lib/domain/csv/csv_import_profile.dart`'s pattern
- [x] 1.4 Add `saveCategoryRule`, `watchCategoryRules`, `updateCategoryRule`, `deleteCategoryRule` to `StatementImportRepository`

## 2. Matching and suggestion

- [x] 2.1 Add a case-insensitive substring matcher: given a description and the current saved rules, return the most-recently-created matching rule's category, or null
- [x] 2.2 Update `StatementImportRepository.suggestCategoryFor` (or its caller in the view model) to check the rule matcher first, falling back to the existing exact-memo match when no rule matches
- [x] 2.3 Add a normalized-description grouping helper (trim + case-fold) for building preview row groups

## 3. Preview screen: grouping and bulk assignment

- [x] 3.1 In `StatementImportViewModel`, group `_rows` by normalized description and expose the groups to the view
- [x] 3.2 Add a `setCategoryForGroup(groupKey, categoryId)` method that sets the category on every row currently in that group
- [x] 3.3 Update `statement_import_view.dart` to render grouped rows with a single category picker per group (still allowing per-row override)
- [x] 3.4 After a group category assignment, prompt to save it as a rule: pre-fill the keyword from the group's normalized description for multi-row groups; require an explicit keyword for single-row groups
- [x] 3.5 Wire the "save as rule" confirmation to `StatementImportRepository.saveCategoryRule`

## 4. Rule management UI

- [x] 4.1 Add a rule list view showing keyword + category per saved rule — reachable via a "Manage category rules" app bar action on the import screen itself, not a separate settings screen: CSV import profiles turned out to already be managed inline within the import flow (the column-mapping step), not in a settings area as originally assumed, so rule management follows that same actual precedent instead
- [x] 4.2 Add edit (keyword and/or category) and delete actions, wired to `updateCategoryRule`/`deleteCategoryRule`

## 5. Tests

- [x] 5.1 Unit tests for the substring matcher: match, no match, case-insensitivity, multiple-matches-resolves-to-most-recent
- [x] 5.2 Unit tests for `suggestCategoryFor`'s new priority order: rule match wins over exact-memo match; falls back correctly when no rule matches
- [x] 5.3 Widget/view-model tests for grouping preview rows by normalized description, including the single-row group case
- [x] 5.4 Widget/view-model tests for bulk-assigning a category to a group and for the save-as-rule flow (both the pre-filled-keyword and explicit-keyword paths)
- [x] 5.5 Repository tests for save/watch/update/delete of category rules, and for the additive migration

## 6. Verify

- [x] 6.1 `flutter analyze` passes with no new warnings
- [x] 6.2 Full test suite passes (338 tests: 313 pre-existing + 25 new)
- [x] 6.3 Manually import a CSV with repeated/varied counterparties on a physical device or simulator, confirm grouping, bulk assignment, rule saving, and that a second import auto-categorizes via the saved rule — verified by the user on-device
