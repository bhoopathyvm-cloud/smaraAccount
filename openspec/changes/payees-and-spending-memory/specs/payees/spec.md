# payees

## Purpose

Capability for payees and spending memory.

## Requirements

### Requirement: Payees and Spending Memory
The system SHALL maintain payee names with optional default category and account. When recording a transaction the system SHALL suggest payees and apply defaults from the last matching payee or keyword rule.

#### Scenario: Payee default category
- **WHEN the user selects payee Starbucks with default category Food**
- **THEN** the category field prefills Food

#### Scenario: Remember last account
- **WHEN the user records from the same payee again**
- **THEN** the last used account is suggested

