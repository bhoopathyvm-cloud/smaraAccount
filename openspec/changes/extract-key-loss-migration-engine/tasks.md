## 1. Extract

- [x] 1.1 Add `lib/data/repositories/key_loss_migration_engine.dart` (`migrate()` + active-entries selection)
- [x] 1.2 `IdentityRepository` constructs one engine and delegates `migrateToNewIdentityAfterKeyLoss`; remove the moved algorithm and now-unused imports

## 2. Verify

- [x] 2.1 `dart analyze` clean
- [x] 2.2 Real-DB migration tests (`ledger_repository_test.dart` migrate group) + migration UI tests green
- [x] 2.3 Full `flutter test` suite green
- [x] 2.4 Linux acceptance `identity_restore` group green
