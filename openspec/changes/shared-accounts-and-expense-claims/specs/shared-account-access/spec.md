## Purpose

Let company books give each person only the access they need: Approvers who decide and pay claims, and Claimants who see only their own claims and balance on their own device.

## ADDED Requirements

### Requirement: Approver and Claimant Roles
Company books SHALL support the roles Approver and Claimant in addition to the Owner and Member roles of `linked-devices`. An Approver SHALL be able to review, approve, adjust, reject and pay claims, and record advances. A Claimant SHALL be able only to create and submit their own claims and see their own balance and payments. One person SHALL be able to hold several roles, and Owners SHALL be able to assign and remove roles.

#### Scenario: A Claimant cannot approve
- **WHEN** a Claimant opens a submitted claim
- **THEN** no approve, adjust, reject or pay action is offered

#### Scenario: An Owner who also approves
- **WHEN** an Owner gives themselves the Approver role
- **THEN** they see the approval queue in addition to everything an Owner sees

### Requirement: A Claimant Sees Only Their Part of the Books
A Claimant's device SHALL receive and store only:
- their own claims, claim items, receipts and decisions;
- the entries that post to their "Owed to <name>" account;
- the expense categories the company allows for claims.

It SHALL NOT receive company bank accounts, other people's accounts, other claims, or any other entries. Each record the Claimant's device receives SHALL still be verified against the public key of the device that signed it.

#### Scenario: Ravi's phone holds only Ravi's part
- **WHEN** Ravi's phone syncs with the company books
- **THEN** it shows his claims, his balance and his payments, and contains no other employee's data and no company bank account

#### Scenario: Received records are verified
- **WHEN** Ravi's phone receives the payment entry for his claim
- **THEN** the entry's signature is verified before it is shown

### Requirement: Adding an Employee
An Owner SHALL be able to add a person with the role Claimant by name and link their device by QR code, as in `linked-devices`. The system SHALL create the account "Owed to <name>" automatically, so that nobody has to set up accounting for the employee by hand.

#### Scenario: A new employee
- **WHEN** an Owner adds "Ravi" as a Claimant and links Ravi's phone
- **THEN** the company books contain the account "Owed to Ravi", and Ravi's phone shows an empty claims list for Acme

### Requirement: Removing a Departing Employee
Before removing a Claimant, the system SHALL warn the Owner about open claims and any balance ("Ravi has 1 open claim and is owed 40"). Removal SHALL still be allowed. The Claimant's claims, receipts and "Owed to" account SHALL stay in the company books, and the account SHALL remain until its balance is settled.

#### Scenario: Removing with an open balance
- **WHEN** an Owner removes Ravi while Acme owes him 40
- **THEN** the warning names the open claim and the 40, and after removal "Owed to Ravi" still shows 40 until it is paid

### Requirement: Separate From Personal Books
On a Claimant's device, the company's part SHALL be a separate set of books (`multiple-books`). Nothing from it SHALL appear in the Claimant's own household books.

#### Scenario: Household books unaffected
- **WHEN** Acme pays Ravi 230
- **THEN** Ravi's "My household" books contain no new entry
