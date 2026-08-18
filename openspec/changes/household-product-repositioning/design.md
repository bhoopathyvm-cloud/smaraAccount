## Context

The ledger engine (signed journal, accounts, categories, transfers,
import, quarantine) is sound. The product gap is **household usability**:
voice, default paths, insight, habits, and trust rituals (backup, lock).
Child changes are sized for independent implementation and archive.

## Goals / Non-Goals

**Goals:**
- Twenty mapped features with clear OpenSpec ownership.
- Waves that minimize merge pain (language + money formatting before
  massive UI string churn; backup before “put real data in”).
- Preserve double-entry derivation and reversal-based correction.

**Non-Goals (program level):**
- Multi-user household sync, bank login, investment trading, AI advice.
- Replacing immutability with edit-in-place.
- Shipping all twenty in one release.

## Implementation waves

```
Wave 1 — Trust & speak human
  household-language-voice
  deferred-onboarding-first-entry
  fix-this-correction-wizard
  ledger-backup-restore
  app-lock
  localized-money-formatting
  (i18n-foundation in parallel when ready)

Wave 2 — Daily capture & glance
  home-hub-capture          (Add hub + this month by category)
  register-search
  payees-and-spending-memory
  pending-transfers-plain-language
  first-week-setup-wizard

Wave 3 — Staying habits
  recurring-templates
  split-transactions
  monthly-category-limits
  credit-card-household-flow

Wave 4 — Power without accountant mode
  unarchive-accounts-categories
  ledger-data-export
```

## Decisions

### 1. Child changes, not one mega-change
Each feature has its own `proposal/design/tasks/specs` so branches,
PRs, and archive stay reviewable. This umbrella change does not block
`openspec apply` on children.

### 2. Voice before locale packs
`household-language-voice` defines English household terms (`Spent`,
`Received`, `Fix`, `Hide`) as the semantic source for ARB keys when
`i18n-foundation` lands.

### 3. Correction is one wizard, two journal entries
`fix-this-correction-wizard` posts reversal + replacement; users never
pick debit/credit. Linkage is UX-only (optional “corrected” badge), not
a new immutable coupling requirement unless a child spec adds it.

### 4. Backup is the ledger file, identity stays separate
`ledger-backup-restore` exports encrypted SQLite (or logical export) the
user places off-device; recovery phrase / keystore still restore signing
identity only.

### 5. Credit card is a mode, not a new account type
`credit-card-household-flow` labels liability accounts and steers capture
(“Paid from card” vs bank) without breaking asset/liability model.

## Risks / Trade-offs

- [Risk] Twenty changes overwhelm contributors. → Mitigation: waves;
  each change is independently shippable.
- [Risk] `household-language-voice` + `i18n-foundation` overlap. →
  Mitigation: voice change defines semantics; i18n extracts strings.
- [Risk] Split transactions complicate signing chain. → Mitigation: one
  user action still yields balanced journal entries; child spec details.

## Open Questions

- Whether `household-language-voice` should update README positioning in
  the same change or a final program task after Wave 1 ships.
