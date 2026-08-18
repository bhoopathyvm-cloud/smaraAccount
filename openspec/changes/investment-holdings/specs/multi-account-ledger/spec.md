## MODIFIED Requirements

### Requirement: Account Groups for Financial Accounts
The system SHALL provide account groups that classify financial accounts for overview rollups. The system SHALL seed at least these system groups on first use or migration: Cash & cash equivalents (asset), Pension & retirement (asset), Credit & short-term debt (liability), Loans & mortgages (liability), and Investments (asset). The user SHALL be able to create additional account groups, each with a name, a kind (asset or liability), and a currency. The user SHALL be able to rename any account group, system or user-created. Reassigning a financial account to a different group additionally requires the destination group to have the same currency as the account's current group.

#### Scenario: Seeded groups exist after setup or migration
- **WHEN** the application completes first-identity confirmation or migrates an existing pre-multi-account database
- **THEN** the five system account groups exist and are available for assignment

### Requirement: System Account Groups Are Permanent and Renameable
The five seeded system account groups SHALL NOT be permanently deleted and SHALL NOT be archived. They remain available for assignment for the lifetime of the ledger. The user SHALL be able to rename a system account group. A user-created account group SHALL be archivable once it has zero active member financial accounts; an archived user-created group SHALL NOT be permanently deleted. An empty, non-archived group (no active member accounts) is simply omitted or de-emphasized on the home overview rather than requiring archiving.

#### Scenario: System group cannot be deleted
- **WHEN** the user attempts to permanently delete a system account group
- **THEN** the system rejects the action and the group remains

#### Scenario: System group cannot be archived
- **WHEN** the user attempts to archive a system account group
- **THEN** the system rejects the action and the group remains available for assignment

## ADDED Requirements

### Requirement: Seeded Investments System Group
The system SHALL seed an Investments system asset group on first use or on migration from a database that does not yet have it. The group SHALL be a system group: renameable, not permanently deletable, and not archivable, matching the other four system groups.

#### Scenario: Investments group exists after setup or migration
- **WHEN** the application completes first-identity confirmation or migrates a database that lacks the Investments group
- **THEN** the Investments system asset group exists and is available for assignment
- **AND** the four pre-existing system groups still exist

### Requirement: Asset Accounts May Be Investment Wrappers
When creating an asset financial account, the user SHALL be able to mark it as an investment account. That account SHALL then have cash and inventory as defined by `investment-holdings`. A liability account SHALL NOT be markable as an investment account. The investment-account flag SHALL NOT be changeable after creation.

#### Scenario: Create an investment account
- **WHEN** the user creates an asset financial account marked as an investment account, with a name and an account group
- **THEN** the account accepts cash transfers in and out, buy (cash-funded and non-cash), sell, and dividend against its inventory
- **AND** it is still an asset account for archive, rename, and group membership

#### Scenario: A liability cannot be an investment account
- **WHEN** the user attempts to mark a liability financial account as an investment account
- **THEN** the system rejects the create or the flag

### Requirement: An Archived Investment Account's Cash Closes Out Like Any Other Account, Repeatably
An investment account with a positive cash balance SHALL be archivable, exactly like any other financial account, and its cash SHALL be closeable via the same full-balance closeout transfer already defined for an archived financial account. Unlike an ordinary archived account — whose balance cannot become positive again once closed out, because nothing can post to it — an archived investment account's cash CAN become positive again afterward, from a later Sell or Dividend (both permitted by the requirement below). The closeout transfer SHALL therefore be offered again each time the archived investment account's cash becomes positive, not only once for its lifetime, so cash from any later sell or dividend is never stranded with no way to move it out.

#### Scenario: An investment account archives with positive cash, then closes out
- **WHEN** the user archives an investment account that has a positive cash balance
- **THEN** the account archives normally
- **AND** the account's closeout transfer is available to move that cash to a different active financial account, exactly as for any other archived account

#### Scenario: A later sell's proceeds get their own closeout transfer
- **WHEN** the user sells units from an archived investment account after its cash was already closed out to zero once
- **THEN** the closeout transfer becomes available again for the cash that sell produced

#### Scenario: A later dividend's proceeds get their own closeout transfer
- **WHEN** the user records a dividend against an archived investment account after its cash was already closed out to zero once
- **THEN** the closeout transfer becomes available again for the cash that dividend produced

### Requirement: Sell and Dividend Remain Available on an Archived Investment Account
Because inventory cannot be moved by a closeout transfer (a closeout transfer moves cash, not instrument quantity), an archived investment account SHALL continue to permit **Sell** against its remaining inventory, so holdings can be wound down at the user's own pace rather than forced into a single liquidation before archiving is allowed. It SHALL also continue to permit **Dividend**, since a dividend resolves an already-earned economic event rather than opening a new position — the same reasoning as Sell. An archived investment account SHALL NOT permit a new Buy or non-cash acquisition, both of which open or grow a position.

#### Scenario: Selling continues to work after archiving
- **WHEN** the user sells units of a held instrument in an investment account that has been archived
- **THEN** the sell posts normally, increasing cash and reducing inventory
- **AND** the resulting cash remains eligible for the account's closeout transfer

#### Scenario: Dividends continue to work after archiving
- **WHEN** the user records a dividend against an investment account that has been archived
- **THEN** the dividend posts normally, increasing cash
- **AND** the resulting cash remains eligible for the account's closeout transfer

#### Scenario: Buy and non-cash acquisition are blocked once archived
- **WHEN** the user attempts a buy or non-cash acquisition against an archived investment account
- **THEN** the system rejects the action and no journal entry is posted
