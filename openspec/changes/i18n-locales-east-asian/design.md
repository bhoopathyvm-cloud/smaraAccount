## Context

Depends on `i18n-foundation`. Locales: Japanese (`ja`), Simplified Chinese (`zh`), Korean (`ko`). "Mandarin Chinese" maps to the Simplified Chinese (`zh`) locale for v1.

## Goals / Non-Goals

**Goals:** AI-draft ARB parity; CJK fonts; register locales.

**Non-Goals:** Traditional Chinese; Japanese formal/honorific tuning beyond AI draft; human QA.

## Decisions

### 1. Chinese variant
`zh` = Simplified for v1. Traditional (`zh_Hant`) deferred.

### 2. Fonts
Bundle Noto Sans CJK (or JP/KR/SC subset) — watch binary size; subset if needed.

## Risks / Trade-offs

- [APK/IPA size from CJK fonts] → Subset or platform fonts where acceptable.
- [AI tone mismatches] → Polish in later versions.

## Migration Plan

Additive after foundation.

## Open Questions

- Whether to use `zh` or `zh_CN` as the ARB locale tag — prefer `zh` unless Flutter resolution requires `zh_CN`.
