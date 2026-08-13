## Context

`StatementImportViewModel` (`lib/ui/features/statement_import/view_models/statement_import_view_model.dart`)
drives the shared OFX/CSV preview screen. For each parsed row it calls
`StatementImportRepository.suggestCategoryFor(financialAccountId,
description: transaction.description)`
(`lib/data/repositories/statement_import_repository.dart:112`), which finds
the most recent journal entry on that account whose `description` is
**exactly** equal (case-sensitive, unnormalized) to the row's description,
and reuses its category. Real bank memos rarely repeat exactly — most embed
a per-transaction reference, date, or location suffix — so this signal
rarely fires, and the user ends up assigning a category to every row by
hand.

Categories are plain `Account` rows with `type == AccountType.expense` or
`AccountType.income` (`lib/domain/models/account.dart`) — there's no
separate `Category` type to extend.

The existing `CsvImportProfiles` table/`CsvImportProfile` model
(`lib/data/database/tables/csv_import_profiles_table.dart`,
`lib/domain/csv/csv_import_profile.dart`) is the precedent for a
user-managed, named, persisted entity tied to import: same repository
(`StatementImportRepository`), same additive-migration pattern in
`app_database.dart`. A category rule is a new, distinct entity — not an
extension of the column-mapping profile, which serves an unrelated purpose
(how a file's columns map to fields) and is keyed by header fingerprint,
not by transaction content.

## Goals / Non-Goals

**Goals:**
- Let a category assignment make future transactions from the same
  counterparty (in the same import and in every future one) categorize
  themselves.
- Reduce a 200-row, all-different-memo import to roughly as many
  categorization actions as there are distinct counterparties, not as many
  as there are rows.
- Keep the matching mechanism explicit and inspectable — no silent fuzzy
  matching a user can't see or correct, consistent with this app's existing
  refusal to guess CSV column meaning.

**Non-Goals:**
- Automatic counterparty extraction/clustering (e.g. stripping trailing
  reference numbers via heuristics). The user names the matching keyword
  themselves, once, when they'd otherwise be assigning a category anyway.
- Per-account rule scoping. A rule applies across all financial accounts.
- Changing anything about posting, duplicate detection, or the exact-memo
  fallback itself — this only adds a new, higher-priority signal ahead of
  it.

## Decisions

- **Matching mechanism: case-insensitive substring match against the row's
  description.** A rule stores a `keyword` (e.g. "AMAZON"); a row matches
  when its description, lowercased, contains the keyword lowercased. This
  is simple, fully explainable to the user ("this categorized because the
  description contains 'AMAZON'"), and doesn't require a new dependency.
  Alternative considered: fuzzy/token-similarity matching — rejected as
  unpredictable and harder for the user to reason about or correct, for
  the same reason the CSV importer already refuses to guess column
  meaning from header text.

- **Grouping in the preview screen is by exact normalized description
  (trimmed, case-folded)**, mirroring `normalizeHeaderRow`'s
  trim+lowercase approach for consistency with existing code. This handles
  the common case of literal repeats within one file (e.g. a subscription
  charged the same way every month) without needing any new matching
  logic just for grouping. Rows with distinct descriptions remain
  ungrouped (a group of one) but can still be bulk-assigned via the same
  action, since "assign category to this group" and "assign category to
  this row" become the same code path either way.

- **Assigning a category to a group offers "save as rule," with the
  keyword pre-filled from the group's shared description** (or, for a
  distinct-description group of one, the user must type a keyword to save
  a rule at all — a single arbitrary row's full description is a poor
  default keyword). Saving is opt-in per group: bulk-assigning a category
  without saving a rule only affects the current import, matching how a
  user might reasonably one-off categorize a single unusual row without
  wanting it to become a standing rule.

- **Rule priority: saved rule match, then the existing exact-memo
  fallback, then uncategorized.** A saved rule represents explicit,
  durable user intent and should win over the exact-memo heuristic. When
  multiple saved rules match the same description, the most recently
  created rule wins — simple and deterministic; rule conflicts are
  expected to be rare and the user can always override the suggestion or
  edit/delete a rule.

- **Persistence follows the `CsvImportProfiles` pattern exactly**: a new
  `CategoryRules` Drift table (`id`, `keyword`, `categoryId`,
  `createdAt`), a `CategoryRule` domain model, and
  `saveCategoryRule`/`watchCategoryRules`/`updateCategoryRule`/`deleteCategoryRule`
  methods on `StatementImportRepository`, added via the same additive
  `MigrationStrategy.onUpgrade` pattern already used for
  `csv_import_profiles`.

## Risks / Trade-offs

- [A short or generic keyword (e.g. "FEE") could over-match unrelated
  transactions.] → Mitigation: the preview always shows which rows a rule
  pre-categorized before posting, and any row's category remains
  individually editable — an over-broad rule is visible and correctable
  before anything posts, and the rule itself can be edited or deleted
  afterward.
- [Users may not realize a category assignment they made was also saved
  as a standing rule, and be surprised by it applying to an unrelated
  future import.] → Mitigation: saving is an explicit, separate opt-in
  action (not implied by simply assigning a category), and rule management
  (view/edit/delete) is reachable from the same settings area as import
  profiles.

## Migration Plan

- Additive-only: new table, no changes to existing tables or posted data.
  Existing imports and the exact-memo fallback continue to work unchanged
  for users who never create a rule.
- Rollback: dropping the new table/feature requires no data migration back,
  since no existing behavior depends on it.
