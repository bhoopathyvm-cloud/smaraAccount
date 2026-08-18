## Why

Western Indian scheduled languages — Marathi, Gujarati, Konkani, and Sindhi — complete another regional slice of India's 22 scheduled languages. v1 translations are AI-generated from the English ARB.

## What Changes

- Add AI-translated ARBs for `mr`, `gu`, `kok`, `sd`.
- Register those locales in `supportedLocales` and the language picker with verified endonyms.
- Fonts: Devanagari (Marathi/Konkani), Gujarati, and **Arabic-script Sindhi**. Arabic-script Sindhi SHALL use RTL.
- Depends on `i18n-foundation`.

## Capabilities

### New Capabilities
- `locales-indian-west`: Marathi, Gujarati, Konkani, and Sindhi as supported AI-draft UI locales.

### Modified Capabilities
- `app-localization`: register these four locales; RTL for `sd`.

## Impact

- Four new ARB files; locale registration; font coverage for Arabic-script Sindhi; RTL for Sindhi.
- AI-draft quality; English fallback for gaps.
- Devanagari Sindhi is out of v1.
