## Purpose

Let Claimants attach receipt evidence to claim items and keep that evidence safely with the company books, on the company's own devices only.

## ADDED Requirements

### Requirement: Capturing Receipts
A Claimant SHALL be able to attach one or more receipts to a claim item by taking a photo with the camera or by picking an image or a PDF. The camera and photo-library permissions SHALL be asked only when the Claimant first adds a receipt.

#### Scenario: Photo of a taxi receipt
- **WHEN** Ravi taps "Add receipt" and takes a photo
- **THEN** the photo is attached to the item and shown as a thumbnail

### Requirement: Receipts Required Above an Amount
An Owner SHALL set "Receipt required above ___" for the company books, defaulting to 0, which means a receipt is always required. An item at or above the amount SHALL NOT be submittable without a receipt.

#### Scenario: Missing receipt blocks submission
- **WHEN** the setting is 0 and Ravi tries to submit an item without a receipt
- **THEN** submission is blocked with "Add a receipt for this item"

### Requirement: Receipt Size and Format
Photos SHALL be compressed to roughly 1 MB each before they are stored. PDFs SHALL be stored unchanged up to 5 MB, and larger PDFs SHALL be refused with a plain message.

#### Scenario: A large PDF is refused
- **WHEN** Ravi picks a 12 MB PDF
- **THEN** the app refuses it and explains the 5 MB limit

### Requirement: Receipts Stay With the Books
Receipts SHALL be stored inside the company books on the Claimant's device and on the company's linked devices. They SHALL be exchanged only over the shared Wi-Fi, included in every Books Copy, and kept for as long as the books exist. The app SHALL NOT send receipts to any server or AI service, and SHALL NOT delete them automatically.

#### Scenario: Receipt in a saved copy
- **WHEN** an Owner saves a Books Copy and restores it on another device
- **THEN** every receipt is present and opens

#### Scenario: Receipts are not deleted
- **WHEN** a claim was paid three years ago
- **THEN** its receipts are still available to Owners and Approvers
