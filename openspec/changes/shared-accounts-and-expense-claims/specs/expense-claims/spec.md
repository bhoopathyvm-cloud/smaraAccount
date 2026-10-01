## Purpose

Let employees submit travel and other expense Claims with receipts on
their phones, and let the office approve or reject each item and pay —
creating ordinary books records only on approval — without a server.

## ADDED Requirements

### Requirement: Claim Is Outside the Books Until Approved
A Claim is a list of Claim Items with receipts and a status. The system SHALL NOT post Journal Entries for a Claim or Claim Item until an Approver or Owner approves that item. Rejected items SHALL NEVER create Journal Entries.

#### Scenario: Draft and submitted claims do not appear in the register
- **WHEN** a Claimant saves or submits a Claim with items
- **THEN** the company books register gains no Journal Entry for those items
- **AND** the Claim is stored in the company Books Set as a Claim, not as a posted entry

#### Scenario: Rejected item never posts
- **WHEN** an Approver rejects a Claim Item with a reason
- **THEN** no Journal Entry is created for that item
- **AND** the rejection reason is stored for the Claimant to see

### Requirement: Approval Creates Expense and Owed-To Entries
When an Approver or Owner approves a Claim Item (at the submitted amount or a different amount), the system SHALL post a balanced Journal Entry for the approved company-currency amount between the chosen expense Category and the Claimant's "Owed to \<name\>" liability Financial Account.

#### Scenario: Approve posts expense and liability
- **WHEN** an Approver approves a Claim Item for 120 in company currency against Travel
- **THEN** a Journal Entry posts Travel expense 120 and Owed to that Claimant 120
- **AND** the entry is signed by the Approver's device Signing Identity

#### Scenario: Approve different amount requires a reason
- **WHEN** an Approver approves a Claim Item for an amount different from the submitted company-currency amount
- **THEN** the system requires a reason before posting
- **AND** the posted amount is the Approver's amount, not the submitted amount

### Requirement: Payment Clears Owed-To Against Bank
When the office records a payment to a Claimant for approved amounts, the system SHALL post a balanced Journal Entry between that Claimant's "Owed to \<name\>" liability and a chosen company bank or cash Financial Account.

#### Scenario: Payment posts liability and bank
- **WHEN** an Approver pays 120 owed to a Claimant from the company checking account
- **THEN** a Journal Entry posts Owed to that Claimant −120 and checking −120 (asset reduced)
- **AND** the Claimant's visible balance updates after sync

### Requirement: Per-Item Approve Reject or Different Amount
Each Claim Item SHALL be decided separately: Approve, Approve a different amount (reason required), or Reject (reason required). The Claim's status SHALL follow from its items.

#### Scenario: Mixed decisions yield partly approved
- **WHEN** one item on a Claim is approved and another is still undecided
- **THEN** the Claim status is Partly approved

#### Scenario: Reject requires a reason
- **WHEN** an Approver chooses Reject on a Claim Item
- **THEN** the system does not complete the decision until a reason is provided

### Requirement: Claim Statuses
A Claim SHALL expose status among Draft, Submitted, Partly approved, Approved, Paid, and Rejected (every item rejected). Claimants SHALL see these statuses on their own claims.

#### Scenario: Submit moves draft to submitted
- **WHEN** a Claimant submits a Draft Claim that meets receipt and category rules
- **THEN** the Claim status becomes Submitted

#### Scenario: Paid after full settlement
- **WHEN** every approved amount on a Claim has been settled by payment or advance offset
- **THEN** the Claim status becomes Paid

#### Scenario: All items rejected
- **WHEN** every Claim Item on a Claim has been rejected
- **THEN** the Claim status is Rejected
- **AND** no amount is owed for that Claim

### Requirement: Claimant Sees Only Their Slice
A person whose role on the books is Claimant only SHALL see their own claims and statuses, rejection reasons, their balance with the company, payments made to them, and the expense categories allowed for claims. They SHALL NOT see company bank accounts, other employees' claims, or other parts of the books.

#### Scenario: Claimant home shows own claims and balance
- **WHEN** a Claimant-only user opens the company Books Set
- **THEN** they see their claims, statuses, and balance copy such as "Acme owes you…" or "You owe Acme…"
- **AND** they do not see company bank balances or other people's names in a people list

#### Scenario: Claimant cannot open bank register
- **WHEN** a Claimant-only user attempts to navigate to a company bank account register
- **THEN** the system denies that navigation

### Requirement: Claim Category Allowlist
The company books SHALL maintain the set of expense Categories allowed on Claims. Claimants SHALL pick only from that allowlist when adding Claim Items.

#### Scenario: Disallowed category is not offered
- **WHEN** a Claimant adds a Claim Item
- **THEN** only allowlisted expense Categories appear
- **AND** categories not on the allowlist cannot be selected

### Requirement: Foreign Currency Claim Items
A Claim Item SHALL be recorded in the currency paid. The Claimant MAY enter a card-statement rate; otherwise the system SHALL use the app's rate for the expense date when available. The Approver SHALL see both currencies and MAY correct the rate. The books SHALL record the approved company-currency amount.

#### Scenario: Employee-stated rate is used until Approver changes it
- **WHEN** a Claimant enters a paid-currency amount and a statement rate
- **THEN** the item shows the implied company-currency amount using that rate
- **AND** the Approver can change the rate before approving

#### Scenario: Missing rate uses app rate for the date
- **WHEN** the Claimant leaves the rate blank and the app has a rate for that expense date
- **THEN** the item uses that app rate for the company-currency amount

### Requirement: Advances Reduce What Is Owed
The system SHALL support Advances: payments to a Claimant before Claims. Approved Claim amounts SHALL reduce the Advance / owed balance. Claimant balance copy SHALL reflect either direction (company owes Claimant, or Claimant owes company).

#### Scenario: Advance then approved claim
- **WHEN** the office records an Advance of 200 to a Claimant and later approves a Claim Item for 80
- **THEN** the Claimant's balance reflects the remaining Advance against approved amounts
- **AND** the Claimant can see the Advance and the approved Claim after sync

### Requirement: Spending Limit Hints Are Not Enforced
Optional per-category spending limits for Claims (for example a maximum per night) SHALL be shown as hints to the Claimant and the Approver. The system SHALL NOT block submit or approve because a hint is exceeded.

#### Scenario: Over-hint still submittable
- **WHEN** a Claimant enters an amount above a category's Claim spending-limit hint
- **THEN** the UI shows the hint
- **AND** the Claimant can still submit
- **AND** the Approver can still approve

### Requirement: Claims Submit Only on Office Wi-Fi Sync
Claims prepared away from the office SHALL reach Approver devices only when Peer Sync runs on the same Wi-Fi. The system SHALL NOT offer an internet or relay path to submit Claims.

#### Scenario: Submit waits for sync on same Wi-Fi
- **WHEN** a Claimant marks a Claim Submitted while off the office network
- **THEN** Approver devices do not receive it until both sync on the same Wi-Fi
- **AND** no server is used to deliver the Claim

### Requirement: No Household Books Reimbursement in First Version
Recording a payment for a Claim SHALL NOT create entries in the Claimant's household Books Set.

#### Scenario: Payment stays in company books only
- **WHEN** the office pays an approved Claim
- **THEN** only the company Books Set gains the payment Journal Entry
- **AND** the Claimant's household Books Set is unchanged
