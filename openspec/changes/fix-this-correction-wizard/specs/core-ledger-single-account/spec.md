## ADDED Requirements

### Requirement: Correct via Fix Flow
In addition to reversing an entry as a standalone action, the user SHALL
be able to open a **Fix** flow from the register that posts a reversal
and a replacement transaction reflecting corrected fields (amount,
category, account, date, description) in one guided sequence. The
original entry SHALL remain visible and unchanged.

#### Scenario: Fix from register row
- **WHEN** the user chooses Fix on a register row
- **THEN** the system shows a form prefilled with the entry's fields
- **AND** on confirm posts a reversal and a new entry with the edited values

#### Scenario: Fix does not edit in place
- **WHEN** the user completes a Fix flow
- **THEN** no posted journal entry is modified in place
