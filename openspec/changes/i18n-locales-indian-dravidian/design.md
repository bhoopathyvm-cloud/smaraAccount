## Context

Depends on `i18n-foundation`. Adds Tamil (`ta`), Telugu (`te`), Malayalam (`ml`), Kannada (`kn`) as AI-draft locales.

## Goals / Non-Goals

**Goals:** Full ARB parity with English template for these four locales; register in picker; Indic font rendering.

**Non-Goals:** Human linguistic QA; Crowdin; changing English keys; BIP39 non-English wordlists.

## Decisions

### 1. AI batch translate from `app_en.arb`
Preserve all keys, placeholders, and `@` metadata. Use the shared accounting glossary from foundation notes when prompting.

### 2. Locale codes
BCP-47: `ta`, `te`, `ml`, `kn` (no regional variants in v1).

### 3. Fonts
Noto Sans Tamil / Telugu / Malayalam / Kannada (or a single multi-script Noto bundle already chosen in foundation).

## Risks / Trade-offs

- [AI mistranslates accounting terms] → English fallback + glossary; polish later.
- [Complex script shaping] → Use fonts with proper GSUB/GPOS; smoke-test on device/emulator.

## Migration Plan

Merge after foundation. Adding locales is additive; remove by deleting ARBs and unregistering.

## Open Questions

None blocking; glossary terms can be refined while applying.
