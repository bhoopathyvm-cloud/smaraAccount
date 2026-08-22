## Context

Depends on `i18n-foundation`. Locales: Hindi (`hi`), Urdu (`ur`), Punjabi (`pa`), Nepali (`ne`), Sanskrit (`sa`), Dogri (`doi`), Kashmiri (`ks`), Maithili (`mai`).

## Goals / Non-Goals

**Goals:** AI-draft ARB parity; register locales; RTL for Urdu and Kashmiri; fonts for Devanagari, Gurmukhi, and Perso-Arabic scripts used here.

**Non-Goals:** Human QA; separate Shahmukhi vs Gurmukhi Punjabi variants beyond a single Gurmukhi `pa` for v1; Devanagari Kashmiri variant; BIP39 localization.

## Decisions

### 1. Punjabi script for v1
Gurmukhi (`pa`). Endonym: ਪੰਜਾਬੀ — Punjabi. Shahmukhi is out of v1.

### 2. Urdu is RTL
`Directionality` flips when `ur` is active. Endonym: اردو — Urdu.

### 3. Kashmiri script and RTL
v1 uses official Perso-Arabic orthography. Endonym: کٲشُر — Kashmiri (source: Kashmiri language / Unicode Kashmiri orthography). `ks` SHALL activate RTL the same way as Urdu. If Flutter does not treat `ks` as an RTL language code, force `TextDirection.rtl` at the app root. Devanagari Kashmiri is out of v1.

### 4. Dogri / Maithili / Sanskrit / Hindi / Nepali
Devanagari, LTR. Endonyms: हिन्दी, नेपाली, संस्कृतम्, डोगरी, मैथिली.

### 5. Material coverage
Ship AI ARBs even if Material widget localizations are incomplete; app strings still resolve from ARBs; date-picker chrome may stay English.

## Risks / Trade-offs

- [Limited Flutter Material translations for some locales] → App chrome still localized via ARB; system widgets may show English.
- [Script ambiguity for Punjabi/Kashmiri users] → Document v1 choice; revisit with regional variants later.
- [Kashmiri font / vowel marks] → Use a Noto Nastaliq/Noto Naskh Arabic family that covers Kashmiri additions; smoke-test کٲشُر in the picker.

## Migration Plan

Additive after foundation.

## Open Questions

None blocking. Kashmiri script is Perso-Arabic (Decision 3).
