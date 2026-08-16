## Purpose

Record investment holdings (instruments, quantities, cost, optional display marks) on investment accounts as a local schedule backed by ordinary signed journal entries — not a dealing desk, broker, or live market.

## ADDED Requirements

### Requirement: Investment Accounts May Hold Positions
An asset financial account MAY be marked as an investment account at creation. Only an investment account SHALL be allowed to hold instruments. The investment-account flag SHALL NOT be changeable after creation. A non-investment financial account SHALL reject any attempt to acquire a holding.

#### Scenario: Create an investment account
- **WHEN** the user creates an asset financial account marked as an investment account
- **THEN** the account can acquire and dispose holdings
- **AND** it remains a normal asset account for transfers, income, expense, opening balance, archive, and the home overview

#### Scenario: Ordinary asset cannot hold a position
- **WHEN** the user attempts to acquire a holding against a financial account that is not marked as an investment account
- **THEN** the system rejects the acquire and no journal entry is posted

#### Scenario: Investment flag cannot change after creation
- **WHEN** the user attempts to turn an existing financial account into an investment account, or to clear the flag on an investment account
- **THEN** the system rejects the change

### Requirement: User-Defined Instruments
The user SHALL be able to create an instrument with a name, a kind (equity, fund, bond, or other), and optional ticker and ISIN identifiers. The user SHALL be able to rename an instrument and archive an instrument that is no longer needed. Instruments SHALL NOT be permanently deleted. An archived instrument SHALL NOT be offered for a new acquire, and SHALL remain visible on existing holdings.

#### Scenario: Create an instrument
- **WHEN** the user creates an instrument with a name and a kind
- **THEN** the instrument is available when acquiring a holding

#### Scenario: Archive an instrument
- **WHEN** the user archives an instrument
- **THEN** it is no longer offered for a new acquire
- **AND** existing holdings that reference it remain visible

### Requirement: Acquire a Holding
The user SHALL record an acquire by providing an investment account, an active instrument, a positive quantity, a positive cost in the investment account's group currency, a transaction date, and a distinct active funding financial account. The system SHALL post a same-currency or cross-currency movement of that cost from the funding account to the investment account using the existing transfer rules of `multi-account-ledger` and `foreign-currency-settlement`, and SHALL add or increase a holding lot for that instrument on the investment account. The user SHALL NOT be asked to place an order with a broker.

#### Scenario: Acquire funded from a cash account
- **WHEN** the user acquires a positive quantity of an instrument on an investment account, funded from a different active financial account, with a positive cost
- **THEN** the system posts the cost as a transfer from the funding account to the investment account
- **AND** the investment account's holding in that instrument increases by the given quantity and cost

#### Scenario: Non-positive quantity or cost is rejected
- **WHEN** the user attempts an acquire with a zero or negative quantity, or a zero or negative cost
- **THEN** the system rejects the acquire and no journal entry is posted

#### Scenario: Acquire against an archived investment account is rejected
- **WHEN** the user attempts an acquire on an archived investment account
- **THEN** the system rejects the acquire and no journal entry is posted

### Requirement: Dispose a Holding
The user SHALL record a dispose by providing an investment account, an instrument already held there, a positive quantity no greater than the quantity held, proceeds in the investment account's group currency (zero allowed only for a total write-off), a transaction date, a distinct active destination financial account, and — when proceeds differ from the cost removed — an active income category (gain) or expense category (loss). The system SHALL reduce the holding's quantity and cost (average cost), SHALL post a balanced journal entry that moves proceeds to the destination, reduces the investment account by the cost removed, and records any difference as income or expense, and SHALL NOT place a broker order.

#### Scenario: Dispose at a gain
- **WHEN** the user disposes part or all of a holding for proceeds greater than the average cost removed, to a different active financial account, with an active income category
- **THEN** the destination account is credited the proceeds
- **AND** the investment account is reduced by the cost removed
- **AND** the income category is credited the difference
- **AND** the holding's remaining quantity and cost decrease accordingly

#### Scenario: Dispose at a loss
- **WHEN** the user disposes a holding for proceeds less than the average cost removed, with an active expense category
- **THEN** the destination account is credited the proceeds
- **AND** the investment account is reduced by the cost removed
- **AND** the expense category is debited the difference

#### Scenario: Disposing more than held is rejected
- **WHEN** the user attempts to dispose a quantity greater than the quantity held
- **THEN** the system rejects the dispose and no journal entry is posted

### Requirement: Display Marks Do Not Post
The user SHALL be able to enter or clear a last-known price for a holding as a display mark. A mark SHALL NOT create, update, or delete a journal entry or posting. Unrealized gain or loss computed from a mark SHALL be display-only.

#### Scenario: Entering a mark does not change the ledger
- **WHEN** the user enters a last-known price for a holding
- **THEN** no journal entry is posted
- **AND** the investment account's ledger display balance is unchanged
- **AND** the holdings view may show a marked value and an unrealized difference

#### Scenario: Clearing a mark
- **WHEN** the user clears a holding's last-known price
- **THEN** the holdings view no longer shows a marked value for that holding
- **AND** no journal entry is posted

### Requirement: No Dealing Desk
The system SHALL NOT place, route, or execute orders with a broker or exchange, SHALL NOT synchronize with a brokerage API, and SHALL NOT fetch live market quotes as part of this capability. Acquire and dispose are user-recorded facts about holdings the user already has or no longer has.

#### Scenario: No broker or quote action is offered
- **WHEN** the user opens an investment account's holdings view
- **THEN** the offered actions are acquire, dispose, and optional display mark
- **AND** there is no buy/sell order ticket and no live quote button
