## Why

A small business that runs travel expenses in Smara today has no way for
employees to submit receipts on their phones and for the office to
approve and pay them inside the same books. Project B (`linked-devices-
and-sync`) gave Linked devices, Peer Sync on Wi-Fi, Owner/Member roles,
and several Books Sets on one device — the foundation employees need to
hold company books beside household books. This change is project C of
the three agreed in the 2026-10 grilling session (issue #205): shared
accounts and expense claims, still with no server.

## What Changes

- **Claims outside the books until approved.** An employee's items form a
  **Claim** (list with receipts and status). Approval creates journal
  entries in the company books ("Travel expense / Owed to \<name\>");
  payment creates ("Owed to \<name\> / Bank"). Rejected items never
  touch the books.
- **Claimant sees only their slice.** Their own claims and statuses
  (Draft, Submitted, Partly approved, Approved, Paid), rejection
  reasons, balance ("Acme owes you…" / "You owe Acme…"), payments to
  them, and the expense categories the company allows for claims. They
  never see company bank accounts, other employees, or the rest of the
  books.
- **Per-item decisions.** Approver (or Owner) chooses Approve, Approve a
  different amount (reason required), or Reject (reason required) per
  item. Claim status follows from its items.
- **Receipts.** Camera photo, or picked image/PDF; company setting
  "Receipt required above ___" (default 0 = always); photos compressed
  to ~1 MB; PDFs kept as-is up to 5 MB; stored inside the books, synced
  over Wi-Fi, included in a Books Copy; kept as long as the books
  exist.
- **Foreign currency on claim items.** Recorded in the currency paid;
  optional card-statement rate from the employee, else the app's rate
  for the expense date; Approver sees both currencies and can correct
  the rate; books post the approved company-currency amount.
- **Roles** extending B: **Owner**, **Approver** (accounting),
  **Member** (bookkeeping), **Claimant** (employee). One person can hold
  several roles.
- **Advances.** Payment to the employee before claims; approved claims
  reduce the advance balance.
- **Submit on office Wi-Fi.** Claims prepared on the road arrive at the
  office only on the office Wi-Fi (B's Wi-Fi-only rule).
- **Add a person.** Owner links an employee's phone by QR with role
  Claimant; "Owed to \<name\>" is created automatically.
- **Employee leaving.** Owner is warned about open claims and balances,
  and can still remove them; history and receipts stay in the company
  books.
- **Spending limits as hints only.** Optional per-category limits (e.g.
  "Hotel at most 150 per night") shown to Approver and Claimant; never
  enforced automatically.
- **No personal-books reimbursement in v1.** Approved payments do not
  appear in the employee's household Books Set.

**Out of scope (follow-ups, not this change):** mileage, daily
allowances / per diem, automatic receipt OCR / AI amount reading, PDF or
CSV claim reports, "Add this payment to my household books", and
submitting claims outside office Wi-Fi.

## Capabilities

### New Capabilities
- `expense-claims`: Claim lifecycle outside the ledger until approval;
  claim items with per-item approve / approve-different-amount / reject;
  claim statuses; posting on approval and on payment; advances;
  Claimant-visible balance and payments; company claim-category
  allowlist; foreign-currency claim items; spending-limit hints;
  Claimant-restricted surface of company books.
- `claim-receipts`: attaching camera photos, picked images, or PDFs to
  claim items; receipt-required threshold setting; photo compression and
  PDF size cap; storage inside the books; Peer Sync and Books Copy
  inclusion; retention for the life of the books.

### Modified Capabilities
- `linked-devices`: extend membership roles with Approver and Claimant;
  "Add a person" (QR link for a person, not only a device); automatic
  "Owed to \<name\>" Financial Account on Claimant join; remove-person
  flow with open-claims / balance warning.
- `peer-sync`: sync claim payloads, receipt blobs, and advance metadata
  over the same Wi-Fi path; Claimant peers receive only their own claims
  and related payments / balance, not full books.
- `books-copy`: a Books Copy of company books includes claims history and
  receipt attachments for that set.
- `books-switcher`: a device may hold household books and company books;
  when the active set is company books and the person's role is Claimant
  only, the UI is the Claimant surface (not full bookkeeping).
- `app-navigation-policy`: Claimant-only role gates navigation away from
  bank accounts, other people, and full register/settings that expose
  company books beyond claims.
- `acceptance-test-suite`: dual-device harness coverage for claim submit /
  sync / approve / pay; Claimant visibility assertions; physical
  Claimant-phone runs stay manual.
- `user-guide`: documents Claims, roles (Owner / Approver / Member /
  Claimant), receipts, advances, Add a person, and Claimant limits.
- `household-product-positioning`: product promise includes small-
  business expense claims on Linked devices, still with no server
  holding books or keys.

## Impact

- **Code added (high level):**
  - claim / claim-item / advance domain models and repositories
    (outside posted journal entries until approval);
  - approval and payment posting into company books (expense category +
    "Owed to \<name\>" liability; then liability + bank);
  - receipt capture, compression, and blob storage keyed to claim items
    inside the books set;
  - Claimant Home / claim list / claim editor UI; Approver review queue;
  - role gates for Approver and Claimant on top of B's Owner/Member;
  - "Add a person" QR flow reusing B's join transport with a person-role
    offer.
- **Code changed:**
  - linked-device membership schema (role enum, person vs device,
    owed-to account id);
  - peer-sync payloads (ClaimBatch, ReceiptBlob, AdvanceOps) and
    Claimant-scoped sync filter;
  - Books Copy export/import for receipt blobs and claim tables;
  - books switcher / navigation when active set is Claimant-only;
  - Settings for receipt threshold, claim categories, spending-limit
    hints.
- **Localization:** ARB strings for Claims, statuses, Approver actions,
  reasons, advances, Add a person, Claimant balance copy, receipt
  prompts, and spending-limit hints.
- **Tests:** unit/widget for claim lifecycle and posting; dual-device
  harness for submit→sync→approve→pay; Claimant visibility tests;
  acceptance groups for claims (CI harness + manual physical).
- **Docs:** `CONTEXT.md` glossary (Claim, Claim Item, Claimant,
  Approver, Advance, Claim Receipt, Owed-to Account), user guide,
  architecture note that claims are not journal entries until approved.
- **Dependencies:** camera / image_picker / file picker already used or
  equivalent; image compression; no new backend service.
- **Prerequisite:** builds on `linked-devices-and-sync` (project B):
  Linked devices, Peer Sync, Owner/Member, books switcher. Do not ship
  Claims before those land.
