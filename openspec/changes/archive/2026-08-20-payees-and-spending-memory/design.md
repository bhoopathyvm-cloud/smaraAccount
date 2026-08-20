## Context

Checked before writing this: `normalizeDescription` (trim + lowercase) in
`domain/statement_import/category_rule.dart` is already a pure, generic
string function, not coupled to import-specific types — payee matching
reuses it directly rather than reimplementing normalization. The
"link import keyword rules to payee names" bullet in an earlier draft
had no corresponding delta on `import-category-rules`, even though it
was claimed as a modified capability — resolved with a real delta (see
`specs/import-category-rules/spec.md`) scoped to the one concrete linking
moment that already exists in the UI: saving a rule from a group
assignment.

## Goals / Non-Goals

**Goals:** Second entry for a known payee is one tap; a category rule
learned from import also benefits manual entry for the same payee.

**Non-Goals:** Automatically inferring a payee from every historical
transaction's description (v1 links only at the point a rule is
explicitly saved, and via manual payee creation) — a broader
description-mining feature is a separate, later change if wanted.

## Decisions

### 1. `payees` table; soft match via existing normalization
`payees(id, name, default_category_id, default_financial_account_id)`.
Matching a typed description against a payee reuses
`normalizeDescription`, the same function import category rules already
use — one normalization rule across both features, not two.

### 2. Linking happens at rule-save time, not automatically everywhere
When the user saves a category rule from a group assignment (the
existing `import-category-rules` flow), the save dialog additionally
offers "also remember as a payee," pre-filled with the rule's keyword as
the payee name and the assigned category as its default. Declining
leaves the rule exactly as it works today, with no payee created —
linking is opt-in, not a silent side effect of saving a rule.

## Risks / Trade-offs

- [Risk] Interaction with other child changes. → See
  household-product-repositioning waves.

## Open Questions

None for v1.
