## ADDED Requirements

### Requirement: Real-Build Coverage of Investment Account Cash and Inventory
The acceptance suite SHALL include an independently runnable group that
launches the real `SmaraAccountingApp` root widget, creates an
investment account through the real Accounts GUI, and asserts cash and
empty inventory on the real holdings screen. The group SHALL reuse the
existing acceptance harness and cleanup helpers.

#### Scenario: Opening cash seeds holdings cash and leaves inventory empty
- **WHEN** the acceptance test completes onboarding, creates an asset
  account flagged as holding investments with a positive opening cash
  amount, and opens that account's holdings screen
- **THEN** holdings shows that opening amount as cash
- **AND** inventory is empty (no instrument rows)

#### Scenario: Cash in and cash out leave inventory unchanged
- **WHEN** the acceptance test transfers cash from another active
  account into the investment account, then transfers a smaller amount
  back out, through the real Transfer GUI
- **THEN** holdings cash reflects both transfers
- **AND** inventory remains empty

#### Scenario: Cash out greater than cash is rejected
- **WHEN** the acceptance test attempts a transfer out of the
  investment account larger than its cash
- **THEN** the real UI shows an error
- **AND** cash is unchanged

#### Scenario: Ordinary spent against investment cash does not touch inventory
- **WHEN** the acceptance test records a Spent transaction against the
  investment account through the real record-transaction GUI
- **THEN** holdings cash decreases by that amount
- **AND** inventory remains empty

#### Scenario: A zero-cash investment account cannot buy until funded
- **WHEN** the acceptance test creates an investment account with no
  opening cash and submits a cash-funded Buy
- **THEN** the real UI rejects the buy
- **AND** inventory remains empty

### Requirement: Real-Build Coverage of Buy, Sell, and Dividend
The same acceptance group SHALL walk Buy, Sell, and Dividend through
the real holdings dialogs against the real on-disk ledger, covering
cash-funded brokerage, a non-cash locked lot, a sell, and a dividend.

#### Scenario: Cash-funded buy with brokerage updates cash and inventory
- **WHEN** the acceptance test records a cash-funded Buy of a new
  instrument (kind chosen from the fixed list) with a positive
  brokerage amount and an expense category
- **THEN** holdings lists that instrument with the bought quantity
- **AND** cash has decreased by quantity × price plus brokerage

#### Scenario: Employer-match buy with lock-until blocks selling the locked unit
- **WHEN** the acceptance test records a cash-funded Buy of 3 units and
  a non-cash acquisition of 1 unit with a future lock-until date
- **THEN** inventory shows 4 units
- **AND** a Sell of 4 units is rejected with a message that includes
  the lock-until date

#### Scenario: Sell of unlocked units at a gain increases cash and reduces inventory
- **WHEN** the acceptance test sells a quantity no greater than the
  unlocked holding at a price above cost, with an income category
- **THEN** inventory quantity decreases by the sold amount
- **AND** cash increases

#### Scenario: Dividend increases cash without changing quantity
- **WHEN** the acceptance test records a Dividend for a held instrument
- **THEN** cash increases by the dividend amount
- **AND** the instrument's quantity is unchanged

#### Scenario: Dividend still posts after the position is fully sold
- **WHEN** the acceptance test sells the remaining sellable quantity
  and then records a Dividend for that instrument
- **THEN** the dividend posts and cash increases
- **AND** inventory does not list a positive quantity for that
  instrument

### Requirement: Real-Build Coverage of Archive, Closeout, and Home Portfolio
The same acceptance group SHALL cover archiving an investment account
(sell and dividend remain available; buy does not; cash closeout can
run more than once) and the home overview showing a labeled market
estimate.

#### Scenario: Archived investment account allows sell and repeatable cash closeout
- **WHEN** the acceptance test archives an investment account that has
  cash, closes that cash out to another account, then sells remaining
  units
- **THEN** Buy is not offered (or is disabled) while archived
- **AND** the closeout-transfer affordance appears again for the new
  cash

#### Scenario: Home shows a labeled market estimate and opens holdings
- **WHEN** quotes are disabled and the user views Home after recording
  cash plus at least one holding
- **THEN** the investment account's home amount is presented as a
  market estimate (cash plus cost when no live quote)
- **AND** tapping the account opens the holdings screen

#### Scenario: The investment group runs independently
- **WHEN** a developer runs only
  `integration_test/acceptance/investment_holdings_test.dart`
- **THEN** it completes using the same real-build harness and cleanup
  as the rest of the acceptance suite, without requiring any other
  acceptance file to run first
