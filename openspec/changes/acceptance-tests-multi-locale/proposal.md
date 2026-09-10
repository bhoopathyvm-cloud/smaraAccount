## Why

The acceptance suite (`tool/run_acceptance_tests.sh`) only ever runs the app in English, even though the app ships 43 locales with varying translation quality (some professionally reviewed, some AI-drafted). A localization bug — a missing key silently falling back to English, an untranslated string breaking a `tapReliably`/`enterTextReliably` lookup, a RTL layout that clips a button, a currency default that's wrong for a locale — can only be caught by driving the real GUI in that locale. Nothing today does that; the `onboarding-language-selection` change added real per-locale behavior (currency defaults, BIP39-wordlist recovery phrases, RTL support) with no acceptance-level regression coverage across locales.

## What Changes

- The existing acceptance suite becomes parameterizable by locale: the same test bodies in `integration_test/acceptance/acceptance_test.dart` run unchanged, but the app is driven through onboarding in a caller-selected locale (via the app's own first-launch language screen, tapping the target locale row instead of "Same as device") instead of always English.
- A new locale-fixture lookup supplies the handful of test-authored strings the suite types into the app during a run (category names, payee names, transaction descriptions, search terms, etc.) in the selected locale, so what a run "types" and asserts on both belong to that locale — not just the app's own UI chrome.
- A new opt-in developer entry point runs the full suite once per locale for a small, deliberately curated set of locales (not all 43) chosen to cover the highest-risk classes of localization bugs: RTL script, CJK script, the 7 BIP39-wordlist locales, a long-compound-word script (stress-tests layout), and at least one AI-drafted/lower-review-confidence locale. This is separate from the existing English-only invocation and is **not** wired into `flutter-ci.yml` or run automatically — full per-locale runs multiply an already multi-hour suite by the number of locales tested, so this is a manual/periodic developer tool, not a per-PR gate.
- Existing English-only acceptance runs (the ones developers already run after every change, per `CLAUDE.md`) are unaffected: the default locale stays English when no locale is specified.

## Capabilities

### New Capabilities

(none — this extends the existing acceptance-test-suite capability rather than introducing a new one)

### Modified Capabilities

- `acceptance-test-suite`: adds a "Locale Is Selectable Per Run" requirement (mirroring the existing "Target Device Is Selectable Per Run" requirement) — a run can be pointed at a specific supported locale, defaults to English when unspecified, drives onboarding's language screen to reach that locale, and types/asserts test-authored fixture strings in that locale rather than hardcoded English.

## Impact

- `integration_test/acceptance/acceptance_test.dart` and `integration_test/acceptance/support/acceptance_harness.dart`: onboarding entry helper(s) gain locale selection; literal English fixture strings used as typed-in test data are replaced with locale-aware lookups.
- New `integration_test/acceptance/support/locale_fixtures.dart` (or similar): a small table of test-fixture strings per curated locale.
- `tool/run_acceptance_tests.sh` (or a new sibling script): gains a locale argument/flag and a way to run the curated locale set in one invocation.
- No production `lib/` code changes — this is test-only.
