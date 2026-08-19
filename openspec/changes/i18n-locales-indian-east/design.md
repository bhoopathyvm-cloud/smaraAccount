## Context

Depends on `i18n-foundation`. Locales: Bengali (`bn`), Assamese (`as`), Odia (`or`), Manipuri (`mni`), Bodo (`brx`), Santali (`sat`). Completes the 22 Indian scheduled languages with the other Indian packs + foundation English (English is not one of the 22).

## Goals / Non-Goals

**Goals:** AI-draft ARB parity; register locales; best-effort fonts for Bengali–Assamese, Odia, Meitei Mayek, Devanagari (Bodo), Ol Chiki (Santali).

**Non-Goals:** Perfect font coverage if an open font is unavailable — document English/tofu mitigation; human QA.

## Decisions

### 1. Manipuri script
Meitei Mayek when a font is available (preferred). Endonym: ꯃꯩꯇꯩꯂꯣꯟ — Manipuri (Meiteilon). Fallback: Bengali-script মৈতৈলোন্ only if Meitei Mayek fonts cannot ship; document that fallback in the apply notes.

### 2. Santali
Ol Chiki. Endonym: ᱥᱟᱱᱛᱟᱲᱤ — Santali. If the font cannot ship, still add the ARB and note the font follow-up (missing glyphs, not missing keys).

### 3. Bodo
Devanagari. Endonym: बरʼ — Bodo (Boro). LTR.

### 4. Bengali, Assamese, Odia
বাংলা — Bengali; অসমীয়া — Assamese; ଓଡ଼ିଆ — Odia. Odia locale tag is ISO 639-1 `or`.

### 5. Completing the 22
Together with dravidian (4), north (8), west (4), east (6) = 22 scheduled languages. Task 3.3 is an integration check: skip or mark blocked until the other Indian packs are on the same branch; do not fail this pack's own apply if they are not merged yet.

## Risks / Trade-offs

- [Rare-script font gaps] → Ship strings; track font follow-up; English fallback still works for missing keys (not missing glyphs).
- [Flutter Material gaps] → Same as other packs.
- [Font packaging size] → Subset or lazy-register Ol Chiki + Meitei Mayek.

## Migration Plan

Additive after foundation. Prefer merging after or with other Indian packs so the picker shows a complete Indian set, but this pack is independently shippable.

## Open Questions

None blocking.
