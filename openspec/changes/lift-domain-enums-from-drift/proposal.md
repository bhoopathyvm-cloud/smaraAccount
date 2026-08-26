## Why

Domain models re-export Drift table enums (`AccountType`, verification break reasons, pending-transfer kinds, etc.), so the domain↔data seam leaks upward. Domain-word realignment and domain-only tests cannot proceed without touching schema files. Repositories stay shallow adapters mapping rows into models that already speak Drift’s vocabulary.

## What Changes

- Lift shared enums and value types into `lib/domain/` (domain-owned names such as account kind / verification reason).
- Make repositories the only adapters that translate Drift columns ↔ domain types.
- Stop domain models from importing `lib/data/database/tables/*`.
- Broad mechanical rename/import updates across models, repositories, and tests — no intended user-facing behavior change.

## Capabilities

### New Capabilities
- `domain-persistence-seam`: domain types own vocabulary; Drift is an implementation detail behind repository adapters.

### Modified Capabilities
- (none at product-spec level — existing ledger/account/integrity capabilities keep their scenarios; this is seam hygiene)

## Impact

- `lib/domain/models/*`, possibly new `lib/domain/` type files
- `lib/data/database/tables/*` (enums may remain for Drift or map from domain)
- All repositories and tests that construct domain models with Drift enums
- Foundational; large touch surface — schedule after or carefully alongside posting extraction
