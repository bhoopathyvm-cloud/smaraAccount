# payees

## Purpose

Payee entities with default category/account, and autocomplete on the
transaction description field, reusing the same description
normalization import category rules already use.

## Requirements

### Requirement: Payees and Spending Memory
The system SHALL maintain payee names with an optional default category and an optional default financial account. When recording a transaction, the system SHALL suggest a matching payee by normalized description (the same normalization import category rules use) and apply that payee's defaults; the user may always override the suggestion.

#### Scenario: Payee default category
- **WHEN** the user selects payee Starbucks with default category Food
- **THEN** the category field prefills Food

#### Scenario: Remember last account
- **WHEN** the user records from the same payee again
- **THEN** the last used account is suggested

#### Scenario: Suggestion is always overridable
- **WHEN** a payee's defaults are suggested
- **THEN** the user can change the category or account before saving without any restriction
