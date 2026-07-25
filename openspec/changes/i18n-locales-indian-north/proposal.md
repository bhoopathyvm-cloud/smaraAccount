## Why

Complete coverage of India's northern and related scheduled languages that use Devanagari, Perso-Arabic, or related scripts: Hindi, Urdu, Punjabi, Nepali, Sanskrit, Dogri, Kashmiri, and Maithili. v1 uses AI-translated ARBs from the English template.

## What Changes

- Add AI-translated ARBs for `hi`, `ur`, `pa`, `ne`, `sa`, `doi`, `ks`, `mai`.
- Register those locales in `supportedLocales` and the language picker.
- Enable correct text direction for Urdu (RTL) and ensure fonts cover Devanagari, Gurmukhi, Perso-Arabic, and related scripts used by this set.
- Depends on `i18n-foundation`.

## Capabilities

### New Capabilities
- `locales-indian-north`: Hindi, Urdu, Punjabi, Nepali, Sanskrit, Dogri, Kashmiri, and Maithili as supported AI-draft UI locales.

### Modified Capabilities
- (none archived yet)

## Impact

- Eight new ARB files; locale registration; RTL verification for Urdu.
- Font coverage for Devanagari / Gurmukhi / Arabic-script Urdu/Kashmiri as applicable.
- AI-draft quality; English fallback for gaps.
