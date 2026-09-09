## 1. Navigation policy

- [ ] 1.1 Add `language = '/onboarding/language'` to `AppNavPaths` and include it in the `onboarding` set (`lib/domain/navigation/app_navigation_policy.dart`)
- [ ] 1.2 In `AppNavigationPolicy.resolve`, when `identity == null`, return `AppNavPaths.language` unless `matchedLocation` is `language` or `currency` (currency stays reachable pre-identity)
- [ ] 1.3 Unit tests in `test/domain/navigation/` (or the existing policy test file): no identity + arbitrary location → `language`; no identity + on `language` → stay; no identity + on `currency` → stay; identity present → unchanged behaviour

## 2. Language screen

- [ ] 2.1 Add English ARB keys for the screen (title, subtitle, continue button) to `lib/l10n/app_en.arb`; run `tool/l10n/sync_arb_keys.py` and `flutter gen-l10n`
- [ ] 2.2 Add `LanguageSelectionView` under `lib/ui/features/onboarding/views/` — a scrollable list of supported locales labelled with `locale_endonyms.dart`, pre-selecting `localeController.overrideLocale ?? resolveSupportedLocale(deviceLocale)`, with a single Continue action; optional first row "Same as device" writing `kSystemLocalePreference` (see design Open Questions)
- [ ] 2.3 Selecting a row calls `context.read<LocaleController>().setPreference(tag)`; Continue calls `context.go(AppNavPaths.currency)`
- [ ] 2.4 Register the `GoRoute` for `AppNavPaths.language` in `lib/ui/app_router.dart`, styled consistently with the other onboarding routes

## 3. Tests

- [ ] 3.1 Widget test for `LanguageSelectionView`: renders endonyms, pre-selects the resolved locale, tapping a language rebuilds visible copy in that language, Continue navigates onward
- [ ] 3.2 Update onboarding widget tests that assumed currency is the first screen to advance past the language screen first
- [ ] 3.3 Update `integration_test/acceptance/onboarding_test.dart` to step through the language screen (choose a non-English language, assert a later onboarding screen renders in that language)
- [ ] 3.4 Update any other acceptance files whose `setUp` drives first-launch onboarding (e.g. `core_ledger`, `first_week_setup`) to pass the new screen via a shared harness helper

## 4. Docs

- [ ] 4.1 Document the language screen in `docs/user-guide.md` under onboarding (per the `user-guide` spec's "every reachable screen" requirement)

## 5. Verify

- [ ] 5.1 `flutter analyze` clean; `flutter test` green
- [ ] 5.2 Manual: fresh install with an unsupported device locale opens on the language screen in English; choosing Tamil re-renders the currency and later onboarding screens in Tamil; Settings shows Tamil already selected; relaunch stays Tamil
- [ ] 5.3 Manual: choosing Arabic/Urdu flips the onboarding screens to RTL without layout breakage
- [ ] 5.4 `tool/run_acceptance_tests.sh -d macos` green
