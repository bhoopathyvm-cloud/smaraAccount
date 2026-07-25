## Why

Eastern and northeastern Indian scheduled languages — Bengali, Assamese, Odia, Manipuri (Meitei), Bodo, and Santali — finish the 22 scheduled-language set alongside the other Indian locale packs. v1 translations are AI-generated from the English ARB.

## What Changes

- Add AI-translated ARBs for `bn`, `as`, `or`, `mni`, `brx`, `sat`.
- Register those locales in `supportedLocales` and the language picker.
- Ensure fonts cover Bengali–Assamese, Odia, Meitei Mayek (and/or Bengali script if used for Manipuri in v1), Devanagari (Bodo), and Ol Chiki (Santali) — document any script fallback if a font is unavailable.
- Depends on `i18n-foundation`.

## Capabilities

### New Capabilities
- `locales-indian-east`: Bengali, Assamese, Odia, Manipuri, Bodo, and Santali as supported AI-draft UI locales.

### Modified Capabilities
- (none archived yet)

## Impact

- Six new ARB files; locale registration; possibly larger font asset set for Ol Chiki / Meitei Mayek.
- AI-draft quality; English fallback for gaps.
- Some locales have limited Flutter Material translation coverage — app strings still come from ARBs; Material widgets may partially fall back.
