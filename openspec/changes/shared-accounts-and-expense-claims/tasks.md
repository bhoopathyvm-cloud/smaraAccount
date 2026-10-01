## 0. Prerequisites and spec reconciliation

- [ ] 0.1 Confirm `books-copy-and-continuation` and `linked-devices` are implemented and archived (`openspec/specs/linked-devices/spec.md` and `openspec/specs/multiple-books/spec.md` exist); verify `openspec validate shared-accounts-and-expense-claims --strict` after rebasing on main
- [ ] 0.2 After rebasing, move the role extension into a MODIFIED delta of `linked-devices` "Owner and Member Roles" (adding Approver and Claimant), and add MODIFIED deltas for `books-copy` (copy format with receipts) and `local-network-sync` (scoped sync); verify with `openspec validate --strict`

## 1. Turning claims on

- [ ] 1.1 "Expense claims" switch for a set of books (Owner only), with the allowed-categories list, "Receipt required above" (default 0) and per-category limit hints; verify with `test/ui/features/claims/claim_settings_test.dart`

## 2. Claim event log (expense-claims)

- [ ] 2.1 Claim event types as signed control records (created, item added or changed while Draft, submitted, acknowledged, item decided, payment recorded, advance recorded), and the computed claim state with statuses; verify with `test/domain/claims/claim_state_test.dart` covering every status transition
- [ ] 2.2 Item validation (allowed category, amount, currency, a receipt when required) and reason required for reduce or reject; verify with `test/domain/claims/claim_item_draft_test.dart`

## 3. Approval, payment and advances

- [ ] 3.1 Approving posts the expense / "Owed to <name>" entry in the same transaction as the decision event; rejecting posts nothing; changing a decision uses Fix; verify with `test/data/repositories/claim_posting_test.dart` and full chain verification
- [ ] 3.2 Payments and advances post against "Owed to <name>", and the balance wording reads "Acme owes you N" or "You owe Acme N"; verify with `test/domain/claims/claimant_balance_test.dart`
- [ ] 3.3 Foreign currency: original amount, currency, rate and rate source; proposed reference rate; Approver correction stored with the decision; verify with `test/domain/claims/claim_currency_test.dart`

## 4. Receipts (claim-receipts)

- [ ] 4.1 Capture from camera or library (`image_picker`) and PDF (`file_picker`), with permissions asked on first use; verify with widget tests using fake pickers
- [ ] 4.2 Compression (JPEG about 1 MB, long edge at most 2000 px), PDF limit 5 MB, content-addressed storage and SHA-256 in the item event; verify with `test/data/claims/receipt_store_test.dart` (a swapped receipt fails verification)
- [ ] 4.3 Books Copy format v2 (container with `db`, `settings`, `receipts/`, encrypted as a whole and streamed) with the v1 reader kept; verify with `test/domain/backup/books_copy_file_test.dart` v1 and v2 cases and a restore round trip with receipts

## 5. Roles and scoped sync (shared-account-access)

- [ ] 5.1 Role sets per identity (Owner, Member, Approver, Claimant) changed by signed control records; verify with `test/domain/linked_devices/roles_test.dart` additions
- [ ] 5.2 "Add a person" as Claimant, creating "Owed to <name>" automatically and linking the device by QR; verify with `test/data/repositories/add_claimant_test.dart`
- [ ] 5.3 Scope tagging (`person:<id>`, `claimants`) on events, entries and master data; scoped sync sends only in-scope records plus their signing identities; verify with `test/data/sync/scoped_sync_test.dart` that a Claimant database contains no out-of-scope rows
- [ ] 5.4 Claimant-device verification: per-record hash and signature for received records, full continuity for its own chain; verify with a tampered received record in `scoped_sync_test.dart`
- [ ] 5.5 Removing a Claimant: warning with open claims and balance, history kept; verify with `test/ui/features/linked_devices/remove_claimant_test.dart`
- [ ] 5.6 Delivery state "Waiting to send" until an acknowledgement event arrives; verify in `scoped_sync_test.dart`

## 6. Screens

- [ ] 6.1 Claimant home for company books: claims list with statuses, balance, payments, "New claim"; verify with widget tests
- [ ] 6.2 Claim editor: items, receipts, currency and rate, limit hint, Submit; verify with widget tests
- [ ] 6.3 Approver queue and claim review: per-item Approve, Approve different amount, Reject with reason, Pay, Record advance; verify with widget tests
- [ ] 6.4 People and roles screen for Owners; verify with widget tests

## 7. Localization (43 languages)

- [ ] 7.1 Add the new strings to `lib/l10n/app_en.arb` in plain wording (Claim, Submit, Approve, Reject, reasons, balances, receipts, Waiting to send); verify `flutter gen-l10n`
- [ ] 7.2 Translate into all 43 ARB files and update `untranslated.json`; verify `test/l10n/locale_packs_test.dart`, and run `tool/run_localized_acceptance_tests.sh` for the claims screens

## 8. Integration and acceptance tests (all suites)

- [ ] 8.1 New acceptance group `expense_claims` (Owner, Approver and Claimant instances over the loopback transport): add a Claimant, create and submit a claim with a receipt, approve one item, reduce one with a reason, reject one, pay, check both balances, and check the Claimant database holds no out-of-scope data; verify `tool/run_acceptance_tests.sh -d macos expense_claims` passes
- [ ] 8.2 Acceptance cases: advance larger than claims, a foreign-currency item with rate correction, a missing receipt blocking submission, a Books Copy with receipts restoring on a fresh install, removing a Claimant with an open balance; verify on macOS
- [ ] 8.3 Re-run the `linked_devices`, `multiple_books`, `books_copy` and `core_ledger` acceptance groups to confirm no regression; verify each passes on macOS
- [ ] 8.4 Check `integration_test/app_test.dart` and the instrument and market integration tests still pass
- [ ] 8.5 If store screenshot or preview tests exist (PR #198), add a claims screen; verify `tool/capture_store_screenshots.sh`
- [ ] 8.6 CI: confirm `flutter-ci.yml`, `acceptance-suite-nightly.yml`, `localized-smoke.yml` and `linux-desktop.yml` cover the new tests; verify a green CI run on the PR
- [ ] 8.7 Full suite per CLAUDE.md: `tool/run_acceptance_tests.sh -d macos` green
- [ ] 8.8 Real-device run: Owner and Approver on a Mac, Claimant on an Android phone and an iPhone, on office-style Wi-Fi; record a claim with camera receipts, approve and pay; record the results here with dates and devices

## 9. Docs and glossary

- [ ] 9.1 `CONTEXT.md`: add Claim, Claim Item, Claimant, Approver, Advance, Receipt, Owed-to Account, Scope; verify a glossary review
- [ ] 9.2 Privacy policy: receipts and claims stay on company devices and the local network; Claimant devices hold only their part; verify `mkdocs build --strict`
- [ ] 9.3 User guide and website (`whats-built.md`): expense claims for small businesses; verify `mkdocs build --strict`
