## Why

SMARA Account today reads as a careful, tamper-evident general ledger for
one disciplined user: recovery phrase at the door, five equal tabs, ledger
vocabulary, Summary as two totals, and correction via reversal that the
UI barely surfaces. That is faithful to the signed double-entry core but
misaligned with how most people manage household money — quick capture,
“where did it go this month?”, forgiving fixes, backup they control, and
plain language.

This change is the **program umbrella**: it records the repositioning
from “signed journal” to **household books on your device** without
weakening immutability, local-first, or hidden double-entry. Individual
child changes under `openspec/changes/` implement each feature; this
change tracks scope, dependency order, and what stays out of scope.

## What Changes

- Adopt a household product promise: spend/receive like a notebook; history
  cannot quietly rewrite itself.
- Map twenty user-facing improvements to named OpenSpec child changes
  (see design.md).
- Define implementation waves so copy, capture, insight, habit, and power
  features land in a sensible order.
- Keep non-negotiables: no silent edit of posted entries; no server
  custody of books or keys; no auto-filled FX as truth.

## Capabilities

### New Capabilities

- `household-product-positioning`: umbrella requirements for voice,
  default journeys, and dependency ordering across child changes (spec
  lives in this change only until children archive).

### Modified Capabilities

(none)

Each child change owns its own `user-guide` delta for the feature it
adds — checked, all eighteen now have one. This umbrella change itself
adds no feature to document; `README.md` repositioning (tracked in
tasks.md 1.2) is a separate file `user-guide`'s "every shipped feature"
requirement doesn't govern.

## Impact

- No application code in this change — planning artifacts only.
- Child changes touch UI, repository, schema (where noted), tests, and
  `docs/user-guide.md`.
- `archived-account-closeout` and `foreign-transaction-settlement-align`
  have since merged to `main` — Wave 2 UI churn on Home and Register can
  proceed against the shipped closeout mechanism (`archiveFinancialAccount`,
  `recordArchivedAccountCloseoutTransfer`, `canCloseoutSelectedAccount`),
  not a design still in flight.

## Child changes (20 features)

| # | User need | OpenSpec change | Wave |
|---|-----------|-----------------|------|
| 1 | Plain language | `household-language-voice` | 1 |
| 2 | Use before 24 words | `deferred-onboarding-first-entry` | 1 |
| 3 | Home Add hub | `home-hub-capture` | 2 |
| 4 | Fix mistakes | `fix-this-correction-wizard` | 1 |
| 5 | Search register | `register-search` | 2 |
| 6 | This month by category | `home-hub-capture` | 2 |
| 7 | Remember last spend | `payees-and-spending-memory` | 2 |
| 8 | Recurring | `recurring-templates` | 3 |
| 9 | Split purchase | `split-transactions` | 3 |
| 10 | Payees | `payees-and-spending-memory` | 2 |
| 11 | Backup file | `ledger-backup-restore` | 1 |
| 12 | App lock | `app-lock` | 1 |
| 13 | Local money format | `localized-money-formatting` | 1 |
| 14 | Language | `i18n-foundation` (+ locale packs) | 1–5 |
| 15 | Monthly limits | `monthly-category-limits` | 3 |
| 16 | Credit card flow | `credit-card-household-flow` | 3 |
| 17 | Unarchive | `unarchive-accounts-categories` | 4 |
| 18 | Export data | `ledger-data-export` | 4 |
| 19 | First-week wizard | `first-week-setup-wizard` | 2 |
| 20 | Plain pending FX | `pending-transfers-plain-language` | 2 |
