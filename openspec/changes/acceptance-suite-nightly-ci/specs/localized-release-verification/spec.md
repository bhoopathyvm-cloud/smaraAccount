## MODIFIED Requirements

### Requirement: Full Acceptance Suite Runs Per Curated Locale Before Release
Locale-regression coverage before a release ships SHALL be satisfied by `acceptance-test-suite`'s Nightly Linux CI Tier passing for every supported locale on or near the release candidate's commit, rather than a manual, curated-locale, macOS multi-locale sweep. In addition, the full acceptance suite (`tool/run_acceptance_tests.sh`) SHALL be run once, in English, against a macOS target, and SHALL pass, before a release ships — verifying real macOS platform behavior independent of locale. This macOS check is satisfied manually, by a developer or release owner running `tool/run_acceptance_tests.sh -d macos` with no locale flag; it is never automated in CI (see `acceptance-test-suite`'s manual-only requirement for the entry point itself).

#### Scenario: A release owner runs the pre-release localized check
- **WHEN** a developer prepares a release
- **THEN** they confirm the most recent nightly Linux CI run at or near the release candidate's commit passed for every supported locale, and separately run `tool/run_acceptance_tests.sh -d macos` (no locale flag) to confirm the macOS baseline check passes, before the release proceeds

#### Scenario: A locale fails the pre-release check
- **WHEN** the nightly Linux CI run closest to a release candidate's commit shows a failing locale, or the macOS baseline check fails
- **THEN** the release does not proceed until the failure is investigated and resolved (a fix, a re-run confirming it was transient, or a deliberate, documented decision to ship anyway)

### Requirement: The Pre-Release Step Is Documented, Not Tribal Knowledge
The release checklist SHALL name both pre-release locale/platform checks explicitly: the nightly Linux CI tier (automatic, covers every supported locale, checked rather than run by the release owner) and the macOS baseline check (manual, English only, run by the release owner).

#### Scenario: A new contributor prepares a release
- **WHEN** a contributor who has never prepared a release before follows the release checklist
- **THEN** the checklist names where to check the nightly Linux CI tier's latest result, and the exact command for the macOS baseline check, and states plainly that the macOS check no longer covers multiple locales
