# Contributing

Thanks for considering a contribution. This project follows a spec-first
workflow via [OpenSpec](https://github.com/Fission-AI/OpenSpec): changes
are expected to be driven by a spec, not just a patch dropped on top of
the code.

## Architecture and engineering rules

Before writing any code, read:

- [`Specs/architecture/smara-architecture.md`](Specs/architecture/smara-architecture.md) —
  stack, layering (MVVM + Repository), project structure, and data flow.
- [`Specs/architecture/smara-tech-guidelines.md`](Specs/architecture/smara-tech-guidelines.md) —
  the Golden Rules (spec-first, test-first, immutable posted entries, no
  duplicated dependencies or UI components, and more), responsibility
  boundaries per layer, testing rules, Drift migration rules, and the
  Definition of Done checklist.

This document doesn't repeat those rules — it covers the *process* around
them.

## Feature requests

Feature requests are welcome as issues. A useful issue does not need to be
technical, but it should explain the real need:

- What were you trying to do?
- What felt missing, confusing, or too slow?
- What would a better flow let you accomplish?
- Are there examples, screenshots, files, or edge cases that explain the
  request?

Using AI tools to refine an issue before submitting is welcome. They can
help turn a rough idea into a clearer problem statement, user story,
workflow, examples, or acceptance criteria. This is optional; a plain
human explanation is also fine.

There is no support or implementation SLA. Clear issues are easier to
review and may be picked up as time permits.

## The OpenSpec workflow

Every change goes through four stages:

1. **Propose** — describe what you want to build or fix. This generates a
   `proposal.md` (why), `design.md` (how, for anything non-trivial), one
   or more spec deltas under `specs/<capability>/spec.md` (what — testable
   requirements and scenarios), and a `tasks.md` checklist.
2. **Apply** — implement the change by working through `tasks.md`,
   checking off each task as it's done. Code should never implement
   behavior that isn't covered by a spec scenario — if it's not covered,
   the spec delta comes first.
3. **Review** — open a pull request (see below).
4. **Archive** — once merged, the change's spec deltas are folded into
   `openspec/specs/<capability>/spec.md`, the single source of truth for
   that capability's current requirements, and the change moves to
   `openspec/changes/archive/`.

Every requirement in a spec delta is written as a testable `SHALL`/`MUST`
statement with at least one `WHEN`/`THEN` scenario — if you can't write a
scenario for it, it's not specified precisely enough to implement yet.

## Branching and pull requests

- **Nothing is committed directly to `main`.** Every change gets its own
  branch, named after the OpenSpec change it implements (e.g.
  `core-ledger-single-account`, `ledger-integrity-signing`).
- Commits for that change go on that branch, then open a pull request
  from your branch/fork into `main`.
- Keep a PR scoped to the one OpenSpec change it implements — a change
  that touches something unrelated (a dependency bump, an unrelated bug
  fix) belongs in its own PR.
- No formal support or review SLA is provided. If something doesn't get
  merged or reviewed promptly, feel free to fork and continue
  independently.

## Definition of done

Before opening a PR, run through
[`smara-tech-guidelines.md`'s Definition of Done checklist](Specs/architecture/smara-tech-guidelines.md#definition-of-done) —
in short: behavior matches its spec scenario exactly, tests exist at every
applicable tier (unit, widget, integration), `dart analyze` is clean, and
nothing the change replaces (a widget, a Repository method, a dependency)
is left behind unused.
