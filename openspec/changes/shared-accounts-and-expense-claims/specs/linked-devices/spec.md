## ADDED Requirements

### Requirement: Approver and Claimant Roles
Linked-device membership SHALL support roles Owner, Approver, Member, and Claimant. A person MAY hold several roles at once. Approver SHALL review Claim Items and record payments to Claimants. Claimant SHALL create and submit only their own Claims. Owner membership powers from Linked devices remain; Member bookkeeping powers remain.

#### Scenario: Approver can decide claims
- **WHEN** a membership includes Approver and the user opens the review queue
- **THEN** they can Approve, Approve a different amount, or Reject Claim Items

#### Scenario: Claimant cannot approve
- **WHEN** a membership is Claimant only
- **THEN** that user cannot approve or reject anyone's Claim Items
- **AND** they can create and submit their own Claims

#### Scenario: Multiple roles on one membership
- **WHEN** a person is granted Approver and Member
- **THEN** they can both review Claims and perform ordinary bookkeeping on those books

### Requirement: Add a Person With Claimant Role by QR
The system SHALL offer "Add a person" that links another phone by QR code on the same Wi-Fi, assigns the chosen role (default Claimant), and creates an "Owed to \<name\>" liability Financial Account for that person automatically.

#### Scenario: Add Claimant creates owed-to account
- **WHEN** an Owner completes Add a person with role Claimant for display name Ravi
- **THEN** Ravi's device is linked for those books with Claimant role
- **AND** a liability Financial Account "Owed to Ravi" exists in the company books

#### Scenario: Add a person stays on same Wi-Fi
- **WHEN** the devices are not on the same local network
- **THEN** Add a person does not complete over the internet or a relay

### Requirement: Removing a Person Warns About Open Claims
When an Owner removes a person, the system SHALL warn about open Claims and non-zero owed balances, and SHALL still allow removal. History, receipts, and posted Journal Entries SHALL remain in the company books.

#### Scenario: Warning then remove
- **WHEN** an Owner removes a Claimant who has a Submitted Claim and a non-zero owed balance
- **THEN** the UI warns about open Claims and the balance
- **AND** after confirm, the person no longer syncs as a member
- **AND** past Claims, receipts, and Journal Entries stay in the books
