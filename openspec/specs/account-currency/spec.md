# account-currency

## Purpose

Attach a single ISO 4217 currency to each account group, derive each financial account's display currency from its group, and keep home overview net worth per-currency with no FX conversion.

## Requirements

### Requirement: Account Groups Have a Single Currency
Every account group SHALL have exactly one currency, set when the group is created. The system SHALL NOT permit an account group to hold financial accounts denominated in more than one currency.

#### Scenario: Currency set at group creation
- **WHEN** the user creates an account group
- **THEN** the system requires selection of a currency for that group
- **AND** every financial account subsequently assigned to that group is treated as being in that currency

#### Scenario: Group currency cannot change while accounts are assigned
- **WHEN** the user attempts to change an account group's currency while it has at least one active financial account assigned to it
- **THEN** the system rejects the change

#### Scenario: Group currency can change when the group is empty
- **WHEN** the user changes an account group's currency while it has zero active financial accounts assigned to it
- **THEN** the system applies the new currency to the group

### Requirement: Financial Accounts Are Currency-Agnostic
A financial account SHALL NOT store its own currency. The account's display currency SHALL always be derived from the currency of the account group it belongs to.

#### Scenario: Account displays its group's currency
- **WHEN** the user views a financial account's balance, register, or entry screen
- **THEN** the amounts are shown in the currency of the account group that account belongs to
