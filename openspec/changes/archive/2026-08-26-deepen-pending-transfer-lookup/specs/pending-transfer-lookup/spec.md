## ADDED Requirements

### Requirement: Pending-transfer summary is loadable by id
The system SHALL expose a lookup that, given a pending-transfer id, returns the joined summary (counterparty/category names, currency, amount) used by the settle screen. That lookup MUST NOT require `HomeViewModel` or an already-built home overview.

#### Scenario: Settle route does not read Home
- **WHEN** the app opens `/settle-pending-transfer/:id`
- **THEN** the route loads the summary through the lookup seam, not by scanning `HomeViewModel.overview.pendingTransfers`

#### Scenario: Missing id still looks settled
- **WHEN** the id is unknown or already settled
- **THEN** the user still sees the existing already-settled treatment (not a crash)

### Requirement: Home list and settle share the join
Home overview pending rows and the settle lookup SHALL use the same summary assembly so names/currency/amount cannot drift.

#### Scenario: Same summary shape
- **WHEN** Home lists a pending transfer and the user opens settle for that id
- **THEN** both surfaces show the same names, currency, and amount from one join implementation
