## 1. Schema and domain model

- [ ] 1.1 Add `currency` column to `account_groups` (ISO 4217 code, `TEXT NOT NULL`); require it whenever a group is created
- [ ] 1.2 Add the system "Transfers-in-transit" account (`group_id = NULL`, never user-selectable), seeded alongside the existing `equity` row in `confirmFirstIdentity` and the matching `onUpgrade` path
- [ ] 1.3 Add `pending_transfers` Drift table (`id`, `kind`, `source_account_id`, `category_id`, `destination_account_id`, `provisional_entry_id`, `status`, `settlement_entry_id`, `fee_entry_id`, `initiated_at`, `settled_at`); `kind` (`PendingTransferKind { transfer, foreignTransaction }`) and `status` (`PendingTransferStatus { pending, settled }`) are real Dart enums via `textEnum<T>()`, per Golden Rule #5 — not raw strings
- [ ] 1.4 Bump `schemaVersion` (confirm the exact next number once `multi-account-support` archives). Write both `onCreate` (schema + seeded system account, no legacy backfill) and `onUpgrade` paths per smara-tech-guidelines.md's Drift Migration Rule #5, including the currency backfill prompt for pre-existing `account_groups` rows (see design.md Migration Plan step 3)
- [ ] 1.5 Add domain models: `AccountGroup.currency`, `PendingTransfer`, and settlement input/result DTOs
- [ ] 1.6 Add or extend domain exceptions: group-currency mismatch, group-currency change rejected while accounts are assigned, cross-currency group reassignment rejected, settlement amount exceeds the provisional amount, negative settled amount, settling an already-settled pending transfer, fee category is not an active Expense category, direct reversal attempted on a still-pending provisional entry

## 2. Repository: currency, provisional posting, settlement

- [ ] 2.1 Enforce a currency on every account group at creation; require group assignment to resolve a financial account's display currency
- [ ] 2.2 Reject changing a group's currency while it has at least one active financial account; allow it when the group has zero active accounts
- [ ] 2.3 Extend `recordTransfer` to branch on currency: same-currency (unchanged from multi-account-support), known-rate cross-currency (single complete entry, two currencies, no `pending_transfers` row — reject if either currency's amount is non-positive), unknown-rate cross-currency (provisional entry against the Transfers-in-transit account + new `pending_transfers` row)
- [ ] 2.4 Extend `recordTransaction` with the same branching for a foreign-currency transaction against a financial account whose group currency differs from the transaction's native currency — the category leg always posts immediately in the native currency; reject a known-rate entry if either currency's amount is non-positive
- [ ] 2.5 Implement `settlePendingTransfer({pendingTransferId, settledToAccountId, settledAmountMinor, feeCategoryId?})`. When `settledToAccountId` is the original source account (or always, for `kind = foreignTransaction`, where it's resolved to `source_account_id` rather than accepted as a free parameter): compare `settledAmountMinor` to the provisional amount (same currency) and post a fee/loss entry for any shortfall; reject if `settledAmountMinor` exceeds the provisional amount. When `settledToAccountId` is the original destination: post the settlement entry alone in the destination currency, with no shortfall comparison (the amounts are in different currencies and there is nothing to compare against), and reject if a `feeCategoryId` was supplied. Either way, set status to settled once the second entry posts; do not require the settling account to still be active. Reject: negative `settledAmountMinor`, settling an already-`settled` pending transfer, a `feeCategoryId` that isn't an active Expense-type category, and a `settledToAccountId` that isn't the pending transfer's own source or destination account
- [ ] 2.6 Implement a pending-transfers query for the Home overview — one row per unsettled item, ordered by `initiated_at`
- [ ] 2.7 Update the home overview / net-worth query to compute net position per currency instead of one blended figure, including each pending item's amount in its source currency's net position (excluding a pending transfer whose provisional entry is quarantined or migration-superseded, same as any other excluded posting); label every group total, account balance, and pending-transfer amount with its currency
- [ ] 2.8 Ensure the Transfers-in-transit account is excluded from every financial-account picker, the account-management list, and the home overview's account/group rows — allowlist the pickers to real financial account types, don't rely on excluding it by name
- [ ] 2.9 Route every new write (provisional entry, settlement entry, fee entry) through the same signed/chained write path as `recordTransaction`/`recordTransfer`/`reverseEntry` — no separate ad hoc write mechanism
- [ ] 2.10 Reject reassigning a financial account to an account group with a different currency than its current group (extends `multi-account-support`'s existing group-reassignment API)
- [ ] 2.11 Reject a direct `reverseEntry` call against an entry that is still the open `provisional_entry_id` of a `pending` pending transfer; point the caller at `settlePendingTransfer` instead. Once settled, reversal works normally.

## 3. Unit tests (repository / domain)

- [ ] 3.1 Tests: creating a group requires a currency; an account's display currency is derived from its group
- [ ] 3.2 Tests: group-currency change rejected with active accounts assigned; allowed when the group is empty
- [ ] 3.3 Tests: same-currency transfer behavior is unchanged (regression against `multi-account-support`'s existing transfer tests)
- [ ] 3.4 Tests: known-rate cross-currency transfer posts one complete entry, no `pending_transfers` row is created; a zero or negative amount in either currency is rejected
- [ ] 3.5 Tests: unknown-rate cross-currency transfer posts a provisional entry and creates a `pending_transfers` row with status pending
- [ ] 3.6 Tests: foreign-currency transaction posts the category leg immediately in its native currency, posts a provisional account leg, creates a pending row
- [ ] 3.7 Tests: settlement to the original destination in the destination currency closes the pending transfer with no shortfall comparison and no fee entry, even when the destination-currency amount is numerically less than the source-currency provisional amount
- [ ] 3.8 Tests: settlement to the source account for less than the original amount (same currency) posts a fee entry for the shortfall and fully closes the position
- [ ] 3.9 Tests: settlement with zero amount returned to the source account posts the full original amount as a fee/loss entry
- [ ] 3.10 Tests: a `feeCategoryId` supplied together with a destination-account settlement is rejected; the source-account shortfall invariant (settlement + fee amounts exactly equal the provisional amount) holds whenever it applies; a source-account settlement exceeding the provisional amount is rejected; settling against an account that has since been archived still succeeds
- [ ] 3.11 Tests: the Transfers-in-transit account never appears in any picker and has no single-balance query exposed for it
- [ ] 3.12 Tests: per-currency net position calculation across multiple currencies, including a pending item's amount counted in its source currency's net position; every displayed total/balance is labeled with its currency
- [ ] 3.13 Tests: quarantined and migration-superseded entries remain correctly excluded under per-currency net position (regression against `ledger-integrity-signing`'s exclusion rules), including a quarantined or superseded pending transfer's provisional entry — excluded from net worth, still visible in the Pending Transfers section
- [ ] 3.14 Tests: `onCreate` and `onUpgrade` migration paths, including the currency-backfill prompt path for pre-existing `account_groups` rows (mirror `test/data/database/app_database_migration_test.dart`'s hand-built-old-schema approach)
- [ ] 3.15 Tests: reassigning a financial account to a different-currency group is rejected; reassigning within the same currency still works (regression against `multi-account-support`'s existing reassignment tests)
- [ ] 3.16 Tests: negative settled amount rejected; settling an already-settled pending transfer rejected; a fee category that isn't an active Expense category rejected
- [ ] 3.17 Tests: `settlePendingTransfer` on a `foreignTransaction` pending item always resolves to its own `source_account_id`, ignoring or rejecting a different `settledToAccountId`
- [ ] 3.18 Tests: directly reversing a still-pending provisional entry is rejected; reversing it after settlement succeeds normally

## 4. UI: recording flows

- [ ] 4.1 Update Transfer UI/ViewModel to detect a cross-currency transfer and branch between a known-rate form (both amounts entered) and an unknown-rate form (source amount only, posts provisional)
- [ ] 4.2 Update Record Transaction UI/ViewModel with the same branching when the selected account's group currency differs from the transaction's native currency
- [ ] 4.3 Add a Settle Pending Transfer UI/ViewModel: choose the account that actually received funds, enter the real settled amount, choose an expense category if there's a shortfall to cover
- [ ] 4.4 Add currency selection to account-group creation/edit UI; disable changing it once the group has active accounts

## 5. UI: home overview

- [ ] 5.1 Update Home overview to show net position per currency instead of one blended figure; label every group total and account balance with its currency
- [ ] 5.2 Add a Pending Transfers section to Home overview — one line item per pending item, tappable to open the settle flow, amount labeled with its currency
- [ ] 5.3 Confirm the Transfers-in-transit account never appears in the Home overview's account or group rows
- [ ] 5.4 Add a currency constraint to the account-group reassignment picker (Account management, from `multi-account-support`'s Decision 1/2.9) — only offer same-currency groups as reassignment targets

## 6. Widget / integration coverage and polish

- [ ] 6.1 Widget tests: per-currency net position display; Pending Transfers section rendering
- [ ] 6.2 Widget tests: Transfer UI branching (same-currency / known-rate / unknown-rate) and the Settle UI
- [ ] 6.3 Integration test: full cross-currency transfer lifecycle — initiate provisional, verify it appears pending on Home, settle it, verify net position moves from the source currency to the destination currency
- [ ] 6.4 Integration test: bounced transfer with a retained fee — initiate, settle back to the source account for less than sent, verify the fee posts and the pending item clears
- [ ] 6.5 Run `dart analyze` and fix issues introduced by this change
- [ ] 6.6 Manual smoke: migrate an existing `multi-account-support` database, confirm the currency backfill prompt, create a second-currency group, verify transfer and settlement flows end to end
