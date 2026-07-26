## 1. ViewModel

- [x] 1.1 In `RegisterViewModel._recompute`, expose `_rows` reversed (newest first) while keeping the running-balance accumulation loop itself unchanged (still iterates the ascending-ordered entries internally)

## 2. Tests

- [x] 2.1 Update `test/ui/features/register/view_models/register_view_model_test.dart`'s existing order-dependent assertions (`rows[0]`/`rows[1]`) to the new newest-first order
- [x] 2.2 Add/confirm a test: recording a new entry against the viewed account makes it `rows.first`, with `rows.first.runningBalanceMinor` equal to the account's current balance
- [x] 2.3 Widget test: `RegisterView` renders rows in the ViewModel's exposed order (newest first) - e.g. two entries, assert the more recent one's row appears above the older one's
- [x] 2.4 Run `dart analyze` and the full test suite; fix any regressions
