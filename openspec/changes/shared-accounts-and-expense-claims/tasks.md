# Tasks

## 1. Prerequisites and schema foundations

- [x] 1.1 Confirm `linked-devices-and-sync` (project B) is merged or available on the implementation branch — Linked devices, Peer Sync, Owner/Member, books switcher, and dual-device harness compile and their unit tests pass
- [x] 1.2 Extend membership schema from single role to a role set (Owner, Approver, Member, Claimant) with migration mapping Owner→{Owner}, Member→{Member}; add `owedToAccountId` and person display fields — verify migration test from the prior B schema version
- [x] 1.3 Add Drift schema for claims, claim_items, claim_item_decisions, claim_receipts metadata, advances, claim_category_allowlist, and claim_spending_hints; create `books/<id>/receipts/` storage path helper — verify `app_database_migration_test` upgrades and empty claim tables on household sets
- [x] 1.4 Document new glossary terms in a draft note for archive (Claim, Claim Item, Claimant, Approver, Advance, Claim Receipt, Owed-to Account) aligned with design — verify terms match issue #205 wording and avoid banned synonyms

## 2. Owed-to accounts and role gates

- [x] 2.1 Implement automatic creation of "Owed to \<name\>" liability Financial Account when a Claimant person is added; link on membership — verify unit tests that Add Claimant creates the account once and reuses it
- [x] 2.2 Implement role-gate helpers (canApproveClaims, canManageMembership, canBookkeep, canSubmitOwnClaims) over the role set — verify unit tests for single- and multi-role combinations
- [x] 2.3 Build "Add a person" UI/QR flow reusing B's join transport with person-role offer (default Claimant) — verify widget/unit tests for successful Claimant join and same-Wi-Fi refusal off LAN
- [ ] 2.4 Implement remove-person flow with warning for open Claims and non-zero owed balance; history and receipts remain — verify unit/widget tests for warning content and that past claims stay after removal

## 3. Claim domain and Claimant surface

- [x] 3.1 Implement Claim / Claim Item repository: create Draft, edit items, derive status (Draft, Submitted, Partly approved, Approved, Paid, Rejected), reject posting until approval — verify unit tests that submit does not create Journal Entries
- [x] 3.2 Implement claim-category allowlist and spending-limit hints (show only, never block) — verify unit/widget tests that disallowed categories are hidden and over-hint submit still succeeds
- [x] 3.3 Implement foreign-currency Claim Item fields (paid currency/amount, optional employee rate, app rate fallback, Approver-correctable rate, company-currency amount) — verify unit tests for stated rate, app-rate fallback, and Approver override before approve
- [x] 3.4 Build Claimant UI: claims list, claim editor, balance copy ("…owes you" / "You owe…"), payments list, allowlisted categories only — verify widget tests that bank registers and other people are not reachable from Claimant-only role
- [x] 3.5 Wire `app-navigation-policy` Claimant-only gates for the active Books Set — verify policy unit tests block bank routes and allow own Claims routes

## 4. Receipts

- [x] 4.1 Implement receipt attach (camera, image pick, PDF pick), photo compression to ~1 MB, PDF reject above 5 MB, store under books receipts path — verify unit tests for compression target, PDF size refusal, and metadata row linkage
- [x] 4.2 Implement "Receipt required above ___" books setting (default 0) and enforce on submit — verify unit tests for threshold 0 and below-threshold omit
- [x] 4.3 Ensure receipts are never auto-deleted on pay/reject — verify unit tests that paid and rejected items still load receipt bytes

## 5. Approver decisions and posting

- [x] 5.1 Implement per-item Approve / Approve different amount (reason required) / Reject (reason required) and status derivation — verify unit tests for mixed decisions → Partly approved and all-rejected → Rejected
- [x] 5.2 On approve, post Journal Entry expense Category ↔ Owed-to account for approved company-currency amount, signed by Approver device — verify ledger tests for balance-zero entry and no post on reject
- [x] 5.3 Implement payment posting Owed-to ↔ bank/cash and Paid status when claim approved amount is settled — verify unit tests for payment entry and Claimant balance update
- [x] 5.4 Build Approver review queue UI showing items, both currencies, receipts, hints, and decision actions — verify widget tests for reason-required paths and successful approve

## 6. Advances

- [x] 6.1 Implement Advance recording (payment to Claimant before claims) and balance reduction when claims are approved / offset — verify unit tests for advance then approve and Claimant balance both signs
- [x] 6.2 Expose Advances on Approver payment UI and Claimant balance/payments views — verify widget tests that Claimant sees advances after sync fixture

## 7. Peer sync, Books Copy, books switcher

- [x] 7.1 Extend Peer Sync payloads with ClaimBatch, decision ops, AdvanceOps, and ReceiptBlob; keep private keys out — verify dual-device harness: submit on B, sync, appear on A
- [x] 7.2 Implement Claimant-scoped outbound filter (own claims, receipts, advances, payments affecting balance, allowlist, hints only) — verify harness/contract tests that Claimant peer receives no unrelated bank Journal Entries
- [x] 7.3 Include claims tables and receipts tree in Books Copy save/restore — verify unit tests that restore brings back claim + receipt bytes without private keys
- [ ] 7.4 Books switcher: Claimant-only membership on company set shows Claimant surface; household set unchanged — verify widget tests for switch to company vs household

## 8. Acceptance, localization, docs

- [x] 8.1 Extend dual-device harness group for Claims (submit → sync → approve → pay, scoped sync, receipt blob); flag physical Claimant-phone manual — verify harness group runs without physical devices and manual group is skipped by default
- [ ] 8.2 Add English ARB strings for Claims, statuses, Approver actions, reasons, advances, Add a person, Claimant balance, receipts, hints; run `flutter gen-l10n` — verify gen-l10n succeeds and widget tests use new keys
- [x] 8.3 Update `docs/user-guide.md` for Claims, roles, receipts, advances, Add a person, Claimant limits; apply `CONTEXT.md` glossary on land; note claims are off-ledger until approval in architecture docs — verify guide sections exist and do not claim remote submit or household reimbursement

## 9. Integration check

- [x] 9.1 Run `flutter analyze` and unit/widget suites touched by this change; fix regressions — verify clean analyze and tests for claims, receipts, roles, sync filter, navigation
- [ ] 9.2 Run dual-device harness claims group via `tool/run_acceptance_tests.sh` on the available CI/Linux target; run GUI acceptance subsets that exist for Claims on macOS when available — verify harness group passes (note environment limits for macOS GUI / physical phones without checking boxes you cannot satisfy)
- [ ] 9.3 Manual spot-check when two devices available: Add a person Claimant, submit claim with receipt on office Wi-Fi, approve different amount, pay, confirm Claimant balance — record result in this task (leave unchecked if physical devices unavailable)
