## Why

Major European languages requested for Smara — German, French, Spanish, Italian, Portuguese, Hungarian, and Romanian — broaden reach beyond India. v1 translations are AI-generated from the English ARB.

## What Changes

- Add AI-translated ARBs for `de`, `fr`, `es`, `it`, `pt`, `hu`, `ro`.
- Register those locales in `supportedLocales` and the language picker with native names.
- Spot-check layout for long German strings on primary actions.
- Single `pt` locale: device `pt_BR` / `pt_PT` resolve to `pt` via foundation language-code matching.
- Depends on `i18n-foundation`.

## Capabilities

### New Capabilities
- `locales-european`: German, French, Spanish, Italian, Portuguese, Hungarian, and Romanian as supported AI-draft UI locales.

### Modified Capabilities
- `app-localization`: register these seven locales.

## Impact

- Seven new ARB files; locale registration.
- Latin-script fonts already covered by foundation.
- Single `pt` locale for v1 (not separate `pt_BR` / `pt_PT`).
- AI-draft quality; English fallback for gaps.
