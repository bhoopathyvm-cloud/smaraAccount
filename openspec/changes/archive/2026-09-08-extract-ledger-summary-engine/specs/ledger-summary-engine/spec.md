## ADDED Requirements

### Requirement: Summary aggregation lives behind one domain engine
The system SHALL compute `LedgerSummary` and `CategoryTotal` lists through a Flutter-free summary engine that applies shared quarantine, migration-supersession, and income/expense magnitude rules. `LedgerRepository.watchSummary` and `CategoryRepository.watchCategoryTotals` MUST map Drift rows into engine inputs rather than inlining those rules.

#### Scenario: Quarantined posting excluded from both surfaces
- **WHEN** a posting belongs to an unverified entry
- **THEN** it contributes neither to `LedgerSummary` nor to `CategoryTotal` totals

#### Scenario: Account filter on summary
- **WHEN** `buildLedgerSummary` is called with `financialAccountId`
- **THEN** only entries that touch that account are included (all their income/expense lines)
