## Context
Cycle 11. Correction/Record drafts exist; Recurring was deferred.

## Decisions
1. Dialog owns the draft (holdings-style), VM stays CRUD adapter.
2. Extract shared `categoriesForDirection` and migrate Record + Correction in the same change.
3. Repo keep persist-time validation; draft owns UI readiness only.
