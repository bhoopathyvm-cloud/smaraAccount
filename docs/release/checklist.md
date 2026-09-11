# Release checklist

A release is ready only after the release owner completes the required
localized acceptance check below for the release candidate. This is a
manual pre-release gate on macOS, separate from the PR checks and the
localized smoke test in CI.

## Prepare

- [ ] Check out the release candidate and record its commit (`git rev-parse HEAD`),
  the release version, the operator, and the verification date in the release record.
- [ ] Use a Mac configured for this project's Flutter desktop development.
  From the repository root, run `flutter doctor -v`, resolve any macOS/Xcode
  setup problems, then run `flutter pub get` and `flutter devices`. The latter
  must list the `macos` target. The existing CI workflows pin Flutter 3.47.1.
- [ ] Use a dedicated test macOS user account with no production Smara data.
  The acceptance harness resets the app's real database, preferences, and
  signing/recovery keychain entries. Do not run this against your personal ledger.
- [ ] Reserve approximately **8–10 hours per locale**, run sequentially on
  one Mac: **72–90 hours (about 3–4 days)** for all nine. These estimates
  come from previous macOS runs; allow time for failures and reruns. Keep
  the Mac powered, awake, and available for the GUI run throughout.

## Required localized acceptance check

From the repository root, run exactly:

```sh
tool/run_localized_acceptance_tests.sh -d macos
```

Do not add a group filter: the release gate requires the **full acceptance
suite once per locale**. The wrapper calls `tool/run_acceptance_tests.sh`
for each locale in order, using a real macOS app, database, and OS keychain.
It runs manually; no GitHub Actions workflow invokes this tier.

The curated set is defined by `kCuratedAcceptanceLocales` in
[`locale_fixtures.dart`](../../integration_test/acceptance/support/locale_fixtures.dart)
and mirrored in the wrapper:

| Tag | Language |
| --- | --- |
| `ar` | Arabic |
| `ur` | Urdu |
| `hi` | Hindi |
| `ja` | Japanese |
| `zh` | Chinese |
| `ko` | Korean |
| `fr` | French |
| `de` | German |
| `as` | Assamese |

**This verifies only these nine locales on macOS.** It does not verify the
other 34 currently supported locales, or localized behavior on other platforms.

- [ ] Save the terminal output and final `Curated multi-locale summary` with
  the release record, alongside the candidate commit and environment details.
- [ ] Confirm all nine summary entries say `PASSED`, the final message says
  `All curated locales passed.`, and the command exits with status 0
  (`echo $?` immediately after it returns).
- [ ] If a locale fails, hold the release. The wrapper continues through the
  remaining locales and exits nonzero if any failed; completion alone is
  not a pass. Investigate and fix the failure, then obtain passing full-suite
  results for the release candidate. A deliberate exception must explicitly
  document the excluded locale, reason, and release owner's decision in the
  release record; never silently ignore a failed locale or describe partial
  coverage as a full pass. If the candidate changes, re-establish the gate
  for the candidate that will actually ship.

The CI localized smoke test and a filtered acceptance group do not satisfy
this gate. Coverage beyond this curated set requires a separate scope decision.

## Platform release steps

- [ ] For Android, complete the [upload keystore and signed release
  instructions](android-upload-keystore.md), including the Play Console steps.
- [ ] Follow the project's [contribution and store release
  guidance](../../CONTRIBUTING.md#store-release-human-steps) for the target
  platform. This checklist establishes the localized gate; it does not replace
  platform signing or store submission requirements.
