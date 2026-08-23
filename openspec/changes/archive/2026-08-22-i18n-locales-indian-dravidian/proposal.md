## Why

After `i18n-foundation`, Smara still only ships English. India's Dravidian scheduled languages — Tamil, Telugu, Malayalam, and Kannada — are a high-priority first locale pack for the product's Indian user base. v1 translations are AI-generated from the English ARB and may be polished in later versions.

## What Changes

- Add AI-translated ARB files: `app_ta.arb`, `app_te.arb`, `app_ml.arb`, `app_kn.arb` covering every key in the English template (including error strings), preserving placeholders and `@` metadata.
- Register `ta`, `te`, `ml`, `kn` in `supportedLocales` and the language picker with verified endonyms plus English secondary labels (picker search/sort is owned by foundation).
- Register Tamil/Telugu/Malayalam/Kannada fonts in the foundation font registry so those scripts do not tofu.
- Depends on `i18n-foundation` (English template + error-code mapping + locale resolution must already exist). Device locales such as `ta_IN` resolve to `ta` via foundation language-code matching.

## Capabilities

### New Capabilities
- `locales-indian-dravidian`: Tamil, Telugu, Malayalam, and Kannada as supported AI-draft UI locales with full ARB coverage and script font support.

### Modified Capabilities
- `app-localization`: add these four locales to `supportedLocales` and the native-name table.

## Impact

- New files under `lib/l10n/`; updates to `supportedLocales` / language picker list; font assets for the four scripts if not already registered.
- No repository or schema changes.
- Translation quality is AI-draft; English fallback remains for any missing key.
- Layout: Tamil and Malayalam strings can be long — smoke-test primary buttons for overflow (same idea as German in the European pack).
