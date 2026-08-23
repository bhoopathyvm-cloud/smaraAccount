## Context

Depends on `i18n-foundation`. Locales: Japanese (`ja`), Simplified Chinese (`zh`), Korean (`ko`). "Mandarin Chinese" maps to the Simplified Chinese (`zh`) locale for v1.

## Goals / Non-Goals

**Goals:** AI-draft ARB parity; CJK fonts; register locales.

**Non-Goals:** Traditional Chinese; Japanese formal/honorific tuning beyond AI draft; human QA.

## Decisions

### 1. Chinese variant
ARB locale tag is `zh` (not `zh_CN`). Foundation resolution maps `zh`, `zh_CN`, and `zh_Hans` → `zh`. `zh_TW`, `zh_HK`, and `zh_Hant` stay on English until a Traditional pack. Endonym: 简体中文 — Simplified Chinese (not just 中文, so Taiwan users are not told this is their language).

### 2. Fonts
Register Noto Sans CJK (or JP/KR/SC subset) in the foundation font registry — watch binary size; subset if needed; platform CJK fonts are acceptable on Android/iOS if they cover the glyphs.

### 3. Other endonyms
日本語 — Japanese; 한국어 — Korean.

## Risks / Trade-offs

- [APK/IPA size from CJK fonts] → Subset or platform fonts where acceptable.
- [AI tone mismatches] → Polish in later versions.
- [Serving Simplified to Traditional users] → Explicitly blocked by resolution rules.

## Migration Plan

Additive after foundation.

## Open Questions

None blocking. Use `zh`, not `zh_CN`, as the ARB tag (Decision 1).
