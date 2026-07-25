## 1. Flutter l10n plumbing

- [ ] 1.1 Add `flutter_localizations` and `intl`; set `flutter: generate: true` in `pubspec.yaml`
- [ ] 1.2 Add `l10n.yaml` and `lib/l10n/app_en.arb` (template with `@@locale: en`)
- [ ] 1.3 Wire `localizationsDelegates`, `supportedLocales` (start with `en`), and locale resolution on `MaterialApp.router`
- [ ] 1.4 Add language preference storage + apply preferred/`Locale` on app start; default device → fallback `en`

## 2. Extract English UI and ViewModel copy

- [ ] 2.1 Extract onboarding, restore, migration, and keystore export strings into `app_en.arb` and replace literals
- [ ] 2.2 Extract home, register, summary, and app shell / navigation strings
- [ ] 2.3 Extract record transaction, transfer, and settle-pending-transfer strings
- [ ] 2.4 Extract account management and category management strings (including dialogs)
- [ ] 2.5 Extract currency selection / currency backfill strings
- [ ] 2.6 Add ARB keys for system default group and category display labels used by the unchanged-name localization rule

## 3. Localized errors

- [ ] 3.1 Introduce stable error codes (or sealed error types) on domain exceptions used for user-visible failures
- [ ] 3.2 Refactor `LedgerRepository` throw sites to codes + structured params (no user-facing English prose)
- [ ] 3.3 Add `localizeError` (or equivalent) mapper from code → `AppLocalizations`
- [ ] 3.4 Update ViewModels to map repository errors via the mapper; replace hardcoded validation `_errorMessage` strings with l10n keys
- [ ] 3.5 Add English ARB entries for every user-visible error and validation message

## 4. Fonts and recovery phrase

- [ ] 4.1 Choose and wire a font strategy that will render Latin now and Indic/CJK/Arabic when locale packs land (document asset paths)
- [ ] 4.2 Verify recovery phrase / BIP39 flows remain English wordlist regardless of UI locale

## 5. AI translation workflow document

- [ ] 5.1 Write a glossary of Smara's accounting/ledger terms (e.g. "account", "ledger", "transfer", "archive", "opening balance", "reversal", "posting", "journal entry", "category", "settle") with a short English gloss for each, for AI translators to translate consistently across every locale pack
- [ ] 5.2 Document the AI-draft workflow itself: prompt structure, "preserve keys/placeholders/`@` metadata byte-for-byte" rule, and where to place the glossary and workflow notes (e.g. `lib/l10n/TRANSLATION_GLOSSARY.md` or similar) so every locale-pack change can reference one canonical source

## 6. Language settings UI

- [ ] 6.1 Add a language picker surface listing currently supported locales (English only until packs merge), labeling each with its own native-script name (endonym), not only an English name
- [ ] 6.2 Changing language updates the running app without reinstall (locale change triggers an app-level rebuild, e.g. via a `ChangeNotifier`/`InheritedWidget` the root `MaterialApp.router` listens to)

## 7. Tests

- [ ] 7.1 Pin widget/integration tests to `Locale('en')` (or equivalent) so assertions remain stable
- [ ] 7.2 Unit-test error-code → English message mapping for representative repository failures
- [ ] 7.3 Widget-test language preference persistence and fallback to English for unsupported device locales
- [ ] 7.4 Run analyzer and relevant unit/widget suites; fix breakages from string extraction
- [ ] 7.5 Widget-test that changing the language in the picker updates already-visible UI text without an app restart
- [ ] 7.6 Unit-test that a ViewModel-authored validation message (not repository-thrown) resolves through `AppLocalizations`, not a hardcoded string
- [ ] 7.7 Regression-test that a ledger amount renders identically (numeric-dot, ISO 4217 code) with a non-English locale active
