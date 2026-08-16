## ADDED Requirements

### Requirement: Seeded Investments System Group
The system SHALL seed an Investments system asset group on first use or on migration from a database that does not yet have it. The group SHALL be a system group: renameable, not permanently deletable, and not archivable, matching the existing four system groups.

#### Scenario: Investments group exists after setup or migration
- **WHEN** the application completes first-identity confirmation or migrates a database that lacks the Investments group
- **THEN** the Investments system asset group exists and is available for assignment
- **AND** the original four system groups still exist

### Requirement: Asset Accounts May Be Investment Wrappers
When creating an asset financial account, the user SHALL be able to mark it as an investment account. That account SHALL then have cash and inventory as defined by `investment-holdings`. A liability account SHALL NOT be markable as an investment account. The investment-account flag SHALL NOT be changeable after creation.

#### Scenario: Create an investment account
- **WHEN** the user creates an asset financial account marked as an investment account, with a name and an account group
- **THEN** the account accepts cash transfers in and out and buy/sell against its inventory
- **AND** it is still an asset account for archive, rename, and group membership

#### Scenario: A liability cannot be an investment account
- **WHEN** the user attempts to mark a liability financial account as an investment account
- **THEN** the system rejects the create or the flag
