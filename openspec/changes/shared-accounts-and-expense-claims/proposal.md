## Why

Small businesses want to run travel expenses in Smara. Today, an employee keeps paper receipts, fills in a spreadsheet, and waits for the accounting team to type it all in again. With Linked Devices (`linked-devices`, #209), a company can give each employee their own account on their own phone. The employee records costs with receipt photos, the claims sync on the office Wi-Fi, the accounting team decides item by item, and the payment syncs back. The design was settled in a grilling session and recorded in issue #205.

## What Changes

- **Claims, outside the books until approved.** An employee's expense items form a **Claim**: a list with receipts and a status, outside the books.
  - **Approval** creates records in the company books ("Travel expense 120 / Owed to Ravi 120").
  - **Payment** creates "Owed to Ravi −120 / Bank −120".
  - **Rejected items** never touch the books.
- **Statuses:** Draft, Submitted, Partly approved, Approved, Paid. The claim's status follows from its items.
- **A decision for each item:**
  - Approve.
  - Approve a different amount (a reason is required).
  - Reject (a reason is required).
- **Receipts.**
  - **Capture:** a camera photo, or a picked image or PDF.
  - **Required?** A company setting "Receipt required above ___", default 0, meaning always required.
  - **Size:** photos compressed to roughly 1 MB; PDFs kept as they are up to 5 MB.
  - **Storage:** inside the books, synced over Wi-Fi, included in a Books Copy, and kept for as long as the books exist.
- **Foreign currency.** An item is recorded in the currency paid. The employee may type the card-statement rate; otherwise the app's rate for the expense date is used. The approver sees both currencies and can correct the rate, and the books record the approved company-currency amount.
- **Advances.** A payment to an employee before a trip. Approved claims reduce what they owe back. Their balance shows "Acme owes you 30" or "You owe Acme 20".
- **Roles for company books** (extending the Owner and Member roles from `linked-devices`):

  | Role | Can |
  |---|---|
  | **Owner** | Everything |
  | **Approver** | Review, approve, adjust, reject and record payments |
  | **Member** | Normal bookkeeping |
  | **Claimant** | Only their own claims and balance |

  One person can hold several roles.
- **What a Claimant sees:**
  - their claims and statuses;
  - the reasons for decisions;
  - their balance and the payments made to them;
  - the expense categories the company allows for claims.

  They never see company bank accounts, other employees, or any other part of the books.
- **Adding an employee.** "Add a person", choose the role Claimant, and link their phone by QR code. The account "Owed to <name>" is created automatically.
- **An employee leaving.** The Owner is warned about open claims and balances, and can still remove them. History and receipts stay.
- **Spending limits as hints.** Optional per-category limits ("Hotel at most 150 per night") are shown as hints to both sides and are never enforced automatically.
- **Submitting.** Claims are prepared anywhere. They arrive on the office Wi-Fi, under the same-Wi-Fi rule from `linked-devices`.
- **Not in this version:**
  - mileage;
  - per-diem allowances;
  - reading amounts from receipts automatically;
  - claim reports as PDF or CSV;
  - adding reimbursements to the employee's household books;
  - remote submission.

## Capabilities

### New Capabilities
- `expense-claims`: the claim lifecycle, item decisions, statuses, accounting records on approval and payment, foreign currency, advances, spending-limit hints, and submitting on the shared Wi-Fi.
- `claim-receipts`: capturing, requiring, compressing, storing, syncing and keeping receipt images and PDFs.
- `shared-account-access`: the Approver and Claimant roles, partial visibility so a Claimant's device receives only their part of the books, adding an employee with an automatic "Owed to" account, and removing a departing employee.

### Modified Capabilities
None. This change builds on `linked-devices` (#209), whose capabilities are not yet in `openspec/specs/`. The roles and visibility rules extending `linked-devices` are therefore specified in `shared-account-access`, and are reconciled when both changes are archived (see tasks 0.1 and 0.2).

## Impact

- **Depends on:** `books-copy-and-continuation` and `linked-devices` being implemented and archived first.
- **Database:**
  - claims, claim items, decisions and receipt blobs;
  - advance links, and Approver and Claimant roles;
  - per-category claim-limit hints;
  - use of the `visibility_scope` hook from `linked-devices` for partial sync.
- **Sync:** a Claimant's device exchanges only records in its own scope. That needs per-scope verification, because the device does not hold the whole chain set.
- **Platform:** camera and photo-library permissions, plus a file picker for PDFs.
- **UI:**
  - **Claimant home:** claims, balance, payments.
  - **Claim editor:** items, receipts, currency.
  - **Approver screens:** queue, item decisions, payment, advances.
  - **Settings:** company claim settings, people and roles.
- **Localization:** new strings in all 43 languages.
- **Docs:** `CONTEXT.md` (Claim, Claim Item, Claimant, Approver, Advance, Receipt), privacy policy (receipts stay on devices and the local network), user guide and website.
- **Tests:** unit, widget, integration and acceptance suites, with multi-device scenarios over the loopback transport, plus real-device runs.
