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
- [`Specs/design/smara-design-system.md`](Specs/design/smara-design-system.md) —
  the 3-color rule, typography, navigation, shared components, icons.
- [`CONTEXT.md`](CONTEXT.md) — the domain glossary, and
  [`docs/adr/`](docs/adr/) — architecture decision records.
- [`docs/agents/architecture-deepening.md`](docs/agents/architecture-deepening.md) —
  conventions for `extract-`/`deepen-`/`unify-`/`finish-` refactoring
  changes.

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
   `openspec/changes/archive/`. Archive only when **every** task in
   `tasks.md` is checked — `openspec-archive-guard.yml` (and the local
   `tool/git-hooks/pre-push` hook) rejects archiving a change with an
   unchecked or partial task.

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
- **Formatting is required.** Enable the repository's git hooks once per
  clone with `git config core.hooksPath tool/git-hooks`. The pre-commit hook
  formats staged Dart files and runs `flutter analyze`; CI's "Format,
  analyze, and test" check must pass before a PR can merge. AI coding
  agents follow the same rule (see `CLAUDE.md`, `AGENTS.md`,
  `.cursor/rules/code-formatting.mdc` and
  `.github/copilot-instructions.md`).

## Acceptance testing

Beyond unit/widget/integration tests (all run in CI on every push and pull
request), the repo has an ACCEPTANCE tier in
`integration_test/acceptance/acceptance_test.dart`: it drives a real,
launched build of the app through its GUI against a real on-disk database
and real OS keychain/keystore. Its 37 tests are organized as one `group()`
per capability area (account currency, core ledger, CSV import,
currency/transfers, group archive, home and lock, identity restore,
investment holdings, investment research, ledger backup, OFX import,
onboarding, organization). Run it via:

```sh
tool/run_acceptance_tests.sh -d <device-id> [-l <locale-tag>] [group]
```

Run the full suite (omit `[group]`) on each target platform you want
confidence on — macOS, Linux, an iOS simulator, an Android emulator —
after finishing a large change and before opening a PR; after a big
refactor, always run it on `-d macos` (see `CLAUDE.md`). `-l` drives
onboarding to one of the 43 supported locales. See the script's own header
comments for device-id discovery per platform.

The same suite also runs **weekly in CI** on Linux, once per supported
locale (`.github/workflows/acceptance-suite-nightly.yml`, "Acceptance Suite
Weekly"). That run does not block pull requests. Before a release, the
release owner dispatches it manually on the release candidate (see
[the release checklist](docs/release/checklist.md)).

## Documentation

When a change alters what a user sees or does, update
[`docs/user-guide.md`](docs/user-guide.md) in the same change (the
`user-guide` spec requires it to describe only shipped behavior). New
user-visible strings go in `lib/l10n/app_en.arb` using the household
wording in [`docs/household-term-map.md`](docs/household-term-map.md);
new domain terms go in [`CONTEXT.md`](CONTEXT.md). A change that adds or
alters a network request or what is stored on the device also updates the
[privacy policy page](pages/open-source/smara-account/privacy-policy.md)
and `SECURITY.md`.

## Definition of done

Before opening a PR, run through
[`smara-tech-guidelines.md`'s Definition of Done checklist](Specs/architecture/smara-tech-guidelines.md#definition-of-done) —
in short: behavior matches its spec scenario exactly, tests exist at every
applicable tier (unit, widget, integration), `dart analyze` is clean, and
nothing the change replaces (a widget, a Repository method, a dependency)
is left behind unused.

## Store release

Follow the [store release runbook](docs/release/store-release-runbook.md)
for every release: calendar version and shared build number, release
gates, tag and GitHub Release, then Google Play, iOS, and the Mac App
Store. The gates themselves are in the
[release checklist](docs/release/checklist.md), and English store listing
sources and screenshots live in
[`docs/release/store-listing/`](docs/release/store-listing/README.md).

Android upload signing and the first Play Console upload are documented in
[`docs/release/android-upload-keystore.md`](docs/release/android-upload-keystore.md).
Mac App Store sandboxing is on for **Release** entitlements; local
`flutter run -d macos` stays unsandboxed until a real Apple Developer Team
is configured in Xcode (Signing & Capabilities on the `Runner` target).
