## Purpose

Attach camera photos, picked images, or PDFs to Claim Items, store them
inside the company books, sync them over Wi-Fi, and keep them for the
life of the books without automatic deletion.

## ADDED Requirements

### Requirement: Attach Photo Image or PDF to a Claim Item
The Claimant SHALL be able to attach a receipt to a Claim Item by taking a camera photo, picking an image, or picking a PDF.

#### Scenario: Camera photo attaches
- **WHEN** a Claimant takes a photo for a Claim Item receipt
- **THEN** the photo is stored as that item's receipt attachment

#### Scenario: Picked PDF attaches
- **WHEN** a Claimant picks a PDF file within the size limit for a Claim Item
- **THEN** the PDF is stored as that item's receipt attachment

### Requirement: Receipt Required Above Threshold
Company books SHALL have a setting "Receipt required above ___" with default 0 meaning a receipt is always required. Submitting a Claim Item whose amount is above the threshold SHALL require a receipt attachment.

#### Scenario: Default requires receipt always
- **WHEN** the threshold is 0 and a Claimant submits a Claim Item with no receipt
- **THEN** submit is refused until a receipt is attached

#### Scenario: Below threshold may omit receipt
- **WHEN** the threshold is 50 and a Claimant submits an item amounting to 40 in company currency with no receipt
- **THEN** submit is allowed without a receipt

### Requirement: Photo Compression and PDF Size Cap
Receipt photos SHALL be compressed to roughly 1 MB before storage. PDFs SHALL be kept as provided up to 5 MB; larger PDFs SHALL be refused with a plain-language message.

#### Scenario: Large photo is compressed
- **WHEN** a Claimant attaches a multi-megabyte photo
- **THEN** the stored photo is compressed to approximately 1 MB

#### Scenario: Oversized PDF refused
- **WHEN** a Claimant picks a PDF larger than 5 MB
- **THEN** the attachment is refused and the user is told the size limit

### Requirement: Receipts Stored in Books Synced and Copied
Receipt attachments SHALL be stored inside the Books Set, SHALL sync to Linked devices over Peer Sync on the same Wi-Fi, and SHALL be included when saving a Books Copy of that set.

#### Scenario: Receipt arrives on office device after sync
- **WHEN** a Claimant attaches a receipt, submits, and syncs with an Approver device on the same Wi-Fi
- **THEN** the Approver can open the same receipt bytes for that Claim Item

#### Scenario: Books Copy includes receipts
- **WHEN** an Owner saves a Books Copy of company books that contain Claim receipts
- **THEN** restoring that copy on another device restores the receipt attachments

### Requirement: Receipts Never Auto-Deleted
The system SHALL keep Claim receipts for as long as the books exist and SHALL NOT delete them automatically on Claim payment, rejection, or age.

#### Scenario: Paid claim keeps receipt
- **WHEN** a Claim is fully Paid
- **THEN** its receipt attachments remain readable in the company books

#### Scenario: Rejected item keeps receipt
- **WHEN** a Claim Item is rejected
- **THEN** its receipt attachment remains stored
