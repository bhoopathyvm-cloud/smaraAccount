# Proposal: extract-recurring-template-draft

## Why
Recurring add/edit dialog still owns direction→category / readiness in View locals. Architecture cycle 11: finish the draft convention and share `categoriesForDirection`.

## What Changes
- Add `RecurringTemplateDraft` and shared `categoriesForDirection`.
- Point Record/Correction drafts at the shared helper; wire recurring dialog onto the draft.

## Impact
- Specs: `recurring-template-draft` (+ shared filter used by existing drafts).
