## Context

Design system already says direction is icon + sign, not color. This
change is **words**, not layout.

## Goals / Non-Goals

**Goals:** Consistent household dictionary; no debit/credit in UI.

**Non-Goals:** Translating strings (i18n-foundation); changing domain
enum names (`TransactionDirection`) unless aliased at UI boundary.

## Decisions

### Term map (canonical English)

| Ledger/internal | Household UI |
|-----------------|--------------|
| Money in | Received |
| Money out | Spent |
| Record transaction | Add spent / Add received |
| Transfer | Moved money |
| Reverse | Fix |
| Archive (account/category) | Hide from new entries |
| Net position | What you have minus what you owe |
| Pending transfer | Money in transit (see pending change) |
| Financial account | Account |

Internal code and specs may keep existing names; UI and guide use right
column.

### Settings glossary
One screen section: immutability explained as “we keep the old line and
add a correction so history stays honest.”

## Risks

- [Risk] Strings churn twice (voice then i18n). → Acceptable; voice first
  defines meaning.

## Open Questions

None.
