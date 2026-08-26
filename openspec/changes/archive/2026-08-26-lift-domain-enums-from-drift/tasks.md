## 1. Inventory

- [x] 1.1 List domain models that import Drift table enums and the enum families involved
- [x] 1.2 Propose domain type names aligned with product vocabulary

## 2. Lift and map

- [x] 2.1 Add domain enum/value types under `lib/domain/`
- [x] 2.2 Add repository mappers Drift ↔ domain; switch domain models off Drift imports
- [x] 2.3 Update call sites (repositories, view models, tests) until `dart analyze` is clean
- [x] 2.4 Remove unused re-exports and dead Drift-facing helpers from domain

## 3. Verify

- [x] 3.1 Domain sources no longer import `lib/data/database/tables` for those enums
- [x] 3.2 Unit suites for ledger/accounts/integrity green
- [x] 3.3 Note coordination with `extract-ledger-posting-core` if both touch the same files
