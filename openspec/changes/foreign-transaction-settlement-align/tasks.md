## 1. Spec and comments

- [x] 1.1 Confirm `openspec/changes/foreign-transaction-settlement-align/specs/foreign-currency-settlement/spec.md` is the full MODIFIED settlement requirement (no shortfall for `foreignTransaction`).
- [x] 1.2 Update the `settlePendingTransfer` doc comment in `LedgerRepository` so it cites this spec, not "corrected during apply."
- [x] 1.3 Update `SettlePendingTransferViewModel` class comment to match the same rule.

## 2. Tests

- [x] 2.1 Keep existing repository tests that a foreign-currency transaction settlement posts to its own account with no shortfall and no fee entry.
- [x] 2.2 Keep or add a repository test that a fee category on a foreign-currency transaction settlement is rejected.
- [x] 2.3 Keep or add a repository test that a zero settled amount on a foreign-currency transaction settlement is rejected and posts nothing.
- [x] 2.4 Confirm transfer source-settlement shortfall/fee tests still pass unchanged.

## 3. User-guide clarification (if needed)

- [x] 3.1 If the settlement paragraph in `docs/user-guide.md` can be read as applying shortfall to a foreign-currency transaction, add one sentence that shortfall/fee applies only when a *transfer* returns to its source.

## 4. Verification

- [x] 4.1 Run `dart analyze` and the repository / settle-pending-transfer tests.
