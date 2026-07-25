## Context

Smara Accounting is a Flutter/Drift local-first ledger. All user-visible copy is hardcoded English in views, ViewModels, and `LedgerRepository` exception messages. Architecture (`Specs/architecture/smara-architecture.md`) deferred `flutter_localizations` until a second language was required. The product now targets India's 22 scheduled languages plus major world languages via follow-on locale-pack changes. This foundation lands English-complete ARB infrastructure, language-agnostic errors, and the AI-first translation policy those packs depend on.

## Goals / Non-Goals

**Goals:**
- Every user-facing string reachable through `AppLocalizations` with English as the template.
- Domain/repository never emit user-facing language text; UI maps error codes to l10n.
- In-app language preference with device-locale default and English fallback.
- Documented AI draft workflow and glossary so locale packs are mechanical.
- Font strategy that will not break when Indic/CJK ARBs arrive.
- BIP39 mnemonic language remains English.

**Non-Goals:**
- Shipping non-English ARB files in this change (owned by locale-pack changes).
- Crowdin/Lokalise integration (optional later; not required for AI-draft v1).
- Professional human translation or linguistic QA.
- Translating BIP39 wordlists.
- Over-the-air translation delivery / CDN.
- Changing ledger schema solely for i18n (seeded names policy is display-layer).

## Decisions

### 1. Flutter gen-l10n + ARB as the only user-facing copy store

Use `flutter_localizations` + `intl`, `generate: true`, `l10n.yaml` → `lib/l10n/app_en.arb` template, synthetic `AppLocalizations`.

**Why not easy_localization / slang?** Project already documents the official Flutter skill path; type-safe generated accessors match existing Dart style; no new runtime asset-loading package.

**Why not Crowdin in v1?** AI drafts can write ARB files directly in-repo; Crowdin adds cost without unlocking AI-first delivery.

### 2. Error codes, not English exception messages

Introduce a stable `AppErrorCode` (or sealed error types) on domain exceptions. Repository throws codes + structured params (ids, amounts). ViewModels/UI call a small mapper: `localizeError(l10n, code, params)`.

**Alternative considered:** keep English in exceptions and translate only in UI via string matching — rejected (fragile, unlocalizable placeholders, encourages English leakage).

**Alternative considered:** pass `BuildContext` into the repository — rejected (breaks layering).

### 3. Language preference

Store preferred locale tag (e.g. `en`, `ta`) in existing secure/local prefs surface (or a simple SharedPreferences/FlutterSecureStorage-adjacent setting consistent with app patterns). `MaterialApp.router(locale: …, localeResolutionCallback: …)` with fallback to `en`. Unsupported device locales resolve to English until a locale pack registers them.

Changing the language SHALL take effect immediately in the running app, not only on next launch: the preferred-locale value lives in a small `ChangeNotifier` (or `ValueNotifier<Locale>`) that the app root listens to and passes into `MaterialApp.router(locale: …)`, so selecting a new language in the picker triggers an immediate rebuild.

The language picker SHALL label each entry with that language's own native-script name (e.g. "தமிழ்", "हिन्दी"), not only its English name — sourced from a small static `{localeTag: nativeName}` lookup table maintained alongside `supportedLocales` (not derived from `Locale.nativeDisplayLanguage`, which Flutter does not provide out of the box). Each locale pack change adds its own locales' native names to this table alongside its ARB files.

### 4. Seeded system names

Keep English (or stable internal names) in SQLite for system groups/categories. At display time, if the stored name still equals the known system default, show the localized label; if the user renamed it, show the stored string unchanged.

**Alternative considered:** store l10n keys in DB — rejected for now (complicates migrations and user renames); can revisit later.

### 5. AI-translated v1 policy (for follow-on packs)

- English ARB is the only human-authored source of truth.
- Locale packs generate `app_<locale>.arb` via AI using a shared glossary of accounting terms.
- Missing keys fall back to English via Flutter's localization fallback.
- Placeholders/`@` metadata must be preserved byte-for-byte from the template.
- Human review is explicitly a future improvement, not a gate for v1 locale packs.

### 6. Fonts

Bundle (or document) Noto Sans family coverage for Latin + Indic + CJK + Arabic ahead of locale packs, or load per-script font assets when registering locales. Foundation at least selects a theme text theme that will not silently tofu when packs land.

### 7. Locale pack dependency graph

```
i18n-foundation (this change)
        │
        ├─ i18n-locales-indian-dravidian   (ta, te, ml, kn)
        ├─ i18n-locales-indian-north       (hi, ur, pa, ne, sa, doi, ks, mai)
        ├─ i18n-locales-indian-west        (mr, gu, kok, sd)
        ├─ i18n-locales-indian-east        (bn, as, or, mni, brx, sat)
        ├─ i18n-locales-european           (de, fr, es, it, pt, hu, ro)
        ├─ i18n-locales-east-asian         (ja, zh, ko)
        └─ i18n-locales-global-major       (ar, ru, id, tr, vi, th, ms, uk, pl, nl)
```

Each pack: add ARB files, register locales in `supportedLocales`, ensure fonts cover scripts, smoke-test language switcher.

### 8. Number/date formatting

`formatAmountMinor` stays numeric-dot for ledger consistency in v1 unless a follow-up explicitly adopts `NumberFormat`; currency **codes** remain ISO 4217. Material date pickers use Flutter's locale delegates once wired.

## Risks / Trade-offs

- [AI quality for accounting terms] → Mitigation: shared glossary; English fallback; defer human QA to later versions.
- [Widget tests brittle on English] → Mitigation: pin `locale: Locale('en')` in test harness; prefer keys where practical.
- [Exception refactor touches many call sites] → Mitigation: do codes + mapper in one foundation PR before any locale pack.
- [Indic/CJK tofu / layout overflow] → Mitigation: font bundling in foundation or first Indic pack; flexible layouts already mostly column-based.
- [Urdu/Arabic RTL] → Mitigation: global-major / north packs must enable RTL; foundation wires `GlobalWidgetsLocalizations` so Directionality works when those locales register.
- [Merge conflict with multi-currency UI] → Mitigation: prefer applying foundation after multi-currency UI stabilizes, or extract strings in small file batches.

## Migration Plan

1. Land dependencies + empty `app_en.arb` + MaterialApp delegates (English only).
2. Extract UI/VM strings incrementally; app remains English-identical.
3. Introduce error codes; map at UI; keep temporary English message field only if needed during transition, then remove.
4. Add language preference UI (list starts with English; packs append).
5. Locale packs merge independently afterward.

Rollback: revert to hardcoded English only if necessary before packs ship; after packs, removing a locale is deleting its ARB + unregistering it.

## Open Questions

- Exact prefs storage API (reuse secure storage vs lightweight prefs) — decide during apply from existing patterns.
- Whether `zh` means Simplified only (`zh`) or also Traditional (`zh_Hant`) in east-asian pack — default Simplified for v1.
- Portuguese: single `pt` vs `pt_BR` / `pt_PT` — default `pt` (Brazilian-leaning AI draft acceptable for v1).
