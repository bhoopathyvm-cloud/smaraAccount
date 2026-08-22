## Why

Complete coverage of India's northern and related scheduled languages that use Devanagari, Perso-Arabic, or related scripts: Hindi, Urdu, Punjabi, Nepali, Sanskrit, Dogri, Kashmiri, and Maithili. v1 uses AI-translated ARBs from the English template.

## What Changes

- Add AI-translated ARBs for `hi`, `ur`, `pa`, `ne`, `sa`, `doi`, `ks`, `mai`.
- Register those locales in `supportedLocales` and the language picker with verified endonyms.
- Enable RTL for Urdu **and** Kashmiri (Perso-Arabic). Punjabi v1 is Gurmukhi (LTR).
- Depends on `i18n-foundation`.

## Capabilities

### New Capabilities
- `locales-indian-north`: Hindi, Urdu, Punjabi, Nepali, Sanskrit, Dogri, Kashmiri, and Maithili as supported AI-draft UI locales.

### Modified Capabilities
- `app-localization`: register these eight locales, native-name table, and RTL for `ur` and `ks`.

## Impact

- Eight new ARB files; locale registration; RTL verification for Urdu and Kashmiri.
- Font coverage for Devanagari / Gurmukhi / Perso-Arabic (Urdu and Kashmiri).
- AI-draft quality; English fallback for gaps.
- Flutter Material widgets may remain English for rarer locales (`doi`, `ks`, `mai`, `sa`); app chrome still comes from ARBs.
