## Context

See proposal.md and issue #205. This design builds on two earlier changes:
- **`books-copy-and-continuation`:** Books Copy, Restore, Continuation.
- **`linked-devices`** (#209):
  - several sets of books per device, one database file each;
  - one chain per signing identity;
  - signed control records;
  - the signed master-data operation log with hybrid logical clocks;
  - verify-then-add sync over a Noise channel;
  - Owner and Member roles;
  - a `visibility_scope` column reserved on entries and operations.

Constraints:
- Entry hashes cover the account ids of their postings, so an entry can't be repointed after posting.
- A Books Copy (from A) is an encrypted `{db, settings}` payload, which can't hold large binary receipts efficiently.
- Exchange-rate lookup already exists (`reference-exchange-rate-lookup`).

## Goals / Non-Goals

**Goals:**
- Claims and decisions are tamper-evident like entries.
- Only approved amounts and payments enter the books.
- A Claimant's device holds only their part, and still verifies what it receives.
- Receipts are integrity-protected and travel with the books.

**Non-Goals:**
- Mileage, per diem, receipt reading (OCR or AI), claim reports.
- Remote submission, and anything that needs a server.
- Approval workflows with several approval levels.
- Payroll or tax handling.

## Decisions

1. **Claims are a signed event log, not ledger entries.**
   - Every claim action is a signed, chained control record in the acting device's chain. The actions are: created, item added or changed while Draft, submitted, item decided, payment recorded, advance recorded.
   - The claim's current state is computed from these events. Items can change only while Draft. After submission, a correction is a new event.
   - Why: it reuses the chain and verification machinery from `linked-devices`, so claims get the same tamper evidence without polluting the books with rejected items.
   - Alternative: separate mutable claim tables. Rejected, because claims are evidence and should be as tamper-evident as entries.

2. **Approval and payment post ordinary entries.**
   - The Approver's device posts the entry (expense category / "Owed to <name>") in the same transaction as the "item decided" event. The event references the entry id, and the entry's description references the claim item.
   - Payment: company account / "Owed to <name>".
   - Advance: "Owed to <name>" / company account. The "Owed to" account is a liability whose balance sign tells who owes whom.
   - Changing a decision later uses the existing Fix (reversal), plus a new decision event.

3. **Partial visibility with scope `person:<identityId>`.**
   - These records are tagged with the Claimant's scope:
     - the Claimant's claim events;
     - decisions and payments for their claims;
     - entries posting to their "Owed to" account;
     - the allowed-category master data (tagged `claimants`).
   - Sync to a Claimant device sends only records in its scope, plus the public identities that signed them.
   - The Claimant device verifies each received record's hash and signature individually. Chain continuity is checked only for its *own* chain, because it doesn't hold the other chains in full.
   - Full chain verification stays the job of Owner, Approver and Member devices, which hold everything.
   - Alternative: send whole chains and hide them in the UI. Rejected, because the data would be on the employee's phone and could be read from a Books Copy or the database file.

4. **Roles are a set per identity.** The identity's `role` (from `linked-devices`) becomes a set: Owner, Member, Approver, Claimant. Roles change only through signed control records. A person is represented by their device identity and display name. Several devices for one Claimant are possible, each linked and scoped the same way.

5. **Receipts are content-addressed files, referenced by hash.**
   - Storage: `books/<booksId>/receipts/<sha256>.<ext>`.
   - Integrity: the "item added" event includes each receipt's SHA-256, so a swapped or edited receipt fails verification.
   - Compression: photos are compressed on the device before hashing (JPEG at about 1 MB, long edge at most 2000 px). PDFs are stored as they are up to 5 MB.
   - Sync: receipts are sent as separate chunked messages after the events that reference them. A missing receipt shows "Receipt not received yet".
   - **Books Copy format v2:** a container (zip, stored without compression, then encrypted as a whole with the existing scheme) holding `db`, `settings` and `receipts/`. The v1 reader stays for older copies.
   - Alternative: blobs inside SQLite. Rejected, because the database would grow by gigabytes and a v1 copy is a single base64 payload held in memory.

6. **Foreign currency.** Each item stores the original amount, currency, rate, and rate source (`card` or `reference`). Approval stores the final rate and the company-currency amount used in the entry. Proposed rates come from the existing reference-rate lookup, which needs the internet and is opt-in. If it's unavailable, the Claimant or Approver types the rate.

7. **Limit hints** are master-data fields on the allowed category (`claimLimitMinor`, `claimLimitPer` = item, night or day). They are shown in both editors and never applied automatically.

8. **Delivery state.** A submitted claim is "Waiting to send" until a company device acknowledges the submit event (a signed acknowledgement event), then "Submitted".

## Risks / Trade-offs

- **[Receipts make the books large]** → Compression, plus a storage summary in Settings. Copies are streamed, never held in memory. Older-than-N-years archiving is a future follow-up, never automatic deletion.
- **[Claimant devices verify less]** → Per-record signatures still prevent forged or altered records. Full continuity is checked on company devices. The limitation is documented in the design and the privacy policy.
- **[An employee's phone is lost with receipts on it]** → `linked-devices` remove-and-erase, plus App Lock recommended for Claimants. The data on it is only that employee's own claims.
- **[Disagreement over exchange rates]** → Both currencies and the rate source are shown and kept, and the Approver's final rate is recorded with the decision.
- **[Books Copy format v2 changes A's file]** → The v1 reader is kept. v2 is written only when receipts exist, and is covered by tests.

## Migration Plan

1. Ship after `linked-devices` is archived.
2. No migration for household books: claims are available only in books where an Owner turns on "Expense claims".
3. Turning it on creates the allowed-categories list and the claim settings.
4. Rollback: turning claims off hides the screens. Posted entries stay, like any other entries.
