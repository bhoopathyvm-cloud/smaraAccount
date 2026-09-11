## 1. Document the pre-release step

- [x] 1.1 Create `docs/release/checklist.md` (new — `docs/release/` exists today with only `android-upload-keystore.md`, no master checklist yet) naming the localized-acceptance step explicitly: the exact command (`tool/run_localized_acceptance_tests.sh -d macos`), that it covers the curated 9-locale set (name them), that it runs the full acceptance suite once per locale, and that it does not cover the other supported locales outside that set.
- [x] 1.2 Cross-link the new checklist from `docs/release/android-upload-keystore.md` (or wherever else a release process is currently referenced, e.g. `CLAUDE.md`) so a contributor following any one release doc finds the others.
- [x] 1.3 State the real cost plainly in the checklist doc: ~8-10 hours per locale, sequential on one machine today (~3-4 days for the full curated set), so whoever runs this can plan for it rather than being surprised mid-run.

## 2. Verify

- [x] 2.1 Confirm `tool/run_localized_acceptance_tests.sh -d macos` still works as documented (no code changes expected — this is a docs-only change) by re-reading the script, not re-running the multi-day suite as part of this change.
- [x] 2.2 Performed the fresh-day read (2026-09-11, the doc was written 2026-09-10) as a fact-check against the actual codebase rather than recall: confirmed `integration_test/acceptance/support/locale_fixtures.dart` exists at the documented relative path, its `kCuratedAcceptanceLocales` list matches the checklist's 9-locale table exactly (same tags, same order), `tool/run_localized_acceptance_tests.sh` prints exactly the strings the checklist tells the reader to look for ("Curated multi-locale summary", "PASSED"/"FAILED", "All curated locales passed."), and `CONTRIBUTING.md#store-release-human-steps` resolves to a real section ("## Store release (human steps)"). Every concrete claim in the checklist holds against ground truth.
