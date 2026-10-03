# localized-release-verification

## Purpose

A defined, repeatable pre-release requirement that locale-regression coverage and macOS platform behavior are both verified before a release ships — locale coverage via the nightly Linux CI tier, macOS platform behavior via a manual English-only baseline check.

## Requirements

### Requirement: Full Acceptance Suite Runs Per Curated Locale Before Release
Locale-regression coverage before a release ships SHALL be satisfied by a run of `acceptance-test-suite`'s scheduled Linux CI tier workflow, dispatched manually by the release owner on the release candidate's exact commit, passing for every supported locale. A scheduled (weekly) run SHALL NOT substitute for this candidate run. In addition, the full acceptance suite (`tool/run_acceptance_tests.sh`) SHALL be run once, in English, against a macOS target, and SHALL pass, before a release ships — verifying real macOS platform behavior independent of locale. This macOS check is satisfied manually, by a developer or release owner running `tool/run_acceptance_tests.sh -d macos` with no locale flag; it is never automated in CI.

#### Scenario: A release owner runs the pre-release localized check
- **WHEN** a developer prepares a release
- **THEN** they dispatch the acceptance workflow on the candidate commit and confirm every supported locale passed, and separately run `tool/run_acceptance_tests.sh -d macos` (no locale flag) to confirm the macOS baseline check passes, before the release proceeds

#### Scenario: A locale fails the pre-release check
- **WHEN** the candidate run shows a failing locale, or the macOS baseline check fails
- **THEN** the release does not proceed until the failure is investigated and resolved (a fix, a re-run confirming it was transient, or a deliberate, documented decision to ship anyway)

### Requirement: The Pre-Release Step Is Documented, Not Tribal Knowledge
The release checklist SHALL name both pre-release locale/platform checks explicitly: the manually dispatched Linux CI run on the candidate commit (covers every supported locale) and the macOS baseline check (manual, English only, run by the release owner). After those gates, the checklist's platform release steps SHALL point at `docs/release/store-release-runbook.md` for store uploads and rollouts, and SHALL continue to point at `docs/release/android-upload-keystore.md` for upload-keystore setup.

#### Scenario: A new contributor prepares a release
- **WHEN** a contributor who has never prepared a release before follows the release checklist
- **THEN** the checklist names how to dispatch the Linux CI run on the candidate and where to read its result, and the exact command for the macOS baseline check, and states plainly that the macOS check does not cover multiple locales

#### Scenario: Checklist points at the store release runbook
- **WHEN** a release owner has satisfied the locale and macOS gates and needs to push binaries to the stores
- **THEN** the checklist's platform steps link to `docs/release/store-release-runbook.md`
