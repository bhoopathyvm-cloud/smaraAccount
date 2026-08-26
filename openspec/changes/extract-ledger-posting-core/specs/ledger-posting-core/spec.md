## ADDED Requirements

### Requirement: Posting lives behind one deep module
The system SHALL concentrate journal posting and integrity signing (append signed entry, record transaction, reverse entry, and pending-transfer writes that post through the same chain) behind a single posting module with a small interface. Callers that only need posting MUST NOT depend on unrelated ledger read concerns (CSV export layout, home overview aggregation) to post an entry.

#### Scenario: Record transaction uses posting module
- **WHEN** a ViewModel or repository records a journal transaction
- **THEN** the write goes through the posting module's interface rather than a private copy of signing/chaining logic in an unrelated repository method

#### Scenario: Existing posting behavior is preserved
- **WHEN** the existing unit and INTEGRATION suites for record, reverse, and integrity signing run after extraction
- **THEN** they pass without changing product assertions (only construction/DI may change)

### Requirement: Cycle-free chart read seam
The system SHALL provide a shared account/chart read path used for overview and export needs so posting code MUST NOT host private duplicate account-watch or identity-lookup adapters solely to avoid dependency cycles.

#### Scenario: No duplicate private account watch in posting module
- **WHEN** posting and account-chart reads are needed in the same process
- **THEN** account chart data is obtained through the shared read seam, not a second private `_watchFinancialAccounts`-style adapter inside the posting module

### Requirement: Extraction does not change user-visible ledger outcomes
Extracting the posting core SHALL NOT change amounts, counterparties, signatures, or quarantine visibility for users.

#### Scenario: Acceptance core ledger still green
- **WHEN** `tool/run_acceptance_tests.sh -d macos core_ledger` runs after extraction
- **THEN** all scenarios in that group pass
