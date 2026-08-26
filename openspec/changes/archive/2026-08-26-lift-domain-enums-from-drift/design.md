## Context

Domain models under `lib/domain/models/` import or re-export enums defined next to Drift tables. That couples domain vocabulary to persistence and blocks domain-word realignment without schema edits. Repositories already map rows ↔ models but the models still speak Drift.

## Goals / Non-Goals

**Goals:**
- Domain-owned types for account kind, verification reasons, pending-transfer kinds, and similar shared enums.
- Repositories are the only adapters mapping Drift ↔ domain.
- Domain unit tests compile without importing Drift table files.

**Non-Goals:**
- Renaming user-visible strings or changing account taxonomy behavior.
- Rewriting the entire domain model layer in one unrelated cleanup.
- Changing Drift schema column types unless required for the lift (prefer map-only).

## Decisions

### Decision 1 — Lift enums first; keep Drift enums as persistence mirrors if needed

**Options:** (A) Delete Drift enums and use domain enums in table definitions; (B) Keep Drift enums, map at repository; (C) Codegen shared enums.

**Decision: B unless Drift requires the same type in column defs** — then prefer domain types referenced from tables only if that stays a one-way dependency (domain ↚ data). Prefer domain does not import data.

### Decision 2 — Mechanical migration with analyzer-driven sweep

Rename imports file-by-file; keep git history readable with focused commits if the change is large.

### Decision 3 — Coordinate with posting/projection work

Prefer landing after or carefully beside `extract-ledger-posting-core` to avoid merge pain in `ledger_repository.dart`.

## Risks / Trade-offs

- **[Risk]** Large blast radius → **Mitigation:** one enum family per PR if needed; keep green `dart analyze` + unit suite gates.
- **[Risk]** Accidental behavior change via wrong default mapping → **Mitigation:** exhaustive switch tests on mappers.

## Migration Plan

1. Introduce domain types + mappers.
2. Switch models to domain types.
3. Update call sites; remove domain→data imports.
4. Rollback = revert; no user data migration.

## Open Questions

- Exact domain type names (align with CONTEXT / glossary when present).
