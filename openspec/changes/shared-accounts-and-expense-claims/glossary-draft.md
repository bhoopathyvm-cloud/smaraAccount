# Glossary draft (archive into CONTEXT.md on land)

Terms for shared-accounts-and-expense-claims / issue #205. Align wording;
avoid banned synonyms.

**Claim**:
A list of Claim Items with receipts and a status (Draft, Submitted, Partly
approved, Approved, Paid, Rejected). Stored in the company Books Set but
**not** a Journal Entry until an Approver or Owner approves an item.
_Avoid_: expense report (prefer Claim), draft journal entry, reimbursement
request (the Claim is the employee submission; payment is separate).

**Claim Item**:
One line on a Claim: expense Category, amounts (paid currency and company
currency), optional foreign-currency rate, optional Claim Receipt, and a
per-item decision (Approve / Approve different amount / Reject).
_Avoid_: line item alone when the product term is Claim Item; split
(ledger splits are unrelated).

**Claimant**:
A membership role for a person who creates and submits only their own
Claims on company books. On a Claimant-only device they see their claims,
balance, payments, and allowlisted categories — not company banks or other
people.
_Avoid_: employee login, user account, guest (prefer Claimant).

**Approver**:
A membership role that reviews Claim Items (approve, approve different
amount with reason, or reject with reason) and may record payments and
Advances to Claimants. Owner may also approve.
_Avoid_: admin, manager, reviewer (prefer Approver).

**Advance**:
A payment to a Claimant before Claims. Posted as bank ↔ Owed-to; approved
Claim amounts reduce what is owed. Balance copy handles either sign
(company owes Claimant, or Claimant owes company).
_Avoid_: prepaid expense, float, petty cash advance (unless that is the
bank account used).

**Claim Receipt**:
A camera photo, picked image, or PDF attached to a Claim Item, stored
inside the Books Set (`books/<id>/receipts/`), synced on Wi-Fi, included
in a Books Copy, and kept for the life of the books (never auto-deleted
on pay or reject).
_Avoid_: attachment alone when the product term is Claim Receipt; cloud
scan.

**Owed-to Account**:
A liability Financial Account named "Owed to \<name\>" created
automatically when a Claimant is added. Approval posts expense Category ↔
Owed-to; payment posts Owed-to ↔ bank/cash.
_Avoid_: payable vendor bill (this is person-owed for claims), AR/AP
module.
