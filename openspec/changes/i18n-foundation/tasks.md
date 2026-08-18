## 1. Flutter l10n plumbing

- [ ] 1.1 Add `flutter_localizations` and `intl`; set `flutter: generate: true` in `pubspec.yaml`
- [ ] 1.2 Add `l10n.yaml` and `lib/l10n/app_en.arb` (template with `@@locale: en`); set `untranslated-messages-file` for CI
- [ ] 1.3 Wire `localizationsDelegates` (`AppLocalizations`, `GlobalMaterialLocalizations`, `GlobalWidgetsLocalizations`, `GlobalCupertinoLocalizations`), `supportedLocales` (start with `en`), and a `localeListResolutionCallback` implementing design Decision 3b (language-code match; `zh_Hant` / `zh_TW` / `zh_HK` must not resolve to Simplified `zh`)
- [ ] 1.4 Add language preference storage on `SettingsRepository` (SharedPreferences, not secure storage) with follow-device sentinel vs pinned locale; default follow-device → fallback `en`; if a stored pin is no longer supported, drop it

## 2. Extract English UI and ViewModel copy

- [ ] 2.1 Extract onboarding, restore, migration, and keystore export strings into `app_en.arb` using the household dictionary (Spent / Received, Fix, Same as the phone, Recovery words) — never freeze Money in/out, Reverse, or journal wording as the English template
- [ ] 2.2 Extract home, list of lines, summary, and app shell / navigation strings, including tooltips, spoken labels, and counterpart strings (`Starting amount`, `Moved to {name}`)
- [ ] 2.3 Extract add spent/received, moved-money, and finish-money-in-transit strings
- [ ] 2.4 Extract account management and category management strings (including dialogs); hide-from-new-entries, not archive, in user-visible copy
- [ ] 2.5 Extract currency selection / currency backfill strings
- [ ] 2.6 Add ARB keys for unchanged default group, starter category, starter account, Starting amount, and Money in transit display labels
- [ ] 2.7 Add ARB keys for the closed list of notes the app wrote (`Starting amount`, `Money arrived`, `Moving fee` / `Amount that didn't arrive`) and map them at display time
- [ ] 2.8 Move `ExchangeRateProvider.displayName` (and any similar enum labels) to ARB keys in everyday words
- [ ] 2.9 Map import skip-reason codes to ARB keys on the OFX/CSV preview UI (household English)

## 3. Localized errors

- [ ] 3.1 Introduce stable error codes (or sealed error types) on domain exceptions used for user-visible failures, including parser skip-reason codes
- [ ] 3.2 Refactor `LedgerRepository` (and OFX/CSV parsers) throw/skip sites to codes + structured params (no user-facing English prose). Keep `toString()` diagnostic, not display.
- [ ] 3.3 Add `localizeError` (or equivalent) mapper from code → `AppLocalizations`, plus a generic fallback for unknown codes
- [ ] 3.4 Update ViewModels so the View supplies `AppLocalizations` or the VM exposes codes the View maps; replace hardcoded validation `_errorMessage` strings with l10n keys/codes
- [ ] 3.5 Add English ARB entries for every user-visible error, validation message, and skip reason
- [ ] 3.6 Update unit tests that currently match English exception prose to assert on error codes/types instead

## 4. Fonts and recovery phrase

- [ ] 4.1 Wire a theme + font-asset registry for Latin now; document how locale packs register Indic/CJK/Arabic/Ol Chiki files (do not bundle every script in this change). Record font licenses for any bundled files.
- [ ] 4.2 Verify recovery words stay the English word list regardless of the language on screen

## 5. AI translation workflow document

- [ ] 5.1 Write a household glossary for translators: Spent, Received, Add spent, Add received, Moved money, Fix, Hide from new entries, What you have minus what you owe, Money in transit, Account, Starting amount, Money arrived, Moving fee, Amount that didn't arrive, Same as the phone, Use this language, Recovery words, Something went wrong. Explicitly list words **not** to use on screen (debit, credit, journal, posting, ledger, reverse, archive, financial account, settlement). Point at `household-language-voice` as the same dictionary.
- [ ] 5.2 Document the AI-draft workflow itself: prompt structure, "preserve keys/placeholders/`@` metadata (including ICU plural/select skeletons) byte-for-byte" rule, and where to place the glossary and workflow notes (e.g. `lib/l10n/TRANSLATION_GLOSSARY.md` or similar) so every locale-pack change can reference one canonical source

## 6. Language settings UI

- [ ] 6.1 Add a language list on Settings showing Same as the phone plus currently supported languages (English only until packs merge), each with its own name plus an English name
- [ ] 6.2 Changing language updates the running app without reinstall (including left-to-right vs right-to-left)
- [ ] 6.3 The list supports filter/search by native name or English name; hide search until more than one language is registered
- [ ] 6.4 Sort "Same as the phone" first, then English, then other languages by English name

## 7. Tests

- [ ] 7.1 Pin widget/integration tests to `Locale('en')` (or equivalent) so assertions remain stable
- [ ] 7.2 Unit-test error-code → English message mapping for representative repository failures, plus unknown-code fallback
- [ ] 7.3 Widget-test language preference persistence, follow-device vs pinned English, and fallback to English for unsupported device locales
- [ ] 7.4 Run analyzer and relevant unit/widget suites; fix breakages from string extraction
- [ ] 7.5 Widget-test that changing the language in the picker updates already-visible UI text (and direction, when an RTL locale is registered) without an app restart
- [ ] 7.6 Unit-test that a ViewModel-authored validation message (not repository-thrown) resolves through `AppLocalizations`, not a hardcoded string
- [ ] 7.7 Regression-test that money still looks like `1234.56` with a code such as USD when a non-English language is active, including digit order under a right-to-left language
- [ ] 7.8 Unit-test language matching: `hi_IN` → Hindi when Hindi is supported; `zh_TW` / `zh_Hant` → English while only Simplified `zh` is supported; dropped choice → same-as-the-phone/English; legacy `in` → `id` when Indonesian is supported
- [ ] 7.9 Widget-test that an unchanged default group name shows the household translation and a renamed one does not
- [ ] 7.10 Widget-test that a note the user typed is unchanged when the app language changes
- [ ] 7.11 Widget-test English ARB / on-screen copy uses Spent, Received, Fix, Moved money — not Money in/out, Reverse, or Transfer:

## 8. Docs

- [ ] 8.1 Update `docs/user-guide.md` Settings in everyday words (same as the phone vs pick a language, what is not translated, recovery words, how money looks, spoken screen reader)
- [ ] 8.2 Update `Specs/architecture/smara-architecture.md` so it no longer says localization is deferred
