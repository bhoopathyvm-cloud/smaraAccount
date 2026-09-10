## ADDED Requirements

### Requirement: Locale Is Selectable Per Run
The system SHALL allow a developer to select a target locale for an acceptance suite run, in addition to the target device. When no locale is specified, the run SHALL behave identically to the suite's original English-only run. When a non-English locale is specified, the suite SHALL drive the app's own first-launch language screen to reach that locale — never a test-only backdoor or a platform-level locale override — and SHALL resolve every UI-text assertion and every test-authored fixture string against that same locale for the rest of the run.

#### Scenario: Running without a locale argument
- **WHEN** a developer runs the acceptance suite without specifying a locale
- **THEN** the run behaves exactly as before this requirement existed: onboarding proceeds in English and all assertions use English strings

#### Scenario: Running with a specific locale argument
- **WHEN** a developer runs the acceptance suite with a supported locale tag
- **THEN** onboarding selects that locale on the real first-launch language screen, and every subsequent UI-text assertion and typed-in fixture string in the run uses that locale

#### Scenario: An unsupported locale tag is rejected
- **WHEN** a developer specifies a locale tag that has no matching localization
- **THEN** the run fails fast with an error naming the unsupported tag, rather than silently falling back to English

### Requirement: Curated Multi-Locale Run
The system SHALL provide a way to run the acceptance suite once per locale across a fixed, curated set of locales chosen to cover right-to-left scripts, CJK scripts, every locale with an official BIP39 recovery-phrase wordlist, and at least one lower-review-confidence translation, in a single developer-invoked command. This tier SHALL remain outside the `flutter-ci.yml` pull request gate and SHALL NOT run automatically, consistent with the acceptance suite's existing manual-only entry point.

#### Scenario: Developer runs the curated multi-locale suite
- **WHEN** a developer runs the curated multi-locale command with a device argument
- **THEN** the acceptance suite runs to completion once per curated locale against that device, and a per-locale pass/fail summary is reported at the end

#### Scenario: One locale's failure does not hide another's result
- **WHEN** one locale's run fails partway through the curated multi-locale command
- **THEN** the command continues on to the remaining locales rather than stopping, and the final summary reports every locale's outcome

#### Scenario: The curated multi-locale suite is never invoked by CI
- **WHEN** any GitHub Actions workflow in this repository runs
- **THEN** none of them invoke the curated multi-locale acceptance command
