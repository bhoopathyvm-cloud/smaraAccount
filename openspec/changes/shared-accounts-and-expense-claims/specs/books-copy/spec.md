## ADDED Requirements

### Requirement: Books Copy Includes Claims and Receipts
A Books Copy of a Books Set SHALL include that set's Claims, Claim Items, decisions, Advances, and receipt attachments, in addition to ledger data and books settings. The copy SHALL NOT include any device's private key.

#### Scenario: Restore brings back receipts
- **WHEN** an Owner saves a Books Copy of company books that contain Claims with receipts, and another device restores that copy
- **THEN** the restored books include those Claims and their receipt attachments
- **AND** no private key is present in the copy file
