## ADDED Requirements

### Requirement: Investment Account Marked Value Is Secondary
When an investment account has one or more holdings with a display mark, the home overview MAY show a marked-value estimate as a secondary label on that account. The account's contribution to its group total and to its currency's net position SHALL remain its ledger display balance. The system SHALL NOT add unmarked estimates, unrealized gains, or holding marks into net position.

#### Scenario: Net position stays ledger-based
- **WHEN** an investment account has holdings with display marks that differ from cost
- **THEN** the home overview's group total and currency net position still use that account's ledger display balance
- **AND** any marked-value figure is shown as a separate estimate, or omitted, never summed into net position
