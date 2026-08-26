# Architecture Deepening

Conventions for `extract-`/`deepen-`/`unify-`/`finish-` OpenSpec changes, distilled from this repo's architecture-review rounds. Read this — and ADR 0002 — before proposing or implementing a deepening. Also read the `codebase-design` skill for the module/interface/seam/depth/leverage/locality vocabulary these conventions assume.

## Naming

- `extract-<name>` — pull a module out of a larger one (e.g. `extract-ledger-posting-core`, `extract-holdings-trade-order`).
- `deepen-<name>` — give previously-inline or duplicated logic one owned definition, without necessarily relocating a whole module (e.g. `deepen-account-group-invariants`, `deepen-app-navigation-policy`).
- `unify-<name>` — consolidate two existing divergent implementations of the same rule into one (e.g. `unify-register-projection`, `unify-settings-validation`).
- `finish-<name>` — complete a seam a prior change introduced but didn't fully migrate onto (e.g. `finish-chart-catalog-seams`, `finish-investment-income-category-seam`).

## Seam placement

- Prefer the highest existing seam over introducing a new one. Deepen an existing module (e.g. add a method to `AccountRepository`) before reaching for a new top-level package — unless that module is already overloaded.
- **Two adapters justify a seam, one doesn't.** Don't add a named convenience method for a single caller (e.g. a dedicated `requireActiveIncomeCategory`) — call the general method (`requireActiveCategoryOfType`) directly until a second caller needs the same convenience. `finish-investment-income-category-seam` exists because this was skipped once already.
- **Finish the seam in the same change.** When a shared seam is meant to replace N existing hand-rolled call sites, migrate all N in the same change. Leaving any as "a follow-up" is exactly how `finish-chart-catalog-seams` and `finish-investment-income-category-seam` had to exist as their own changes — don't create a third.
- Never introduce a dependency that would close a construction cycle across the `Identity`/`Account`/`Ledger` repository family. Read ADR 0002 before adding a constructor parameter across these repositories.

## Module shape

- A multi-step or multi-field UI flow's in-progress state (funding source, quantity, category selections, CSV column mapping, wizard step) is a plain **mutable** Dart class — not immutable, not a form-framework type — under `lib/domain/<feature>/`. It exposes computed getters (`canSubmit`, `requiresX`) instead of storing derived flags, is constructed fresh per flow instance, and is owned and read/written by the ViewModel. It never touches Drift or a Repository directly. Precedent: `CsvMappingDraft`/`StatementImportSession`, `BuyOrderDraft`/`SellOrderDraft`/`DividendOrderDraft`.
- A value derived from ledger entries and consumed by more than one caller (UI rows, CSV export) is a dedicated domain module (e.g. `RegisterProjection`, `ActiveBalanceEngine`) returning the same DTO every caller uses — not a static helper on the DTO, and not a second copy of the derivation logic on the export path.
- View-agnostic session/draft/projection state lives under `lib/domain/<feature>/`, never inside `lib/ui/features/<feature>/`. Anything that touches Drift stays a repository under `lib/data/repositories/`.
- Apply the deletion test (see the `codebase-design` skill) to anything you suspect is shallow before deepening it.

## DI wiring

- Every new repository or module gets its own `ProxyProvider`/`ProxyProvider2`/`ProxyProvider3` registration in `main.dart`, mirroring the existing `provider`-package pattern. Don't introduce a second DI mechanism to support a deepening.

## Sequencing

- Golden Rule #9 (remove obsolete code in the same change) applies per task group, not only to the change as a whole: when a deepening is too large for one slice, sequence it as multiple task groups, but each group is itself a complete, atomic slice — old surface removed in the same group its replacement lands, every call site updated, `dart analyze`/tests green at the end of every group, not only the last one.
- No compatibility window between groups unless `design.md` documents reason/owner/expiry/cleanup-task, per the Golden Rule #9 exception in `Specs/architecture/smara-tech-guidelines.md`.
- After a big refactor (splitting/moving a repository, changing DI wiring, reshaping a widely-used module), run the full acceptance suite (`tool/run_acceptance_tests.sh -d macos`), not just `flutter test`/`flutter analyze` — see `CLAUDE.md`.

## Testing

- Prefer plain `package:test` unit tests with no Flutter dependency for Flutter-free domain/draft modules.
- The ViewModel stays the seam where a Repository gets mocked (mockito) in tests — draft/domain modules are tested directly, without mocks.
- Keep widget tests for View-level wiring and rendering, not for logic that has moved down into a draft/domain module.
- A deepening that changes structure, not behavior, states that goal explicitly in `design.md`. Any behavior deviation discovered during the migration — intentional or not — gets its own regression test at the seam where it's observable, plus a note in `design.md` explaining why it was kept. Don't let it ship silently under cover of "pure refactor."

## See also

- ADR 0002 — repository dependency graph stays acyclic (D1a).
- `codebase-design` skill — module/interface/depth/seam/adapter/leverage/locality vocabulary.
- `openspec/changes/archive/2026-08-25-architecture-deepening/design.md` — the original `LedgerRepository` split; most of these conventions trace back to decisions made there.
