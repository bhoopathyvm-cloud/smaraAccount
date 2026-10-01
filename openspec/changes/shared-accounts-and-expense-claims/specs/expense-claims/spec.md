## Purpose

Let an employee claim business expenses from company books and let the accounting team decide each item, pay, and manage advances, so that only what the company accepted and paid enters the books.

## ADDED Requirements

### Requirement: A Claim Is a Request Outside the Books
A Claimant SHALL be able to create a Claim made of one or more Claim Items, each with a date, an expense category from the company's allowed list, an amount in the currency paid, a description and receipts. A Claim and its items SHALL NOT create any journal entry until an item is approved.

#### Scenario: A draft claim leaves the books unchanged
- **WHEN** a Claimant creates a claim with three items and saves it as a draft
- **THEN** the company books contain no new entry

### Requirement: Claim Statuses
A Claim SHALL have the status Draft, Submitted, Partly approved, Approved or Paid. The status SHALL follow from its items. It is Draft until submitted, then Submitted until every item is decided. It is Partly approved when items are decided but some are rejected or reduced. It is Approved when every item is approved in full. It is Paid when the approved total has been paid.

#### Scenario: Status follows the items
- **WHEN** an Approver approves two items and rejects one item of a submitted claim
- **THEN** the claim's status is Partly approved

### Requirement: A Decision for Each Item
An Approver SHALL decide each submitted item separately: Approve, Approve a different amount, or Reject. A reason SHALL be required when the amount changes or the item is rejected. The Claimant SHALL see every decision and reason.

#### Scenario: Reduced amount with a reason
- **WHEN** an Approver approves a hotel item of 180 as 150 with the reason "Hotel limit is 150 per night"
- **THEN** the item shows 150 approved and the reason on the Claimant's device after syncing

#### Scenario: A reason is required
- **WHEN** an Approver tries to reject an item without a reason
- **THEN** the rejection is not saved until a reason is entered

### Requirement: Approval and Payment Create the Accounting Records
Approving an item SHALL post one signed entry in the company books: the approved amount to the item's expense category, owed to the Claimant's "Owed to <name>" account. Recording a payment SHALL post a signed entry from the chosen company bank or cash account to the Claimant's "Owed to" account. A rejected item SHALL NOT post any entry. Changing a decision after it was posted SHALL use the normal Fix, never an edit.

#### Scenario: An approved taxi receipt
- **WHEN** an Approver approves a taxi item of 40
- **THEN** the company books contain an entry of 40 to "Travel" owed to "Owed to Ravi"

#### Scenario: Paying the claim
- **WHEN** an Approver records a payment of 230 from the company bank account to Ravi
- **THEN** the books contain that entry, "Owed to Ravi" is reduced by 230, and the claim shows Paid on Ravi's device after syncing

### Requirement: Foreign-Currency Items
A Claimant SHALL record each item in the currency paid. The Claimant MAY enter the exchange rate from their card statement. Otherwise the app SHALL propose its reference rate for the item's date. The Approver SHALL see both currencies and the rate, and MAY correct the rate. The books SHALL record the approved amount in the company's currency.

#### Scenario: Dollars claimed in euro books
- **WHEN** Ravi claims 80 USD at a card rate of 0.92 and the Approver approves it
- **THEN** the books record 73.60 EUR and the item shows 80 USD at 0.92

### Requirement: Advances
An Approver SHALL be able to record an advance paid to a Claimant before a trip. Approved items SHALL reduce the advance. The Claimant's balance SHALL show either what the company owes them or what they owe the company.

#### Scenario: Advance larger than claims
- **WHEN** Ravi received an advance of 300 and items of 280 are approved
- **THEN** Ravi's balance shows "You owe Acme 20"

### Requirement: Spending-Limit Hints
An Owner SHALL be able to set an optional claim limit per allowed category, for example "Hotel at most 150 per night". The limit SHALL be shown as a hint to the Claimant while entering an item and to the Approver while deciding it. It SHALL NOT change any amount automatically.

#### Scenario: A hint, not a rule
- **WHEN** Ravi enters a hotel item of 180 where the limit is 150
- **THEN** the app shows "Above the 150 limit" and still saves 180 for the Approver to decide

### Requirement: Submitting Works Over the Shared Wi-Fi
A Claimant SHALL be able to prepare and submit claims at any time. Submitted claims and their receipts SHALL reach the company's linked devices only over the same Wi-Fi, under the rules of `linked-devices`. The claim SHALL show "Waiting to send" until it has been delivered.

#### Scenario: Submitted while travelling
- **WHEN** Ravi submits a claim from a hotel
- **THEN** it shows "Waiting to send" and is delivered the next time his phone and a company device have Smara open on the office Wi-Fi
