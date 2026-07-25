## Why

After `i18n-foundation`, Smara still only ships English. India's Dravidian scheduled languages — Tamil, Telugu, Malayalam, and Kannada — are a high-priority first locale pack for the product's Indian user base. v1 translations are AI-generated from the English ARB and may be polished in later versions.

## What Changes

- Add AI-translated ARB files: `app_ta.arb`, `app_te.arb`, `app_ml.arb`, `app_kn.arb` covering every key in the English template (including error strings).
- Register `ta`, `te`, `ml`, `kn` in `supportedLocales` and the language picker.
- Ensure fonts render Tamil, Telugu, Malayalam, and Kannada scripts without tofu.
- Depends on `i18n-foundation` (English template + error-code mapping must already exist).

## Capabilities

### New Capabilities
- `locales-indian-dravidian`: Tamil, Telugu, Malayalam, and Kannada as supported AI-draft UI locales with full ARB coverage and script font support.

### Modified Capabilities
- (none in archived `openspec/specs/` yet; packs extend runtime localization introduced by `i18n-foundation`)

## Impact

- New files under `lib/l10n/`; updates to `supportedLocales` / language picker list.
- Font assets if not already bundled by foundation.
- No repository or schema changes.
- Translation quality is AI-draft; English fallback remains for any missing key.
