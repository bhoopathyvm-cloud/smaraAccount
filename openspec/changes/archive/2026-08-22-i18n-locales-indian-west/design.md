## Context

Depends on `i18n-foundation`. Locales: Marathi (`mr`), Gujarati (`gu`), Konkani (`kok`), Sindhi (`sd`).

## Goals / Non-Goals

**Goals:** AI-draft ARB parity; register locales; fonts for Devanagari, Gujarati, and Arabic-script Sindhi; RTL for Sindhi.

**Non-Goals:** Human QA; Goan vs Maharashtrian Konkani orthography split; Devanagari Sindhi.

## Decisions

### 1. Sindhi script for v1
Arabic-script Sindhi. Endonym: سنڌي — Sindhi. `sd` SHALL activate RTL. If Flutter does not treat `sd` as an RTL language code, force `TextDirection.rtl` at the app root. Devanagari Sindhi is a future variant, not v1.

### 2. Konkani locale tag
`kok` (`app_kok.arb`). Endonym: कोंकणी — Konkani (Devanagari). LTR.

### 3. Marathi and Gujarati
मराठी — Marathi; ગુજરાતી — Gujarati. LTR.

## Risks / Trade-offs

- [Sindhi script mismatch for Devanagari readers] → Document Arabic-script v1; future regional variant pack.
- [AI quality for Konkani] → English fallback; polish later.

## Migration Plan

Additive after foundation.

## Open Questions

None blocking. Sindhi script is Arabic (Decision 1).
