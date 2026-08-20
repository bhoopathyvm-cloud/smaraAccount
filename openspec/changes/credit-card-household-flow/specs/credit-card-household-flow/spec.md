## Purpose

The household-facing capture flow and labeling for credit-card-flagged
liability accounts — the flag itself is `multi-account-ledger`'s; this
capability owns the "Paid from card" / "Paid from bank" capture default
and the labeled "Pay card" transfer entry point.

## ADDED Requirements

### Requirement: Spent Capture Offers Card or Bank
When the user has at least one credit-card-flagged account, recording a spent transaction SHALL offer "Paid from card" and "Paid from bank" as labeled shortcuts, both resolving to the existing account-selection step with the relevant accounts pre-filtered.

#### Scenario: Paid from card
- **WHEN** the user records spent and chooses "Paid from card"
- **THEN** the expense posts against the selected credit card account, exactly as an ordinary expense transaction would

#### Scenario: No cards means no shortcut
- **WHEN** the user has no credit-card-flagged account
- **THEN** the ordinary account picker is shown with no card/bank shortcut

### Requirement: Pay Card Is a Labeled Transfer
The system SHALL offer a "Pay card" action that pre-fills an ordinary transfer from a bank (asset) account to the chosen credit card account, using the existing transfer mechanism unchanged.

#### Scenario: Pay card posts an ordinary transfer
- **WHEN** the user completes "Pay card" from a bank account to a card
- **THEN** the system posts the same entry an ordinary transfer between those two accounts would produce
- **AND** the card's amount owed decreases by the paid amount
