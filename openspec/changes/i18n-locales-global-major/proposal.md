## Why

Additional major world languages — Arabic, Russian, Indonesian, Turkish, Vietnamese, Thai, Malay, Ukrainian, Polish, and Dutch — round out worldwide coverage beyond the Indian scheduled set, European pack, and East Asian pack. v1 translations are AI-generated from the English ARB.

## What Changes

- Add AI-translated ARBs for `ar`, `ru`, `id`, `tr`, `vi`, `th`, `ms`, `uk`, `pl`, `nl`.
- Register those locales in `supportedLocales` and the language picker.
- Enable RTL for Arabic; ensure fonts cover Cyrillic, Arabic, Thai, and Vietnamese diacritics.
- Depends on `i18n-foundation`.

## Capabilities

### New Capabilities
- `locales-global-major`: Arabic, Russian, Indonesian, Turkish, Vietnamese, Thai, Malay, Ukrainian, Polish, and Dutch as supported AI-draft UI locales.

### Modified Capabilities
- (none archived yet)

## Impact

- Ten new ARB files; RTL for Arabic; additional font coverage.
- AI-draft quality; English fallback for gaps.
- Further world languages can be added as future packs without changing foundation architecture.
