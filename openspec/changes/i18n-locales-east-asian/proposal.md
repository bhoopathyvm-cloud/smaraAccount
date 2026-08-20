## Why

Major East Asian languages — Japanese, Mandarin Chinese (Simplified), and Korean — are essential for worldwide coverage. v1 translations are AI-generated from the English ARB.

## What Changes

- Add AI-translated ARBs for `ja`, `zh` (Simplified), `ko`.
- Register those locales in `supportedLocales` and the language picker. Chinese v1 is Simplified `zh`; device `zh_CN` / `zh_Hans` resolve to `zh`. Device `zh_TW` / `zh_HK` / `zh_Hant` MUST remain English until a Traditional pack exists (foundation Decision 3b).
- Bundle/verify CJK-capable fonts so glyphs are not tofu.
- Depends on `i18n-foundation`.

## Capabilities

### New Capabilities
- `locales-east-asian`: Japanese, Simplified Chinese, and Korean as supported AI-draft UI locales.

### Modified Capabilities
- `app-localization`: register `ja`, `zh`, `ko`.

## Impact

- Three new ARB files; larger CJK font assets (watch binary size; subset or use platform fonts where acceptable).
- Traditional Chinese (`zh_Hant`) deferred beyond v1 — do not treat Taiwan/Hong Kong devices as Simplified.
- AI-draft quality; English fallback for gaps.
