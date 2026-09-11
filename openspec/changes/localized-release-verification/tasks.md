## 1. Document the pre-release step

- [x] 1.1 Create `docs/release/checklist.md` (new — `docs/release/` exists today with only `android-upload-keystore.md`, no master checklist yet) naming the localized-acceptance step explicitly: the exact command (`tool/run_localized_acceptance_tests.sh -d macos`), that it covers the curated 9-locale set (name them), that it runs the full acceptance suite once per locale, and that it does not cover the other supported locales outside that set.
- [x] 1.2 Cross-link the new checklist from `docs/release/android-upload-keystore.md` (or wherever else a release process is currently referenced, e.g. `CLAUDE.md`) so a contributor following any one release doc finds the others.
- [x] 1.3 State the real cost plainly in the checklist doc: ~8-10 hours per locale, sequential on one machine today (~3-4 days for the full curated set), so whoever runs this can plan for it rather than being surprised mid-run.

## 2. Verify

- [x] 2.1 Confirm `tool/run_localized_acceptance_tests.sh -d macos` still works as documented (no code changes expected — this is a docs-only change) by re-reading the script, not re-running the multi-day suite as part of this change.
- [ ] 2.2 Have a second person (or a fresh read yourself, a day later) follow the new checklist doc's instructions literally, to confirm it's actually enough to run the step without needing prior context from this conversation.
