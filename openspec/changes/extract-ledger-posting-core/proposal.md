## Why

The first repository split peeled off shallow CRUD modules (Category, Payee, Backup) but left `LedgerRepository` (~1,756 lines) owning posting/signing, foreign-currency provisional entries, home overview aggregation, CSV export, and duplicated account-read adapters to dodge dependency cycles. Posting complexity is diluted across one oversized module instead of concentrated behind a small posting interface — the architecture review's top deepening candidate.

## What Changes

- Extract signing/posting (append signed entry, record transaction, reverse entry, pending transfers) into a deep internal posting module with a small interface.
- Introduce a cycle-free shared account/chart read path for overview and export so `LedgerRepository` no longer hosts private duplicate account-read adapters.
- Shrink `LedgerRepository` to orchestration and query streams (or rename to match that role) without changing user-visible ledger behavior.
- Rewire DI and callers that only need posting or reads onto the narrower modules.

## Capabilities

### New Capabilities
- `ledger-posting-core`: the posting/signing module's interface, cycle-free read seam for chart/overview, and preservation of existing journal/integrity behavior behind that extraction.

### Modified Capabilities
- (none — product requirements for recording, reversing, integrity signing, and multi-account flows stay the same; this is internal deepening)

## Impact

- `lib/data/repositories/ledger_repository.dart` and callers: `investment_repository.dart`, `identity_repository.dart`, `recurring_template_repository.dart`, `statement_import_repository.dart`, `account_repository.dart`
- `lib/main.dart` provider graph
- Unit/INTEGRATION tests that construct `LedgerRepository` for posting
- No Drift schema change; no acceptance-scenario requirement changes; no ADR 0001 conflict
