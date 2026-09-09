## 1. Navigation policy

- [x] 1.1 Add `language = '/onboarding/language'` to `AppNavPaths` and include it in the `onboarding` set (`lib/domain/navigation/app_navigation_policy.dart`)
- [x] 1.2 In `AppNavigationPolicy.resolve`, when `identity == null`, return `AppNavPaths.language` unless `matchedLocation` is `language` or `currency` (currency stays reachable pre-identity)
- [x] 1.3 Unit tests in `test/domain/navigation/` (or the existing policy test file): no identity + arbitrary location → `language`; no identity + on `language` → stay; no identity + on `currency` → stay; identity present → unchanged behaviour

## 2. Language screen (mandatory selection)

- [x] 2.1 Add English ARB keys for the screen (title, subtitle, continue button, "Same as device" label) to `lib/l10n/app_en.arb`; run `tool/l10n/sync_arb_keys.py` and `flutter gen-l10n`
- [x] 2.2 Add `LanguageSelectionView` under `lib/ui/features/onboarding/views/` — a scrollable list of supported locales labelled with `locale_endonyms.dart`, plus a first "Same as device" row writing `kSystemLocalePreference`; pre-*highlight* (not silently accept) `localeController.overrideLocale ?? resolveSupportedLocale(deviceLocale)`
- [x] 2.3 Track "has the user tapped a row yet" in local widget state; Continue is disabled until true. Tapping any row (including the pre-highlighted one or "Same as device") calls `context.read<LocaleController>().setPreference(tag)` and sets that state true. Continue calls `context.go(AppNavPaths.currency)`
- [x] 2.4 Register the `GoRoute` for `AppNavPaths.language` in `lib/ui/app_router.dart`, styled consistently with the other onboarding routes

## 3. Currency default follows language

- [x] 3.1 Add `defaultCurrencyForLocale(String languageCode)` (e.g. under `lib/l10n/`) implementing the language→currency table from design.md Decision 7, returning `'USD'` for any code not in the table
- [x] 3.2 In `CurrencySelectionView`, seed `_controller` from `defaultCurrencyForLocale(Localizations.localeOf(context).languageCode)` instead of the hardcoded `_commonCurrencies.first`
- [x] 3.3 Unit test `defaultCurrencyForLocale` against the full table plus an unknown-code fallback case

## 4. Recovery phrase follows language where a BIP39 wordlist exists

- [x] 4.1 Add a locale→`Language` lookup (`bip39LanguageForLocale(String languageCode)`) covering `fr`, `it`, `es`, `pt`, `ja`, `ko`, `zh`, defaulting to `Language.english` for every other code, in `lib/domain/crypto/recovery_phrase_language.dart` (next to `recovery_phrase.dart`)
- [x] 4.2 Thread the active UI language into generation: `RecoveryPhrase.generate({Language language})` (+ `SigningKeyService.generateNewIdentity` / `IdentityRepository.generateFirstIdentity` / `RecoveryPhraseSetupViewModel.commitIdentity`), the currency screen passing `bip39LanguageForLocale(...)`. `RecoveryPhrase.fromWords` now auto-detects the wordlist (English-first) so restore/resume stay language-agnostic and existing English phrases keep their exact original path — a safer design than hardcoding one locale into the restore path (which cannot know the phrase's language up front)
- [x] 4.3 Add English ARB keys for the English-fallback disclosure notice; show it as a dialog once, on the currency screen before `commitIdentity` generates the phrase, when `recoveryPhraseUsesEnglishFallback(languageCode)` is true
- [x] 4.4 Unit tests for `bip39LanguageForLocale` (all 7 mapped codes plus unmapped fallbacks) and `recoveryPhraseUsesEnglishFallback` (English + 7 wordlist locales → false; other non-English → true)

## 5. Tests

- [x] 5.1 Widget test for `LanguageSelectionView`: renders endonyms plus "Device language", pre-highlights the resolved locale without enabling Continue, tapping a row (including the pre-highlighted one) enables Continue and rebuilds visible copy in that language
- [x] 5.2 Update onboarding widget/integration tests that assumed currency is the first screen to advance past the language screen first (tap a row before Continue) — shared `advancePastLanguageScreen` harness helper + `integration_test/app_test.dart`
- [~] 5.3 Acceptance coverage: `integration_test/acceptance/acceptance_test.dart` steps through the language screen choosing Tamil (a non-English, non-BIP39 language), asserts the currency screen renders in Tamil and its pre-fill is INR. The English-fallback notice and the French-wordlist phrase are covered by unit/widget tests (`recovery_phrase_language_test.dart`, `recovery_phrase_test.dart`) rather than a second full end-to-end acceptance pass through the recovery-phrase screen
- [x] 5.4 Update acceptance files whose `setUp` drives first-launch onboarding via the shared `advancePastLanguageScreen` harness helper (tap a row, then Continue)

## 6. Docs

- [x] 6.1 Document the language screen, the currency default behavior, and the BIP39 English-fallback notice in `docs/user-guide.md` under onboarding

## 7. Verify

- [x] 7.1 `flutter analyze` clean; `flutter test` green (841 unit/widget tests)
- [~] 7.2 Automated equivalent run on Linux desktop (this environment): fresh install opens on the language screen; the acceptance Tamil test taps to enable Continue, then the currency screen renders in Tamil pre-filled INR. Full manual device pass (Settings reflection, relaunch persistence) not run on a physical device here
- [ ] 7.3 Manual: choosing French shows no English-fallback notice and the recovery phrase is in French BIP39 words (French wordlist generation is covered by unit tests; not manually device-verified)
- [ ] 7.4 Manual: choosing Arabic/Urdu flips the onboarding screens to RTL without layout breakage (not verified on a physical device in this environment)
- [ ] 7.5 `tool/run_acceptance_tests.sh -d macos` green (macOS not available in this Linux environment; the acceptance suite was run on Linux desktop instead)
