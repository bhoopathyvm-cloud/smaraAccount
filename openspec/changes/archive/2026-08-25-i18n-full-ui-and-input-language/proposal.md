## Why

Locale packs already translate navigation labels and most buttons, but a Tamil (or other) speaker still types into English field values, English placeholders, English validation/parser messages, and English OS/IME chrome. The shipped i18n work covered ARB labels; it did not cover input language, editor contents for seeded names, leftover hardcoded copy, or platform overlays. Until those match the selected language, switching language feels incomplete.

## What Changes

- Treat **text entry** as part of localization: name, payee, memo, and description fields accept the selected language's script, hint the IME toward that language where the OS allows, and never force Latin-only formatters except on ISO/PIN/BIP39/ticker fields.
- Show **system default names** (Cash & Bank, starter categories, group names) in the selected language inside rename/onboarding fields as well as lists; persist the English seed when the user did not actually rename.
- Close remaining **hardcoded English** in the running app: amount-field errors, CSV/OFX skip reasons, biometric unlock copy, unlocalized ViewModel error strings, `MaterialApp` title, and date strings that ignore the UI locale.
- Localize **Material/Cupertino overlay chrome** (date picker OK/Cancel, text-selection toolbar) for locales Flutter already ships, and add an explicit fallback for app locales Flutter does not ship instead of silently mixing English chrome with translated labels.
- Keep existing non-goals: BIP39 words stay English; ledger **amounts** still follow currency conventions, not the UI locale; user-typed notes are stored as typed and are not auto-translated.

## Capabilities

### New Capabilities
- `localized-input`: Keyboard/IME hints, script-capable text fields, localized placeholders, and editor values for unchanged system-seeded names.

### Modified Capabilities
- `app-localization`: Remaining chrome that is not a typed ledger name — window title, displayed calendar dates, platform permission strings, biometric reason text, and Material/Cupertino overlay language.
- `localized-errors`: Parser skip reasons and leftover view/ViewModel validation must actually use codes + ARB (the requirement exists; the app still shows English sentences).
- `investment-research-enablement`: Packed research prompt text follows the UI locale; identifiers stay as stored.
- `user-guide`: Document that choosing a language covers labels, errors, default names in fields, and typing, and what still stays English (recovery words, amounts, user-typed notes, OS keyboard limits).

## Impact

- **Affected code**: `lib/ui/**` text fields and date formatting; `lib/ui/core/money_amount_field.dart`; `lib/l10n/` (new keys, `system_name_localizer` editor helpers, error mapper); `lib/domain/csv/csv_parser.dart` and `lib/domain/ofx/ofx_parser.dart` (skip codes); lock biometric reason; `lib/main.dart` title; `lib/domain/investment_research_prompt.dart`; iOS/macOS `Info.plist` / `InfoPlist.strings`; tests under `test/l10n/` and parser/widget tests that assert English skip sentences or field values.
- **Docs**: `docs/user-guide.md` language section (today the guide barely mentions the setting).
- **Dependencies**: none new; uses existing `flutter_localizations` + `TextField.hintLocales`.
- **Not in this change**: bundling Noto font files (already a documented i18n-foundation follow-up); translating BIP39; reformatting amounts to the UI locale; auto-translating user-authored ledger text.
