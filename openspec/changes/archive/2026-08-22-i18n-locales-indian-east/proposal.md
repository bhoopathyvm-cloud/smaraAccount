## Why

Eastern and northeastern Indian scheduled languages — Bengali, Assamese, Odia, Manipuri (Meitei), Bodo, and Santali — finish the 22 scheduled-language set alongside the other Indian locale packs. v1 translations are AI-generated from the English ARB.

## What Changes

- Add AI-translated ARBs for `bn`, `as`, `or`, `mni`, `brx`, `sat`.
- Register those locales in `supportedLocales` and the language picker with verified endonyms. Odia uses BCP-47 `or` (`Locale.fromSubtags(languageCode: 'or')`).
- Fonts: Bengali–Assamese, Odia, Meitei Mayek (Manipuri), Devanagari (Bodo), Ol Chiki (Santali). If a rare-script font cannot ship, document the gap; strings still ship.
- Depends on `i18n-foundation`. The "all 22 scheduled languages" picker check is integration-level and applies only when the other three Indian packs are also present.

## Capabilities

### New Capabilities
- `locales-indian-east`: Bengali, Assamese, Odia, Manipuri, Bodo, and Santali as supported AI-draft UI locales.

### Modified Capabilities
- `app-localization`: register these six locales and their endonyms.

## Impact

- Six new ARB files; locale registration; possibly larger font asset set for Ol Chiki / Meitei Mayek.
- AI-draft quality; English fallback for gaps.
- Some locales have limited Flutter Material translation coverage — app strings still come from ARBs; Material widgets may partially fall back.
