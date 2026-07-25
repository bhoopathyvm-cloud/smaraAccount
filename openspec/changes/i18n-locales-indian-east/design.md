## Context

Depends on `i18n-foundation`. Locales: Bengali (`bn`), Assamese (`as`), Odia (`or`), Manipuri (`mni`), Bodo (`brx`), Santali (`sat`). Completes the 22 Indian scheduled languages with the other Indian packs + foundation English.

## Goals / Non-Goals

**Goals:** AI-draft ARB parity; register locales; best-effort fonts for Bengali–Assamese, Odia, Meitei Mayek, Devanagari (Bodo), Ol Chiki (Santali).

**Non-Goals:** Perfect font coverage if an open font is unavailable — document English/tofu mitigation; human QA.

## Decisions

### 1. Manipuri script
Prefer Meitei Mayek when a font is available; otherwise Bengali-script Manipuri for v1 AI drafts, documented in tasks notes.

### 2. Santali
Target Ol Chiki (`sat`) when font available; if not, ship ARB anyway and note font follow-up so glyphs may fallback poorly until assets land.

### 3. Completing the 22
Together with dravidian (4), north (8), west (4), east (6) = 22 scheduled languages (English is UI default, not one of the 22).

## Risks / Trade-offs

- [Rare-script font gaps] → Ship strings; track font follow-up; English fallback still works for missing keys (not missing glyphs).
- [Flutter Material gaps] → Same as other packs.

## Migration Plan

Additive after foundation. Prefer merging after or with other Indian packs so the picker shows a complete Indian set.

## Open Questions

- Font packaging size if embedding Ol Chiki + Meitei Mayek — may lazy-load or subset.
