## ADDED Requirements

### Requirement: Target resolution and shortfall comparability live behind one policy
The system SHALL determine a pending transfer's resolved settlement target
account and whether the settlement follows the shortfall path through a
single Flutter-free `PendingTransferSettlement`. The settle-pending form and
the ledger write path MUST both resolve through it rather than restating the
rule.

#### Scenario: Transfer returning to source is the shortfall path
- **WHEN** a transfer's chosen settled-to account is its own source account
- **THEN** the resolved target is that source account and the settlement is shortfall-comparable

#### Scenario: Transfer delivered to destination is not shortfall-comparable
- **WHEN** a transfer's chosen settled-to account is its destination
- **THEN** the resolved target is that destination and the settlement is not shortfall-comparable

#### Scenario: Foreign transaction always resolves to source
- **WHEN** a foreign-transaction pending item is settled
- **THEN** the resolved target is its source account and the settlement is not shortfall-comparable, regardless of any chosen account

#### Scenario: Policy is unit-testable without a ChangeNotifier or Drift
- **WHEN** a test resolves a `PendingTransferSettlement` from primitives
- **THEN** the resolved target and shortfall flag are asserted with `package:test` alone

### Requirement: Existing settle behavior preserved
Unifying the rule SHALL NOT change settlement validation, posting legs, or currency handling.

#### Scenario: Existing settle draft and posting tests still pass
- **WHEN** settle-pending draft, repository, and acceptance tests run after the migration
- **THEN** they pass without weakening assertions
