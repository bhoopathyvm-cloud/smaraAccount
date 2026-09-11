# localized-release-verification

## Purpose

A defined, repeatable pre-release requirement that the full real-device acceptance suite runs, and passes, once per locale in the curated set, on macOS, before a release ships — the same kind of assurance a platform-targeted device test gives, applied along the language axis.

## Requirements

### Requirement: Full Acceptance Suite Runs Per Curated Locale Before Release
Before a release ships, the full acceptance suite (`tool/run_acceptance_tests.sh`) SHALL be run once per locale in the curated locale set (`kCuratedAcceptanceLocales`), on a macOS target, and SHALL pass for every locale in that set. This requirement is satisfied manually, by a developer or release owner running `tool/run_localized_acceptance_tests.sh -d macos`; it is never automated in CI (see `acceptance-test-suite`'s existing manual-only requirement, unchanged by this capability).

#### Scenario: A release owner runs the pre-release localized check
- **WHEN** a developer runs `tool/run_localized_acceptance_tests.sh -d macos` before cutting a release
- **THEN** the full acceptance suite runs to completion once per curated locale, and the resulting per-locale summary shows every locale passing before the release proceeds

#### Scenario: A locale fails the pre-release check
- **WHEN** any curated locale's full-suite run fails
- **THEN** the release does not proceed until the failure is investigated and resolved (a fix, or a deliberate, documented decision to exclude that locale from this release's set)

### Requirement: The Pre-Release Step Is Documented, Not Tribal Knowledge
The release checklist SHALL name this step explicitly, including which locales it covers and that it does not cover the other supported locales outside the curated set.

#### Scenario: A new contributor prepares a release
- **WHEN** a contributor who has never run this step before follows the release checklist
- **THEN** the checklist names the exact command to run, the platform it runs on, and states plainly that it verifies only the curated locale set, not every supported locale
