## Context

Preview deepening left `StatementImportViewModel` as a ~616-line orchestrator (step machine, CSV columns, grouping). Architecture review ranked this Worth exploring: views are already lean; the VM interface is still as wide as the implementation.

## Goals / Non-Goals

**Goals:**
- Flutter-free `StatementImportSession` with a small interface.
- Thin ChangeNotifier adapter.
- Keep `buildPreviewRows` / `postAcceptedRows`.

**Non-Goals:**
- New import file formats.
- Changing OFX vs CSV product rules.
- Re-doing preview batching.

## Decisions

### Decision 1 — Session in domain, not another repository

**Options:** (A) More methods on StatementImportRepository; (B) Domain session; (C) Keep in VM.

**Decision: B.** Repository stays I/O + preview/post. Session is in-process wizard state.

### Decision 2 — Snapshot for the UI

VM exposes an immutable snapshot (step, mapping fields, rows/groups) so widgets do not reach into session internals.

## Risks / Trade-offs

- **[Risk]** Large first PR → **Mitigation:** move state first, keep method names; then slim the VM.
- **[Trade-off]** Two types (session + VM) until widgets bind to snapshot only.

## Migration Plan

1. Extract session with parity tests against current VM behavior.
2. VM delegates; widget tests still construct VM.
3. Delete leftover VM fields.

## Open Questions

- Exact type name (`StatementImportSession` vs `StatementImportWizard`).
