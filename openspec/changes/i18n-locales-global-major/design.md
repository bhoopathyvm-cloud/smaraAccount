## Context

Depends on `i18n-foundation`. Locales: Arabic (`ar`), Russian (`ru`), Indonesian (`id`), Turkish (`tr`), Vietnamese (`vi`), Thai (`th`), Malay (`ms`), Ukrainian (`uk`), Polish (`pl`), Dutch (`nl`).

## Goals / Non-Goals

**Goals:** AI-draft ARB parity; RTL for Arabic; fonts for Arabic, Cyrillic, Thai, Vietnamese.

**Non-Goals:** Full dialect coverage (e.g. Egyptian Arabic); human QA; every UN language.

## Decisions

### 1. Arabic RTL
Verify `Directionality` and mirrored icons/alignment on primary screens when `ar` is active.

### 2. Scope of “major”
This pack is the v1 worldwide remainder; more languages can be future packs without redesign.

## Risks / Trade-offs

- [RTL layout bugs] → Manual smoke on home, record transaction, settings.
- [Thai/Vietnamese rendering] → Dedicated fonts; test diacritics.

## Migration Plan

Additive after foundation.

## Open Questions

- Whether Malay (`ms`) and Indonesian (`id`) share too-similar AI drafts — acceptable for v1; differentiate later if needed.
