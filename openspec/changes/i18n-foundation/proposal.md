## Why

Smara Accounting ships English-only UI and English exception messages embedded in the repository layer. Architecture deferred localization until a second language was a real requirement; that requirement is now explicit: support India's 22 scheduled languages plus major world languages, with copy easy to edit without code changes. This foundation change makes the app localization-ready with English as the source of truth and an AI-first translation workflow for follow-on locale packs.

## What Changes

- Add Flutter gen-l10n (`flutter_localizations`, `intl`, `l10n.yaml`, `lib/l10n/app_en.arb`) and wire delegates into `MaterialApp.router`.
- Extract every user-facing UI and ViewModel string into English ARB keys (chrome, validation, tooltips, semantics labels, snackbars, dialogs, empty states, import skip reasons, and Settings provider labels).
- **BREAKING (internal API):** replace user-facing English in domain/repository exceptions with stable error codes (or typed exceptions); map codes to `AppLocalizations` at the UI boundary. Parser skip reasons follow the same code→l10n pattern.
- Persist an in-app language preference in `SettingsRepository` (SharedPreferences): follow the device locale by default, or pin a supported app locale. Rebuild the UI immediately when it changes, including text direction.
- Establish a font *hook* (theme + asset registry) capable of rendering Indic and CJK scripts once locale packs land; this change ships Latin-capable fonts and the registry, not every script file.
- Define the AI-translated v1 workflow: English ARB is canonical; locale packs may ship AI drafts with English fallback for missing keys; human polish is deferred.
- Keep BIP39 recovery-phrase wordlists English regardless of UI locale.
- Document the dependency order for follow-on changes: Indian and world locale packs apply only after this foundation.
- **Depends on** `household-language-voice` (or land in parallel): English ARB keys SHALL use household terms (Spent, Received, Fix) from the household term map, not legacy ledger jargon.

## Capabilities

### New Capabilities
- `app-localization`: Flutter ARB-based localization, English template completeness, language preference (follow-device vs pin), locale resolution, delegates/fallback, AI-draft translation policy for v1, font-registry hooks, picker UX, and display-time localization of unchanged system defaults.
- `localized-errors`: Stable, language-agnostic error codes from domain/repository/parser layers; UI maps codes (with placeholders) to localized strings, including an unknown-code fallback.

### Modified Capabilities
- `user-guide`: document the language setting in everyday words (same as the phone vs pick a language), what is and is not translated, that recovery words stay English, and that amounts still look like `1234.56` with a code such as USD.
- (Locale packs further modify `app-localization` by adding supported locales.)

## Impact

- Touches nearly every `lib/ui/**` view and ViewModel that currently hardcodes English.
- Refactors `LedgerRepository` and related exception throw sites (~40+) plus VM `errorMessage` handling; ViewModels receive `AppLocalizations` (or a mapper) from the View rather than importing Flutter l10n themselves as a hidden context.
- Extends `SettingsRepository` (already SharedPreferences for non-secrets) with the language preference; does **not** use secure storage.
- Adds dependencies: `flutter_localizations`, `intl`; enables `flutter: generate: true`.
- Widget/integration tests that `find.text('…')` English must pin locale to `en` or assert via keys/l10n; tests that match exception `toString()` prose must switch to error codes.
- Seeded names stay as stored in SQLite; on screen, unchanged defaults show the everyday translated label. Same for a small set of notes the app wrote itself (`Starting amount`, `Money arrived`, …) — never the internal ledger phrasing.
- Blocks no ledger schema work. Coordinate with `household-language-voice` (this change uses that household dictionary for every English ARB value) and `localized-money-formatting` (this change does *not* change how amounts look; that later change may).
- Updates `Specs/architecture/smara-architecture.md` (currently says localization is deferred).
- Follow-on changes (language packs) depend on this change shipping first.
