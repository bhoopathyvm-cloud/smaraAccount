## Context

Depends on `i18n-foundation`. Locales: Arabic (`ar`), Russian (`ru`), Indonesian (`id`), Turkish (`tr`), Vietnamese (`vi`), Thai (`th`), Malay (`ms`), Ukrainian (`uk`), Polish (`pl`), Dutch (`nl`).

## Goals / Non-Goals

**Goals:** AI-draft ARB parity; RTL for Arabic; fonts for Arabic, Cyrillic, Thai, Vietnamese.

**Non-Goals:** Full dialect coverage (e.g. Egyptian Arabic as a separate ARB); human QA; every UN language.

## Decisions

### 1. Arabic RTL
Verify `Directionality` and mirrored icons/alignment on primary screens when `ar` is active, including after an in-app language change without restart. Endonym: العربية — Arabic. Device `ar_EG` → `ar`.

### 2. Scope of “major”
This pack is the v1 worldwide remainder; more languages can be future packs without redesign.

### 3. Malay vs Indonesian
Ship both `ms` and `id` as separate ARBs even if AI drafts are similar. Endonyms: Bahasa Melayu, Bahasa Indonesia.

### 4. Other endonyms
Русский, Türkçe, Tiếng Việt, ไทย, Українська, Polski, Nederlands.

## Risks / Trade-offs

- [RTL layout bugs] → Manual smoke on home, record transaction, settings.
- [Thai/Vietnamese rendering] → Dedicated fonts; test diacritics.
- [Similar Malay/Indonesian drafts] → Acceptable for v1; differentiate later if needed.

## Migration Plan

Additive after foundation.

## Open Questions

None blocking.
