## 1. Flutter l10n plumbing

- [ ] 1.1 Add `flutter_localizations` and `intl`; set `flutter: generate: true` in `pubspec.yaml`
- [ ] 1.2 Add `l10n.yaml` and `lib/l10n/app_en.arb` (template with `@@locale: en`); set `untranslated-messages-file` for CI
- [ ] 1.3 Wire `localizationsDelegates` (`AppLocalizations`, `GlobalMaterialLocalizations`, `GlobalWidgetsLocalizations`, `GlobalCupertinoLocalizations`), `supportedLocales` (start with `en`), and a `localeListResolutionCallback` implementing design Decision 3b (language-code match; `zh_Hant` / `zh_TW` / `zh_HK` must not resolve to Simplified `zh`)
- [ ] 1.4 Add language preference storage on `SettingsRepository` (SharedPreferences, not secure storage) with follow-device sentinel vs pinned locale; default follow-device → fallback `en`; if a stored pin is no longer supported, drop it

## 2. Extract English UI and ViewModel copy

- [ ] 2.1 Extract onboarding, restore, migration, and keystore export strings into `app_en.arb` and replace literals (if `household-language-voice` is still open, use that term map for English ARB wording)
- [ ] 2.2 Extract home, register, summary, and app shell / navigation strings, including tooltips, semantics labels, and register counterpart strings (`Opening balance`, `Transfer: {name}`)
- [ ] 2.3 Extract record transaction, transfer, and settle-pending-transfer strings
- [ ] 2.4 Extract account management and category management strings (including dialogs)
- [ ] 2.5 Extract currency selection / currency backfill strings
- [ ] 2.6 Add ARB keys for system default group, starter category, starter financial account, Opening Balance Equity, and Transfers in transit display labels used by the unchanged-name localization rule
- [ ] 2.7 Add ARB keys for the closed list of system-generated journal descriptions and map them at register display time
- [ ] 2.8 Move `ExchangeRateProvider.displayName` (and any similar enum labels) to ARB keys
- [ ] 2.9 Map import skip-reason codes to ARB keys on the OFX/CSV preview UI

## 3. Localized errors

- [ ] 3.1 Introduce stable error codes (or sealed error types) on domain exceptions used for user-visible failures, including parser skip-reason codes
- [ ] 3.2 Refactor `LedgerRepository` (and OFX/CSV parsers) throw/skip sites to codes + structured params (no user-facing English prose). Keep `toString()` diagnostic, not display.
- [ ] 3.3 Add `localizeError` (or equivalent) mapper from code → `AppLocalizations`, plus a generic fallback for unknown codes
- [ ] 3.4 Update ViewModels so the View supplies `AppLocalizations` or the VM exposes codes the View maps; replace hardcoded validation `_errorMessage` strings with l10n keys/codes
- [ ] 3.5 Add English ARB entries for every user-visible error, validation message, and skip reason
- [ ] 3.6 Update unit tests that currently match English exception prose to assert on error codes/types instead

## 4. Fonts and recovery phrase

- [ ] 4.1 Wire a theme + font-asset registry for Latin now; document how locale packs register Indic/CJK/Arabic/Ol Chiki files (do not bundle every script in this change). Record font licenses for any bundled files.
- [ ] 4.2 Verify recovery phrase / BIP39 flows remain English wordlist regardless of UI locale

## 5. AI translation workflow document

- [ ] 5.1 Write a glossary of Smara's accounting/ledger terms (e.g. "account", "ledger", "transfer", "archive", "opening balance", "reversal", "posting", "journal entry", "category", "settle") with a short English gloss for each, for AI translators to translate consistently across every locale pack. If household-language-voice has a term map, include those user-facing glosses too.
- [ ] 5.2 Document the AI-draft workflow itself: prompt structure, "preserve keys/placeholders/`@` metadata (including ICU plural/select skeletons) byte-for-byte" rule, and where to place the glossary and workflow notes (e.g. `lib/l10n/TRANSLATION_GLOSSARY.md` or similar) so every locale-pack change can reference one canonical source

## 6. Language settings UI

- [ ] 6.1 Add a language picker on Settings listing follow-device plus currently supported locales (English only until packs merge), labeling each locale with endonym + secondary Latin/English name
- [ ] 6.2 Changing language updates the running app without reinstall (locale change triggers an app-level rebuild, including `TextDirection`)
- [ ] 6.3 Picker widget supports filter/search by endonym or English name; hide the search field until more than one locale is registered
- [ ] 6.4 Sort pinned "Use device language" first, then English, then other locales by English/Latin name

## 7. Tests

- [ ] 7.1 Pin widget/integration tests to `Locale('en')` (or equivalent) so assertions remain stable
- [ ] 7.2 Unit-test error-code → English message mapping for representative repository failures, plus unknown-code fallback
- [ ] 7.3 Widget-test language preference persistence, follow-device vs pinned English, and fallback to English for unsupported device locales
- [ ] 7.4 Run analyzer and relevant unit/widget suites; fix breakages from string extraction
- [ ] 7.5 Widget-test that changing the language in the picker updates already-visible UI text (and direction, when an RTL locale is registered) without an app restart
- [ ] 7.6 Unit-test that a ViewModel-authored validation message (not repository-thrown) resolves through `AppLocalizations`, not a hardcoded string
- [ ] 7.7 Regression-test that a ledger amount renders identically (numeric-dot, ISO 4217 code) with a non-English locale active, including digit order under an RTL locale
- [ ] 7.8 Unit-test locale resolution: `hi_IN` → `hi` when Hindi is supported; `zh_TW` / `zh_Hant` → `en` while only Simplified `zh` is supported; dropped pin → follow-device/English; legacy `in` → `id` when Indonesian is supported
- [ ] 7.9 Widget-test that an unchanged seeded group name localizes and a renamed one does not
- [ ] 7.10 Widget-test that a user-typed journal description is unchanged when the UI locale changes

## 8. Docs

- [ ] 8.1 Update `docs/user-guide.md` Settings section per the user-guide delta (language picker, what is not translated, BIP39, amounts, screen-reader limitation)
- [ ] 8.2 Update `Specs/architecture/smara-architecture.md` so it no longer says localization is deferred
