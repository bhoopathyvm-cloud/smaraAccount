## MODIFIED Requirements

### Requirement: Account Groups for Financial Accounts
The system SHALL provide account groups that classify financial accounts for overview rollups. The system SHALL seed at least these system groups on first use or migration: Cash & cash equivalents (asset), Pension & retirement (asset), Credit & short-term debt (liability), and Loans & mortgages (liability). The user SHALL be able to create additional account groups, each with a name, a kind (asset or liability), and a currency. The user SHALL be able to rename any account group, system or user-created.

#### Scenario: Seeded groups exist after setup or migration
- **WHEN** the application completes first-identity confirmation or migrates an existing pre-multi-account database
- **THEN** the four system account groups exist and are available for assignment

#### Scenario: Create a custom account group
- **WHEN** the user creates a new account group with a name, a kind, and a currency
- **THEN** the group exists and is available for assignment to financial accounts of the matching kind
- **AND** the group is not a system group

#### Scenario: A new account group requires a currency
- **WHEN** the user attempts to create an account group without supplying a currency
- **THEN** the system rejects the creation

#### Scenario: Financial account requires a group
- **WHEN** the user creates or edits a financial account
- **THEN** the system requires selection of an account group whose kind matches the account type (asset accounts in asset groups, liability accounts in liability groups)

#### Scenario: Reassign a financial account to another group
- **WHEN** the user changes a financial account's group to another group of the matching kind
- **THEN** the account appears under the new group on the home overview
- **AND** its balance is included in the new group's total instead of the previous group's total

#### Scenario: Reassignment to a mismatched-kind group is rejected
- **WHEN** the user attempts to reassign a financial account to a group whose kind does not match the account's type (e.g. an asset account to a liability group)
- **THEN** the system rejects the reassignment and the account remains in its original group

#### Scenario: Rename an account group
- **WHEN** the user renames a system or user-created account group
- **THEN** the new name is used on the home overview and in account-group pickers

### Requirement: System Account Groups Are Permanent and Renameable
The four seeded system account groups SHALL NOT be permanently deleted and SHALL NOT be archived. They remain available for assignment for the lifetime of the ledger. The user SHALL be able to rename a system account group. A user-created account group SHALL be archivable once it has zero active member financial accounts; an archived user-created group SHALL NOT be permanently deleted. An empty, non-archived group (no active member accounts) is simply omitted or de-emphasized on the home overview rather than requiring archiving.

#### Scenario: System group cannot be deleted
- **WHEN** the user attempts to permanently delete a system account group
- **THEN** the system rejects the action and the group remains

#### Scenario: System group cannot be archived
- **WHEN** the user attempts to archive a system account group
- **THEN** the system rejects the action and the group remains available for assignment

#### Scenario: Archive a user-created account group with no active accounts
- **WHEN** the user archives a user-created account group that has zero active member financial accounts
- **THEN** the group no longer appears in account-group pickers offered for new assignments
- **AND** any account still historically associated with that group (e.g. an already-archived account) continues to resolve the group's name and currency normally

#### Scenario: Archiving a user-created group with an active account is rejected
- **WHEN** the user attempts to archive a user-created account group that has at least one active member financial account
- **THEN** the system rejects the action and the group remains available for assignment

#### Scenario: Archiving an already-archived group is rejected
- **WHEN** the user attempts to archive a user-created account group that is already archived
- **THEN** the system rejects the action

#### Scenario: A user-created account group cannot be permanently deleted
- **WHEN** the user attempts to permanently delete a user-created account group, archived or not
- **THEN** the system rejects the action
