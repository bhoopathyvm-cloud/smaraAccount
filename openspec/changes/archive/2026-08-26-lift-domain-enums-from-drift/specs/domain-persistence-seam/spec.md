## ADDED Requirements

### Requirement: Domain vocabulary does not import Drift tables
Domain model types SHALL NOT import `lib/data/database/tables` (or equivalent Drift table libraries) for shared enums and value types. Persistence enums, if they remain, MUST be translated at repository adapters.

#### Scenario: Domain package analyzes without table imports
- **WHEN** `dart analyze` runs on domain model sources after the lift
- **THEN** no domain model file imports Drift table enum definitions for account kind, verification reason, or pending-transfer kind

#### Scenario: Repository maps Drift to domain
- **WHEN** a repository reads a row that uses a Drift enum column
- **THEN** it maps that column to the domain type before returning a domain model

### Requirement: Product behavior unchanged
Lifting enums SHALL NOT change journal, account, or integrity outcomes visible to users.

#### Scenario: Existing ledger unit suites pass
- **WHEN** the project's unit tests for ledger and accounts run after the lift
- **THEN** they pass with mapper updates only (no weakened assertions)
