## MODIFIED Requirements

### Requirement: Transaction Register
The system SHALL provide a reverse-chronological register of posted journal entries for a selected financial account, showing a running balance for that account. The most recently posted entry SHALL be listed first, so that it and the account's current balance are visible without scrolling.

#### Scenario: Register shows running balance
- **WHEN** the user opens the register for a financial account
- **THEN** posted entries that affect that account are listed in reverse-chronological order, most recent transaction date first
- **AND** each entry shows that account's balance as of that entry

#### Scenario: A newly recorded entry appears at the top
- **WHEN** the user records a new entry against the currently viewed account
- **THEN** the new entry appears as the first (topmost) row in the register
- **AND** its running balance equals the account's current balance
