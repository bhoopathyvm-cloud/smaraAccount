# Household Term Map

SMARA Account is a signed, double-entry ledger under the hood, but it
should never ask a user to think in debits, credits, or journal entries.
This is the canonical mapping from internal/ledger concepts to the
household words the UI and user guide use. Contributors adding
user-visible copy should use the right-hand column; `i18n-foundation`
uses this map when extracting ARB keys so translated strings carry the
same meaning.

| Ledger/internal concept       | Household UI wording                  |
|--------------------------------|----------------------------------------|
| Money in (`TransactionDirection.moneyIn`)  | Received                  |
| Money out (`TransactionDirection.moneyOut`) | Spent                    |
| Record transaction             | Add spent / Add received              |
| Transfer                       | Moved money                           |
| Reverse                        | Fix                                   |
| Archive (account/category/group) | Hide from new entries                |
| Net position                   | What you have minus what you owe      |
| Pending transfer                | Money in transit                     |
| Financial account               | Account                              |

Internal code, domain models, and OpenSpec specs may keep the existing
ledger-facing names (`TransactionDirection.moneyIn`, `archiveFinancialAccount`,
etc.) — only user-visible strings need to use the household wording.

## Why we don't edit old entries

Settings and the correction flow explain this without ledger vocabulary:
"we keep the old line and add a correction so history stays honest."
Never say debit, credit, journal entry, or posting in user-facing copy.
