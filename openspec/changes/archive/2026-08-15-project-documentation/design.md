## Context

Two solid architecture/engineering docs already exist at
`Specs/architecture/smara-architecture.md` (stack, layering, project
structure, data flow) and `Specs/architecture/smara-tech-guidelines.md`
(Golden Rules, responsibility boundaries, testing rules, migration rules,
Definition of Done, build quality gates). Both are accurate and don't need
rewriting. Their problem is discoverability: `Specs/` isn't a path a
contributor arriving via GitHub's normal "Contributing" prompts (which look
for `CONTRIBUTING.md` at the repo root) would ever open, and `README.md`
doesn't mention either file exists.

Separately, there is no user-facing documentation of the app's features at
all — only inline code comments and OpenSpec requirement text, neither of
which is written for an end user.

The full current feature set (confirmed via `lib/ui/app_router.dart` and
`lib/ui/features/*`): onboarding (recovery phrase, keystore export,
confirmation, currency selection, one-time currency backfill for
pre-multi-currency databases), restore (recoverable reinstall/device
migration via phrase or keystore), home, register, record-transaction,
transfer (including settle-pending-transfer), account management, category
management, statement import (OFX/CSV), and settings (reference
exchange-rate lookup + provider selection).

## Goals / Non-Goals

**Goals:**
- Give a new user a single, accurate document covering every screen/flow
  in the current app, including the security-critical parts (recovery
  phrase, keystore export, the "lost key = unrecoverable" tradeoff) that
  the README already flags as important but doesn't walk through
  step-by-step.
- Give a new contributor a single, root-level document that explains the
  process (OpenSpec workflow, branching, PRs) and points them at the
  existing architecture/guidelines docs for the rest, rather than
  re-explaining engineering rules that are already well-written.

**Non-Goals:**
- Rewriting, restructuring, or relocating the existing
  `Specs/architecture/*.md` docs — they're current and correct.
- Documenting the not-yet-implemented `import-category-rules` change as if
  it were live; the user guide describes the app as it exists today.
- API docs, dartdoc generation, or any tooling change — this is prose
  documentation only.

## Decisions

- **Two separate documents for two separate audiences**, matching the
  proposal's two new capabilities: `docs/user-guide.md` for end users,
  `CONTRIBUTING.md` for contributors. A single combined doc would force
  one audience to scroll past content meant for the other.
- **`CONTRIBUTING.md` at the repository root**, not under `docs/` or
  `Specs/` — this is the conventional location GitHub itself looks for and
  surfaces automatically (in the "Contributing" prompt shown when opening
  an issue or PR).
- **`CONTRIBUTING.md` links to and summarizes, rather than duplicates,**
  `Specs/architecture/smara-architecture.md` and
  `smara-tech-guidelines.md`. Duplicating the Golden Rules into a second
  document would violate the project's own Golden Rule #8/#9 spirit (avoid
  redundant, divergence-prone copies) — the two docs would drift out of
  sync the next time the guidelines change. `CONTRIBUTING.md` instead
  covers what those docs don't: the OpenSpec propose/apply/archive
  workflow end to end, the branch-per-change convention (already stated
  briefly in `README.md`), and the PR submission process, then links to
  the architecture docs for everything else.
- **`docs/user-guide.md` lives under a new `docs/` directory**, not the
  repo root, to keep the root uncluttered as more documentation is
  inevitably added later (matches common convention: root holds
  `README.md`/`CONTRIBUTING.md`/`LICENSE`/`SECURITY.md`, longer-form docs
  live under `docs/`).
- **`README.md` gets two new links, not new prose** — a "Usage" pointer to
  `docs/user-guide.md` and an expanded "Contributing" section pointing to
  the new `CONTRIBUTING.md` — keeping `README.md` itself short, per its
  existing style.

## Risks / Trade-offs

- [The user guide can drift out of date as features change, since nothing
  enforces it stays current.] → Mitigation: tasks.md includes verifying
  guide content against the actual current UI/routes at write time (not
  from memory of past conversations), and the guide explicitly scopes
  itself to already-shipped features only, so it never describes planned
  work as real.
- [`CONTRIBUTING.md` could go stale if the OpenSpec workflow or Golden
  Rules change without updating it.] → Mitigation: by linking to
  `smara-tech-guidelines.md` rather than copying its rules,
  `CONTRIBUTING.md` only needs to change if the *process* (not the
  engineering rules) changes.
