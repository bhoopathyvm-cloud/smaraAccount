## Why

Smara Accounting ships English-only UI and English exception messages embedded in the repository layer. Architecture deferred localization until a second language was a real requirement; that requirement is now explicit: support India's 22 scheduled languages plus major world languages, with copy easy to edit without code changes. This foundation change makes the app localization-ready with English as the source of truth and an AI-first translation workflow for follow-on locale packs.

## What Changes

- Add Flutter gen-l10n (`flutter_localizations`, `intl`, `l10n.yaml`, `lib/l10n/app_en.arb`) and wire delegates into `MaterialApp.router`.
- Extract every user-facing UI and ViewModel string into English ARB keys.
- **BREAKING (internal API):** replace user-facing English in domain/repository exceptions with stable error codes (or typed exceptions); map codes to `AppLocalizations` at the UI boundary.
- Persist an in-app language preference (device locale by default, with manual override) and rebuild the UI when it changes.
- Establish fonts capable of rendering Indic and CJK scripts once locale packs land (bundled Noto or equivalent strategy documented in design).
- Define the AI-translated v1 workflow: English ARB is canonical; locale packs may ship AI drafts with English fallback for missing keys; human polish is deferred.
- Keep BIP39 recovery-phrase wordlists English regardless of UI locale.
- Document the dependency order for follow-on changes: Indian and world locale packs apply only after this foundation.

## Capabilities

### New Capabilities
- `app-localization`: Flutter ARB-based localization, English template completeness, language preference, delegates/fallback, AI-draft translation policy for v1, and font strategy hooks for follow-on locale packs.
- `localized-errors`: Stable, language-agnostic error codes from domain/repository layers; UI maps codes (with placeholders) to localized strings.

### Modified Capabilities
- (none in `openspec/specs/` yet for UI chrome; localization is net-new. Locale packs modify `app-localization` by adding supported locales.)

## Impact

- Touches nearly every `lib/ui/**` view and ViewModel that currently hardcodes English.
- Refactors `LedgerRepository` and related exception throw sites (~40+) plus VM `errorMessage` handling.
- Adds dependencies: `flutter_localizations`, `intl`; enables `flutter: generate: true`.
- Widget/integration tests that `find.text('…')` English must pin locale to `en` or assert via keys/l10n.
- Seeded ledger names (groups/categories) policy: store English (or stable keys); display translation only for unchanged system defaults — detailed in design.
- Blocks no ledger schema work, but should land after or alongside settling `multi-currency-support` UI churn to avoid merge pain on the same screens.
- Follow-on changes (language packs) depend on this change shipping first.
