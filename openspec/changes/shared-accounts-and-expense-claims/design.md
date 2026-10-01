# Design

## Context

See proposal.md for motivation. Constraints that shape this design:

- **Depends on project B** (`linked-devices-and-sync`): Linked devices,
  Peer Sync (mDNS + TLS pinning), Owner/Member membership, books
  switcher (one SQLite file per Books Set), and dual-device harness.
- **No server / no cloud / no relay.** Claims submit and catch up only
  on the same Wi-Fi as B. No remote claim submission in v1.
- **ADR 0004:** private keys never leave the device. Claimants sign
  claim payloads with their device Signing Identity; office devices
  sign approval and payment journal entries with theirs.
- **Golden Rule #7:** posted journal entries are immutable. A Claim is
  deliberately *not* a Journal Entry until an Approver/Owner approves
  an item — approval *creates* entries; rejection never does.
- **Issue #205** closed the product decisions (claim vs books, Claimant
  visibility, per-item decisions, receipts, FX, roles, advances, Add a
  person, spending-limit hints, no personal-books reimbursement). This
  design closes the technical seams.

## Goals / Non-Goals

**Goals:**
- A Claim / Claim Item model stored in the company Books Set but outside
  the posted ledger until approval.
- Approval and payment posting into ordinary double-entry Journal
  Entries against expense categories and auto-created "Owed to \<name\>"
  liability accounts.
- Claimant-scoped UI and sync filter so an employee never sees company
  bank accounts or other people's claims.
- Receipt blobs in the books set, synced and included in Books Copies.
- Role enum extended with Approver and Claimant; "Add a person" QR
  reusing B's join transport.
- Advances that reduce when claims are approved/paid.
- CI coverage via the dual-device harness; physical Claimant phone stays
  manual.

**Non-Goals:**
- Mileage, per diem, receipt OCR/AI, claim PDF/CSV reports, remote
  (off-Wi-Fi) submit, and "add payment to household books" (follow-ups
  from #205).
- Enforcing spending limits (hints only).
- A separate cloud identity or login for employees.
- Changing B's discovery/TLS stack.

## Decisions

1. **Claims live in books-set tables, not as journal entries.**
   Tables (names illustrative): `claims`, `claim_items`,
   `claim_item_decisions`, `claim_receipts` (metadata), receipt blob
   store, `advances`, `claim_category_allowlist`, `claim_spending_hints`.
   Status on a Claim is derived from its items (Draft / Submitted /
   Partly approved / Approved / Paid) per rules below — not a free-form
   override.
   - **Why not draft journal entries:** rejected items must never touch
     the books; Golden Rule #7 forbids deleting drafts-as-entries that
     looked like history.
   - **Why not a side database:** receipts and history must travel with
     Books Copy and Peer Sync of that Books Set.

2. **Approval posts ordinary Journal Entries; payment posts separately.**
   - On **Approve** (or approve-different-amount) of an item: post
     balanced entry expense category (approved company-currency amount)
     ↔ "Owed to \<Claimant\>" liability. Record `postedEntryId` on the
     item decision. Sign with the Approver/Owner device identity.
   - On **Reject**: store reason only; no journal entry.
   - On **Pay** (full approved balance or scheduled payment against
     advances): post "Owed to \<Claimant\>" ↔ chosen bank/cash Financial
     Account. Claim moves toward Paid when owed balance for that claim
     (or overall, when paying advances) is cleared per payment UI.
   - **Alternative rejected:** one combined approve-and-pay entry —
     issue #205 separates review from payment so accounting can approve
     before cash moves.

3. **Claim status derivation.**
   - Draft: not yet submitted (editable by Claimant).
   - Submitted: submitted, no item decisions yet (or all pending).
   - Partly approved: at least one item approved and at least one still
     pending or rejected (or mix of approved/rejected with pending).
   - Approved: every item decided and at least one approved; none
     pending; owed amount may still be unpaid.
   - Paid: approved amount for the claim has been fully settled by
     payment entries (including advance offset).
   Exact edge for "all rejected" → treat as terminal rejected/closed
   under Approved-family UI as "Rejected" display for Claimant (all
   items rejected, nothing owed) — surface as status **Rejected** in
   Claimant copy even if internal enum folds under decided-with-zero-
   approved. Spec names Draft, Submitted, Partly approved, Approved,
   Paid, and Rejected (all items rejected).

4. **Claimant-scoped sync filter.**
   A device whose only role on the books is Claimant receives:
   - membership row for self;
   - claim-category allowlist and spending-limit hints;
   - that Claimant's claims, items, decisions, receipts, advances, and
     payments that affect their owed balance;
   - public keys needed to verify those payloads.
   It does **not** receive other journal entries, other people's claims,
   bank account registers, or full category charts beyond the allowlist.
   Owner/Approver/Member devices continue full sync as in B.
   - Filter is applied when building outbound batches for a Claimant
     peer (serverless: each peer knows the remote role from membership).
   - **Alternative rejected:** full books on Claimant phone with UI
     hiding — issue #205 requires they never see company banks; UI-only
     hide fails if they open a Books Copy or DB.

5. **"Owed to \<name\>" auto-account.**
   On successful "Add a person" with Claimant role, create a liability
   Financial Account named "Owed to \<displayName\>" in a suitable
   liability group (reuse or seed a "People owed" / payables group in
   company books). Link `membership.owedToAccountId`. Archive (do not
   delete) when the person is removed and balance is zero; if balance
   non-zero, Owner warning already applies and account stays until
   cleared.

6. **"Add a person" reuses B's QR join with a person-role offer.**
   QR payload gains `personRole: Claimant|Approver|Member|Owner` (or a
   set of roles) and display name. Same TLS cert exchange and books-set
   id. Difference from "Add a device": UX copy and default role
   Claimant; creates owed-to account; Claimant-scoped sync thereafter.
   One physical device can still hold household Books Set + company
   Books Set (books switcher).

7. **Roles are a set on membership, not a single enum.**
   B stored one role Owner|Member. Extend to a set/bitfield so one
   person can be Approver+Member, or Owner+Approver, etc. Capability
   checks: Owner ⊃ membership admin; Approver ⊃ decide claim items and
   record payments to claimants; Member ⊃ bookkeeping as today;
   Claimant ⊃ create/submit own claims. Sole-Owner claim rules from B
   unchanged.

8. **Receipt storage.**
   - Metadata row on claim item; blob in books-set directory
     `books/<id>/receipts/<receiptId>` (or SQLite blob table — prefer
     files beside DB so Books Copy zips them and large PDFs do not bloat
     WAL).
   - Photos: decode, compress to JPEG ~1 MB target (quality loop), store.
   - PDFs: store as-is if ≤ 5 MB; reject above with plain message.
   - Sync: ReceiptBlob messages after ClaimBatch item that references
     them; content-addressed or id+hash so duplicates skip.
   - Books Copy: include `receipts/` tree for the set.
   - Never auto-delete.

9. **Foreign currency on items.**
   Item stores `paidCurrency`, `paidAmount`, optional
   `employeeStatedRate`, resolved `rateUsed`, `companyCurrencyAmount`.
   Default rate: existing reference-rate / app rate for expense date
   when employee leaves rate blank (reuse lookup path; if offline/missing,
   require typed rate or company-currency amount before submit).
   Approver can edit rate before approve; posted amount is company
   currency. Does **not** create Pending Transfer — claims post the
   known company-currency amount on approval (known-rate path).

10. **Advances.**
    Advance is a payment Journal Entry bank → "Owed to \<name\>" *or* a
    dedicated advance record that posts the same shape, tagged
    `advanceId`. Approved claim amounts reduce the Claimant's owed
    balance (which may go negative from the company's view as "employee
    owes company" when advances exceed claims — Claimant balance copy
    handles both signs per issue). Payment UI can apply approved claims
    against outstanding advances without a second bank movement when
    offsetting.

11. **Spending-limit hints.**
    Separate from `monthly-category-limits` (month-to-date spent). Claim
    hints are optional per allowlisted category ("at most N per unit"
    with unit label e.g. night). Shown on Claimant item form and
    Approver review; never block submit or approve.

12. **No household reimbursement in v1.**
    Paying a claim never writes into another Books Set. Future follow-up
    may offer an explicit cross-set action; do not invent a sync bridge.

## Risks / Trade-offs

- **[Claimant sync filter bugs leak books]** → Contract tests: outbound
  batch to Claimant-only peer contains no non-allowlisted accounts or
  foreign claims; treat filter as security boundary equal to role gates.
- **[Large receipt PDFs slow Wi-Fi sync]** → 5 MB cap; sync receipts
  after claim metadata; resume by receipt id; Books Copy remains the
  bulk path.
- **[Role set migration from B's single role]** → Additive column or
  parallel roles table; map Owner→{Owner}, Member→{Member}; default
  Claimant-only for new person joins.
- **[Approver offline while Claimant travels]** → Accepted: submit waits
  for office Wi-Fi; Draft stays on phone until sync (B rule).
- **[All-rejected claim UX]** → Explicit Rejected status so Claimant is
  not stuck on Submitted.
- **[Dependency on B]** → Tasks require B merged/available; do not ship
  Claims UI before membership + sync + switcher work.

## Migration Plan

1. Schema bump on company books: claim tables, receipt files dir, role
   set, owed-to account link, allowlist, hints, advances. Household-only
   sets gain empty tables harmlessly (or migrate lazily on first claim
   feature open).
2. Migrate membership role column → role set.
3. Ship domain + repositories + Claimant filter before enabling Add a
   person / Claims UI.
4. Enable Approver queue and posting, then advances, then receipt
   polish.
5. **Rollback:** additive schema; older app versions ignore claim
   tables. Claimant devices on old builds cannot open Claims UI — copy
   says update required.
6. Before archive: `CONTEXT.md` terms (Claim, Claim Item, Claimant,
   Approver, Advance, Claim Receipt, Owed-to Account); user guide;
   architecture note that claims are off-ledger until approval.

## Open Questions

None that block specs or tasks. Image-compression library choice and
exact receipt file vs blob-table storage are apply-phase details as long
as size caps, Books Copy inclusion, and sync semantics hold.
