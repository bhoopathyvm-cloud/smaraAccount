## Context

Depends on `i18n-foundation`. Locales: Hindi (`hi`), Urdu (`ur`), Punjabi (`pa`), Nepali (`ne`), Sanskrit (`sa`), Dogri (`doi`), Kashmiri (`ks`), Maithili (`mai`).

## Goals / Non-Goals

**Goals:** AI-draft ARB parity; register locales; RTL for Urdu; fonts for Devanagari, Gurmukhi, and Perso-Arabic scripts used here.

**Non-Goals:** Human QA; separate Shahmukhi vs Gurmukhi Punjabi variants beyond a single `pa` choice for v1; BIP39 localization.

## Decisions

### 1. Punjabi script for v1
Use Gurmukhi (`pa`) as the primary AI-draft target unless foundation fonts already favor another; document the choice in the ARB `@@locale`.

### 2. Urdu is RTL
Ensure `Directionality` flips when `ur` is active (Flutter locale + Material delegates).

### 3. Kashmiri / Dogri availability
Ship AI ARBs even if Material widget localizations are incomplete; app strings still resolve from ARBs.

## Risks / Trade-offs

- [Limited Flutter Material translations for some locales] → App chrome still localized via ARB; system widgets may show English.
- [Script ambiguity for Punjabi/Sindhi-adjacent users] → Document v1 choice; revisit with regional variants later.

## Migration Plan

Additive after foundation.

## Open Questions

- Exact Kashmiri script orthography for AI drafts (Perso-Arabic vs Devanagari) — default Perso-Arabic if font available, else document fallback.
