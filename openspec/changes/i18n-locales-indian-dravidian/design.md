## Context

Depends on `i18n-foundation`. Adds Tamil (`ta`), Telugu (`te`), Malayalam (`ml`), Kannada (`kn`) as AI-draft locales. These four plus the other Indian packs complete the Eighth Schedule set (22 languages; English is not one of them).

## Goals / Non-Goals

**Goals:** Full ARB parity with English template for these four locales; register in picker with verified endonyms; Indic font rendering; no tofu on Home and Record Transaction.

**Non-Goals:** Human linguistic QA; Crowdin; changing English keys; BIP39 non-English wordlists; regional variants (`ta_IN` vs `ta` — device `ta_IN` resolves to `ta` via foundation).

## Decisions

### 1. AI batch translate from `app_en.arb`
Preserve all keys, placeholders, and `@` metadata. Use the shared accounting glossary from `lib/l10n/TRANSLATION_GLOSSARY.md` (or the path foundation chose).

### 2. Locale codes
BCP-47: `ta`, `te`, `ml`, `kn` (no regional variants in v1). Foundation language-code matching maps `ta_IN` → `ta`, etc.

### 3. Fonts
Register Noto Sans Tamil / Telugu / Malayalam / Kannada (or a multi-script Noto bundle) in the foundation font-asset registry. Do not assume foundation already shipped those files.

### 4. Picker labels (verified)
Primary endonym, secondary English: தமிழ் — Tamil; తెలుగు — Telugu; മലയാളം — Malayalam; ಕನ್ನಡ — Kannada.

## Risks / Trade-offs

- [AI mistranslates accounting terms] → English fallback + glossary; polish later.
- [Complex script shaping / long words overflow] → Fonts with proper GSUB/GPOS; smoke-test on device/emulator including primary CTAs.

## Migration Plan

Merge after foundation. Adding locales is additive; remove by deleting ARBs and unregistering (pinned users fall back per foundation).

## Open Questions

None blocking.
