## Context

Depends on `i18n-foundation`. Locales: German (`de`), French (`fr`), Spanish (`es`), Italian (`it`), Portuguese (`pt`), Hungarian (`hu`), Romanian (`ro`).

## Goals / Non-Goals

**Goals:** AI-draft ARB parity; register locales; basic layout check for long German labels.

**Non-Goals:** Separate `pt_BR`/`pt_PT` ARBs; Latin American vs European Spanish variants; human QA.

## Decisions

### 1. Single Portuguese locale
Use `pt` only in v1. Foundation resolution maps `pt_BR` and `pt_PT` → `pt`. Endonym: Português.

### 2. Spanish
Use `es` without regional variant. Endonym: Español.

### 3. Other endonyms
Deutsch, Français, Italiano, Magyar, Română.

## Risks / Trade-offs

- [Long German compounds overflow] → Soft-wrap / flexible buttons; smoke-test primary CTAs.
- [Regional Portuguese differences] → Accept AI generic `pt` for v1.

## Migration Plan

Additive after foundation.

## Open Questions

None blocking.
