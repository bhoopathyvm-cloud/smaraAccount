## ADDED Requirements

### Requirement: Transfer Fee Can Be Deducted From the Transferred Amount
In addition to the default mode where a transfer fee posts as an additional debit on top of the transferred amount, the user SHALL be able to indicate, per transfer, that the fee is deducted from the entered amount rather than added to it. When this deducted-fee mode is selected and a valid fee is present, the amount actually moved by the transfer (and, for a known-rate cross-currency transfer, converted to the destination) SHALL be the entered amount minus the fee amount, while the total debited from the source account SHALL remain equal to the entered amount (transfer amount plus separately posted fee amount). The known destination amount field, when supplied, SHALL continue to represent the amount the user expects to arrive and SHALL NOT be altered by this mode. The system SHALL reject the submit, before posting either entry, if the fee amount is greater than or equal to the entered amount while deducted-fee mode is selected.

#### Scenario: Deducted fee reduces the transfer's own amount
- **WHEN** the user records a same-currency transfer of 100.00, supplies a fee of 1.62 with an active expense category, and selects deducted-fee mode
- **THEN** the transfer entry posts for 98.38 between the source and destination accounts
- **AND** a separate same-currency money-out fee entry of 1.62 posts against the source account and the chosen category
- **AND** the total amount debited from the source account across both entries is 100.00

#### Scenario: Deducted fee applies to a known-rate cross-currency transfer's source leg
- **WHEN** the user records a cross-currency transfer with a source amount of 100.00, a known destination amount, a fee of 1.62, and deducted-fee mode selected
- **THEN** the transfer's source-side amount used for the entry and its conversion is 98.38
- **AND** the destination amount posted is exactly the value the user entered, unmodified by the fee or the mode

#### Scenario: A fee that would consume the entire amount is rejected
- **WHEN** the user selects deducted-fee mode and enters a fee amount greater than or equal to the transfer amount
- **THEN** the system rejects the submit
- **AND** neither a transfer entry nor a fee entry is posted

#### Scenario: Fee mode defaults to additive, unchanged from existing behavior
- **WHEN** the user records a transfer with a fee and does not select deducted-fee mode
- **THEN** the transfer posts for the full entered amount
- **AND** the fee posts as an additional debit, as already specified by the transfer fee requirement
