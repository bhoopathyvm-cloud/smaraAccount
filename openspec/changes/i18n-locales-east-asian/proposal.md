## Why

Major East Asian languages — Japanese, Mandarin Chinese (Simplified), and Korean — are essential for worldwide coverage. v1 translations are AI-generated from the English ARB.

## What Changes

- Add AI-translated ARBs for `ja`, `zh` (Simplified), `ko`.
- Register those locales in `supportedLocales` and the language picker.
- Bundle/verify CJK-capable fonts so glyphs are not tofu.
- Depends on `i18n-foundation`.

## Capabilities

### New Capabilities
- `locales-east-asian`: Japanese, Simplified Chinese, and Korean as supported AI-draft UI locales.

### Modified Capabilities
- (none archived yet)

## Impact

- Three new ARB files; larger CJK font assets.
- Traditional Chinese (`zh_Hant`) deferred beyond v1.
- AI-draft quality; English fallback for gaps.
