## Why

Today, the only auto-categorization signal during statement import is an
exact match against a transaction's own previously-posted memo
(`StatementImportRepository.suggestCategoryFor`) — a new counterparty (or
one whose memo varies slightly transaction to transaction, as most banks'
memos do) gets no suggestion at all. For a 200-row CSV import, that means
categorizing many rows one at a time. Users need a way to categorize by
counterparty (who the money came from or went to) once, and have it apply
automatically — both to the rest of the current import and to every future
one.

## What Changes

- Add **category rules**: a user-defined, named mapping from a keyword/substring
  match against a transaction's description to a category, stored
  independently of any single import.
- On the statement-import preview screen, group rows whose description
  contains a common substring together, and let the user assign a category
  to the whole group in one action instead of row by row. Assigning a
  category to a group offers saving it as a reusable rule.
- Auto-apply saved rules during preview-building: a row whose description
  matches a saved rule's keyword is pre-categorized from that rule, taking
  priority over the existing exact-memo-match fallback (which still applies
  when no rule matches).
- Add rule management (view, edit keyword/category, delete) — mirroring how
  saved CSV import profiles are already managed.
- Out of scope: automatic/fuzzy counterparty detection without a
  user-defined keyword (no guessing, consistent with this app's existing
  CSV-mapping philosophy of never inferring what the user hasn't specified);
  per-account rule scoping (rules apply across all financial accounts, since
  a counterparty's category doesn't depend on which of the user's accounts
  the money moved through).

## Capabilities

### New Capabilities
- `import-category-rules`: storing, matching, and managing user-defined
  keyword-to-category rules, and the grouped-row bulk-categorization
  interaction on the statement-import preview screen.

### Modified Capabilities
- `ofx-transaction-import`: the "Categorize Rows Before Posting" requirement
  changes so that a matching saved category rule is tried before the
  existing exact-memo-match fallback. (`csv-transaction-import` already
  points to this same requirement for its own category-suggestion behavior,
  so it inherits this change without its own delta.)

## Impact

- `lib/data/repositories/statement_import_repository.dart` (`suggestCategoryFor`)
- `lib/ui/features/statement_import/view_models/statement_import_view_model.dart`
  (row grouping, bulk-assign, rule persistence calls)
- `lib/ui/features/statement_import/views/statement_import_view.dart` (grouped preview UI)
- New Drift table for saved category rules (additive migration), following
  the existing `CsvImportProfiles` table pattern
- New domain model for a category rule, following the existing
  `CsvImportProfile` pattern
