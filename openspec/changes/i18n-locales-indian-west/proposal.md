## Why

Western Indian scheduled languages — Marathi, Gujarati, Konkani, and Sindhi — complete another regional slice of India's 22 scheduled languages. v1 translations are AI-generated from the English ARB.

## What Changes

- Add AI-translated ARBs for `mr`, `gu`, `kok`, `sd`.
- Register those locales in `supportedLocales` and the language picker.
- Ensure fonts render Devanagari (Marathi/Konkani), Gujarati, and Sindhi scripts (Arabic or Devanagari presentation as chosen for v1 — document the chosen script variant in design).
- Depends on `i18n-foundation`.

## Capabilities

### New Capabilities
- `locales-indian-west`: Marathi, Gujarati, Konkani, and Sindhi as supported AI-draft UI locales.

### Modified Capabilities
- (none archived yet)

## Impact

- Four new ARB files; locale registration; font coverage for the chosen Sindhi script variant.
- AI-draft quality; English fallback for gaps.
