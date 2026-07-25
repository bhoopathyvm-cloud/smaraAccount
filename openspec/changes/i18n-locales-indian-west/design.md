## Context

Depends on `i18n-foundation`. Locales: Marathi (`mr`), Gujarati (`gu`), Konkani (`kok`), Sindhi (`sd`).

## Goals / Non-Goals

**Goals:** AI-draft ARB parity; register locales; fonts for Devanagari, Gujarati, and chosen Sindhi script.

**Non-Goals:** Human QA; separate Goan Konkani orthography variants beyond `kok`.

## Decisions

### 1. Sindhi script for v1
Prefer Arabic-script Sindhi if font coverage exists; otherwise Devanagari. Record the choice in design during apply if fonts dictate.

### 2. Konkani locale tag
Use `kok` as BCP-47 language subtag for the ARB file (`app_kok.arb`).

## Risks / Trade-offs

- [Sindhi script mismatch for some users] → Document choice; allow a future regional variant pack.
- [AI quality for Konkani] → English fallback; polish later.

## Migration Plan

Additive after foundation.

## Open Questions

- Confirm Sindhi script at apply time based on available font assets.
