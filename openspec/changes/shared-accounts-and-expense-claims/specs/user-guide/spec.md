## ADDED Requirements

### Requirement: User Guide Documents Expense Claims and Shared Roles
The user guide SHALL document expense Claims (Draft through Paid and Rejected), per-item Approve / Approve different amount / Reject with reasons, receipts (camera, image, PDF, size limits, receipt-required threshold), foreign-currency claim items, Advances, spending-limit hints (not enforced), Add a person by QR, roles Owner / Approver / Member / Claimant, Claimant-only visibility, office Wi-Fi submit via sync, and that payments do not appear in household books in the first version. The guide SHALL NOT describe follow-ups that have not shipped (mileage, per diem, receipt OCR, remote submit, claim PDF/CSV reports).

#### Scenario: Claims section exists
- **WHEN** a user reads the user guide after this change ships
- **THEN** it explains how employees submit Claims, how Approvers decide items, how payments work, and what Claimants can and cannot see

#### Scenario: Roles include Approver and Claimant
- **WHEN** a user reads the Linked devices or Claims roles section
- **THEN** Owner, Approver, Member, and Claimant are described
- **AND** Add a person is documented alongside Add a device
