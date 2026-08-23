## 1. Flutter l10n plumbing

- [x] 1.1 Add `flutter_localizations` and `intl`; set `flutter: generate: true` in `pubspec.yaml`
- [x] 1.2 Add `l10n.yaml` and `lib/l10n/app_en.arb` (template with `@@locale: en`)
- [x] 1.3 Wire `localizationsDelegates`, `supportedLocales` (start with `en`), and locale resolution on `MaterialApp.router`
- [x] 1.4 Add language preference storage + apply preferred/`Locale` on app start; default device → fallback `en`

## 2. Extract English UI and ViewModel copy

- [x] 2.1 Extract onboarding, restore, migration, and keystore export strings into `app_en.arb` and replace literals
- [x] 2.2 Extract home, register, summary, and app shell / navigation strings
- [x] 2.3 Extract record transaction, transfer, and settle-pending-transfer strings
- [x] 2.4 Extract account management and category management strings (including dialogs)
- [x] 2.5 Extract currency selection / currency backfill strings
- [x] 2.6 Add ARB keys for system default group and category display labels used by the unchanged-name localization rule

## 3. Localized errors

- [x] 3.1 Introduce stable error codes (or sealed error types) on domain exceptions used for user-visible failures
- [x] 3.2 Refactor `LedgerRepository` throw sites to codes + structured params (no user-facing English prose)
- [x] 3.3 Add `localizeError` (or equivalent) mapper from code → `AppLocalizations`
- [x] 3.4 Update ViewModels to map repository errors via the mapper; replace hardcoded validation `_errorMessage` strings with l10n keys
- [x] 3.5 Add English ARB entries for every user-visible error and validation message

## 4. Fonts and recovery phrase

- [x] 4.1 Choose and wire a font strategy that will render Latin now and Indic/CJK/Arabic when locale packs land (document asset paths)
- [x] 4.2 Verify recovery phrase / BIP39 flows remain English wordlist regardless of UI locale

## 5. AI translation workflow document

- [x] 5.1 Write a glossary of Smara's accounting/ledger terms (e.g. "account", "ledger", "transfer", "archive", "opening balance", "reversal", "posting", "journal entry", "category", "settle") with a short English gloss for each, for AI translators to translate consistently across every locale pack
- [x] 5.2 Document the AI-draft workflow itself: prompt structure, "preserve keys/placeholders/`@` metadata byte-for-byte" rule, and where to place the glossary and workflow notes (e.g. `lib/l10n/TRANSLATION_GLOSSARY.md` or similar) so every locale-pack change can reference one canonical source

## 6. Language settings UI

- [x] 6.1 Add a language picker surface listing currently supported locales (English only until packs merge), labeling each with its own native-script name (endonym), not only an English name
- [x] 6.2 Changing language updates the running app without reinstall (locale change triggers an app-level rebuild, e.g. via a `ChangeNotifier`/`InheritedWidget` the root `MaterialApp.router` listens to)

## 7. Tests

- [x] 7.1 Pin widget/integration tests to `Locale('en')` (or equivalent) so assertions remain stable
- [x] 7.2 Unit-test error-code → English message mapping for representative repository failures
- [x] 7.3 Widget-test language preference persistence and fallback to English for unsupported device locales
- [x] 7.4 Run analyzer and relevant unit/widget suites; fix breakages from string extraction
- [x] 7.5 Widget-test that changing the language in the picker updates already-visible UI text without an app restart
- [x] 7.6 Unit-test that a ViewModel-authored validation message (not repository-thrown) resolves through `AppLocalizations`, not a hardcoded string
- [x] 7.7 Regression-test that a ledger amount for a given currency renders identically when a non-English **UI** locale is active (currency-native formatting stays keyed off the currency, not `Intl.defaultLocale` / the UI locale)
