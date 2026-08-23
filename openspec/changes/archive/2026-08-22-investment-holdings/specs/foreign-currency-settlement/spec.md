## MODIFIED Requirements

### Requirement: Known-Rate Cross-Currency Movement Posts as a Single Entry
When the exact amount in the destination or account currency is known at the time a cross-currency transfer or foreign-currency transaction is recorded, the system SHALL post one complete journal entry covering both currencies immediately, and SHALL NOT create a pending transfer. An investment account's cash leg participates in cross-currency transfers exactly as any other financial account's balance does; there is no investment-specific variant of this behavior.

#### Scenario: Cash funding an investment account across currencies
- **WHEN** the user transfers cash into or out of an investment account whose group currency differs from the source or destination account's currency
- **THEN** the transfer follows the same known-rate or provisional-and-settled path already defined for any other cross-currency transfer
