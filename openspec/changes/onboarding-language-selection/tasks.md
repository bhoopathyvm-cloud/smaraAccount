## 1. Navigation policy

- [ ] 1.1 Add `language = '/onboarding/language'` to `AppNavPaths` and include it in the `onboarding` set (`lib/domain/navigation/app_navigation_policy.dart`)
- [ ] 1.2 In `AppNavigationPolicy.resolve`, when `identity == null`, return `AppNavPaths.language` unless `matchedLocation` is `language` or `currency` (currency stays reachable pre-identity)
- [ ] 1.3 Unit tests in `test/domain/navigation/` (or the existing policy test file): no identity + arbitrary location → `language`; no identity + on `language` → stay; no identity + on `currency` → stay; identity present → unchanged behaviour

## 2. Language screen (mandatory selection)

- [ ] 2.1 Add English ARB keys for the screen (title, subtitle, continue button, "Same as device" label) to `lib/l10n/app_en.arb`; run `tool/l10n/sync_arb_keys.py` and `flutter gen-l10n`
- [ ] 2.2 Add `LanguageSelectionView` under `lib/ui/features/onboarding/views/` — a scrollable list of supported locales labelled with `locale_endonyms.dart`, plus a first "Same as device" row writing `kSystemLocalePreference`; pre-*highlight* (not silently accept) `localeController.overrideLocale ?? resolveSupportedLocale(deviceLocale)`
- [ ] 2.3 Track "has the user tapped a row yet" in local widget state; Continue is disabled until true. Tapping any row (including the pre-highlighted one or "Same as device") calls `context.read<LocaleController>().setPreference(tag)` and sets that state true. Continue calls `context.go(AppNavPaths.currency)`
- [ ] 2.4 Register the `GoRoute` for `AppNavPaths.language` in `lib/ui/app_router.dart`, styled consistently with the other onboarding routes

## 3. Currency default follows language

- [ ] 3.1 Add `defaultCurrencyForLocale(String languageCode)` (e.g. under `lib/l10n/`) implementing the language→currency table from design.md Decision 7, returning `'USD'` for any code not in the table
- [ ] 3.2 In `CurrencySelectionView`, seed `_controller` from `defaultCurrencyForLocale(Localizations.localeOf(context).languageCode)` instead of the hardcoded `_commonCurrencies.first`
- [ ] 3.3 Unit test `defaultCurrencyForLocale` against the full table plus an unknown-code fallback case

## 4. Recovery phrase follows language where a BIP39 wordlist exists

- [ ] 4.1 Add a locale→`Language` lookup (e.g. `bip39LanguageForLocale(String languageCode)`) covering `fr`, `it`, `es`, `pt`, `ja`, `ko`, `zh`, defaulting to `Language.english` for every other code, co-located with or near `lib/domain/crypto/recovery_phrase.dart`
- [ ] 4.2 Replace the three hardcoded `Language.english` call sites in `recovery_phrase.dart` with `bip39LanguageForLocale(...)`, threading the active UI language code through to wherever the phrase is generated/confirmed
- [ ] 4.3 Add English ARB keys for the English-fallback disclosure notice; add a notice screen/dialog shown once, before recovery-phrase generation, when `bip39LanguageForLocale` returns `Language.english` for a non-English UI locale
- [ ] 4.4 Unit tests for `bip39LanguageForLocale` (all 7 mapped codes plus an unmapped-code fallback); widget/unit test confirming the notice shows only for non-English, non-BIP39-wordlist locales and never for English or the 7 supported ones

## 5. Tests

- [ ] 5.1 Widget test for `LanguageSelectionView`: renders endonyms plus "Same as device", pre-highlights the resolved locale without enabling Continue, tapping a row (including the pre-highlighted one) enables Continue and rebuilds visible copy in that language
- [ ] 5.2 Update onboarding widget tests that assumed currency is the first screen to advance past the language screen first (tapping a row before Continue)
- [ ] 5.3 Update `integration_test/acceptance/onboarding_test.dart` to step through the language screen (choose a non-English, non-BIP39 language; assert a later onboarding screen renders in that language, the currency screen's pre-filled value matches that language's default, and the English-fallback notice appears before the recovery phrase); add a second pass choosing a BIP39-supported language (e.g. French) and asserting no notice appears and the phrase uses French words
- [ ] 5.4 Update any other acceptance files whose `setUp` drives first-launch onboarding (e.g. `core_ledger`, `first_week_setup`) to pass the new screen via a shared harness helper (tap a row, then Continue)

## 6. Docs

- [ ] 6.1 Document the language screen, the currency default behavior, and the BIP39 English-fallback notice in `docs/user-guide.md` under onboarding (per the `user-guide` spec's "every reachable screen" requirement)

## 7. Verify

- [ ] 7.1 `flutter analyze` clean; `flutter test` green
- [ ] 7.2 Manual: fresh install with an unsupported device locale opens on the language screen in English; choosing Tamil requires a tap before Continue, then re-renders the currency screen (pre-filled INR) and later onboarding screens in Tamil; the English-fallback notice appears before the recovery phrase; Settings shows Tamil already selected; relaunch stays Tamil
- [ ] 7.3 Manual: choosing French shows no English-fallback notice and the recovery phrase is in French BIP39 words
- [ ] 7.4 Manual: choosing Arabic/Urdu flips the onboarding screens to RTL without layout breakage
- [ ] 7.5 `tool/run_acceptance_tests.sh -d macos` green
