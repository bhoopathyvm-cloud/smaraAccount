## Context

Smara Accounting is a Flutter/Drift local-first ledger. All user-visible copy is hardcoded English in views, ViewModels, and `LedgerRepository` exception messages. Architecture (`Specs/architecture/smara-architecture.md`) deferred `flutter_localizations` until a second language was required. The product now targets India's 22 scheduled languages plus major world languages via follow-on locale-pack changes. This foundation lands English-complete ARB infrastructure, language-agnostic errors, and the AI-first translation policy those packs depend on.

## Goals / Non-Goals

**Goals:**
- Every user-facing string reachable through `AppLocalizations` with everyday household English as the template (including tooltips, spoken labels, snackbars, dialogs, empty states, import skip reasons, and Settings labels).
- Domain/repository/parser layers never emit user-facing language text; UI maps error codes to l10n.
- In-app language preference: follow device (default) or pin a supported locale; English fallback; immediate rebuild including `Directionality`.
- Documented AI draft workflow and glossary so locale packs are mechanical.
- Font *registry* that will not break when Indic/CJK ARBs arrive; Latin ships here, script files ship with packs.
- Recovery words stay English (BIP39 wordlist).
- Unchanged system defaults and a closed list of notes the app wrote localize at display time using household labels; text the user typed never does.

**Non-Goals:**
- Shipping non-English ARB files in this change (owned by locale-pack changes).
- Crowdin/Lokalise integration (optional later; not required for AI-draft v1).
- Professional human translation or linguistic QA.
- Translating recovery words into other languages.
- Over-the-air translation delivery / CDN.
- Changing ledger schema solely for i18n (seeded names policy is display-layer).
- Locale-specific number/currency-symbol formatting (explicitly deferred; a later `localized-money-formatting` change may supersede Decision 8).
- Making TalkBack/VoiceOver follow the in-app locale (OS screen readers typically follow the device language; document this limitation rather than claiming otherwise).

## Decisions

### 1. Flutter gen-l10n + ARB as the only user-facing copy store

Use `flutter_localizations` + `intl`, `generate: true`, `l10n.yaml` → `lib/l10n/app_en.arb` template, synthetic `AppLocalizations`.

`l10n.yaml` SHALL set `untranslated-messages-file` so CI can fail a locale pack that drops keys. Missing keys in a locale ARB are substituted from the English template at *generation* time (Flutter gen-l10n), which is the mechanism behind the spec's "falls back to English" scenario — not a separate runtime lookup.

ARB placeholders and ICU plurals/selects MUST be declared in `@` metadata on the English template; locale packs copy that metadata byte-for-byte.

**Why not easy_localization / slang?** Project already documents the official Flutter skill path; type-safe generated accessors match existing Dart style; no new runtime asset-loading package.

**Why not Crowdin in v1?** AI drafts can write ARB files directly in-repo; Crowdin adds cost without unlocking AI-first delivery.

### 2. Error codes, not English exception messages

Introduce a stable `AppErrorCode` (or sealed error types) on domain exceptions. Repository and parsers throw codes + structured params (ids, amounts, skip-reason codes). ViewModels/UI call a small mapper: `localizeError(l10n, code, params)`.

`Exception.toString()` MAY include the code and params for logs and test diagnostics. It is **not** the user-visible string. Tests MUST assert on codes/types, not English prose.

If the mapper does not recognize a code (a new throw site shipped without an ARB key), show a generic localized "Something went wrong" message that MAY include the raw code for support, and MUST NOT crash.

**Alternative considered:** keep English in exceptions and translate only in UI via string matching — rejected (fragile, unlocalizable placeholders, encourages English leakage).

**Alternative considered:** pass `BuildContext` into the repository — rejected (breaks layering).

### 3. Language preference

Store the preference in existing `SettingsRepository` (`SharedPreferencesAsync`), **not** secure storage (that remains for recovery-phrase / signing-key material). Two states:

- **Follow device** (default, stored as a sentinel such as null / `system`): resolve from the platform locale.
- **Pinned locale**: an explicit supported tag (e.g. `en`, `ta`).

The picker MUST offer "Same as the phone" as a first-class row, distinct from choosing English. Choosing `en` means English even if the phone is `hi_IN`.

`MaterialApp.router(locale: …, localeListResolutionCallback: …)` with fallback to `en`. Changing the language SHALL take effect immediately in the running app, including `TextDirection`: the preferred-locale value lives in a small `ChangeNotifier` (or `ValueNotifier<Locale?>`) that the app root listens to.

If a stored pinned tag is later removed from `supportedLocales` (pack uninstalled / rollback), treat it as unsupported and fall back to follow-device, then English.

### 3b. Locale resolution

Match on **language code** (and script when present), not exact `Locale` equality:

| Device locale | Supported app locales include | Resolves to |
| --- | --- | --- |
| `hi_IN`, `hi` | `hi` | `hi` |
| `pt_BR`, `pt_PT`, `pt` | `pt` | `pt` |
| `zh`, `zh_CN`, `zh_Hans` | `zh` (Simplified v1) | `zh` |
| `zh_TW`, `zh_HK`, `zh_Hant` | `zh` only (no `zh_Hant`) | **English** (do **not** silently serve Simplified) |
| `ar_EG`, `ar` | `ar` | `ar` (RTL) |
| `id`, `in` (legacy Android Indonesian tag) | `id` | `id` |
| anything else unmatched | — | `en` |

Odia uses BCP-47 `or` (`Locale.fromSubtags(languageCode: 'or')`). Document that this is the ISO 639-1 tag, not the English word "or".

Flutter's built-in RTL language list may omit Kashmiri (`ks`) and Sindhi (`sd`). Locale packs that register those tags SHALL still get `TextDirection.rtl` when their v1 script is Arabic-derived — if `Bidi.isRtlLanguage` is false for the tag, the app root MUST force RTL for those locales rather than trusting Flutter's table.

Language preference applies from the first `MaterialApp` frame, including onboarding, even when no signing identity exists yet (`SettingsRepository` does not need the ledger).

### 4. Seeded system names and system-generated descriptions

Keep stored names as they are in SQLite for:

- system groups and starter categories
- the seeded starter account (`Cash & Bank` in the database; on screen, if unchanged, show a household label such as the main bank account)
- Opening Balance Equity and Transfers in transit (stored names; on screen, if shown, **Starting amount** and **Money in transit**)

At display time, if the stored name still equals the known default, show the household localized label; if the user renamed it, show the stored string unchanged.

A **closed list** of notes the app wrote (`Opening balance`, `Settlement`, `Transfer fee / shortfall`, and any similar hardcoded phrase) SHALL map at display time to household ARB strings (`Starting amount`, `Money arrived`, `Moving fee` / `Amount that didn't arrive`) when the stored text still equals that template. Notes the user typed are shown exactly as stored, in every language.

Register counterpart labels SHALL become ARB strings with placeholders (`Moved to {accountName}`), not concatenated English `"Transfer: "` in the ViewModel.

**Alternative considered:** store l10n keys in DB — rejected for now (complicates migrations and user renames); can revisit later.

### 5. AI-translated v1 policy (for follow-on packs)

- English ARB is the only human-authored source of truth.
- Locale packs generate `app_<locale>.arb` via AI using the **household** glossary (Decision 5b), not an accounting glossary.
- Missing keys fall back to English via Flutter's generation-time substitution (Decision 1).
- Placeholders/`@` metadata must be preserved byte-for-byte from the template, including ICU `plural` / `select` skeletons (Arabic and others need more than English's one/other).
- Human review is explicitly a future improvement, not a gate for v1 locale packs.
- After packs ship, **new English keys land in this template first**; a follow-on pack (or a small chore on the same pack) adds translations. Until then the new key shows English in every locale — acceptable.

### 5b. User-visible English is everyday household language

The English ARB, error strings, picker labels, unchanged default names, notes the app wrote, import skip reasons, Settings copy, and the translator glossary are written for a person who does not know bookkeeping.

Use the household dictionary (same as `household-language-voice`):

| Internal / today's code | Words the user sees (English ARB) |
| --- | --- |
| Money in | Received |
| Money out | Spent |
| Record transaction | Add spent / Add received |
| Transfer | Moved money |
| Reverse / reversal | Fix |
| Archive | Hide from new entries |
| Net position | What you have minus what you owe |
| Pending transfer / Transfers in transit | Money in transit |
| Financial account | Account |
| Opening balance (line note / counterpart) | Starting amount |
| Opening Balance Equity (if a name is shown) | Starting amount |
| Settlement | Money arrived |
| Transfer fee / shortfall | Moving fee / Amount that didn't arrive |
| `Transfer: {name}` | Moved to {name} / Moved from {name} |
| Locale / pin a locale | Language / Use this language |
| Follow device | Same as the phone |
| Recovery phrase / mnemonic / BIP39 | Recovery words (the words themselves stay English) |
| ISO 4217 in user-facing sentences | A code like USD or INR |
| Journal / posting / ledger / debit / credit | Do not use |

Internal code, table names, and stored SQLite strings MAY keep the left column. Translators MUST be given the **right** column, never asked to translate "journal entry" or "reversal" as if those were the product's words.

The generic unknown-error string is everyday English: "Something went wrong." not "Unhandled domain exception."

This is mandatory even if `household-language-voice` has not archived yet — do not freeze current on-screen ledger jargon as the translation template.

### 6. Fonts

This change: pick a theme text theme + a font-asset registry so adding a script later is registering a file, not rewriting widgets. Ship a Latin-capable family (Noto Sans Latin or the current theme font) and **license notes** for any bundled font (Noto is SIL OFL).

Locale packs add the script files they need (Tamil, CJK, Arabic, Ol Chiki, …). Do **not** embed every Indic/CJK file in the foundation APK "just in case" — that duplicates pack work and inflates size before those languages exist.

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

Each pack: add ARB files, register locales in `supportedLocales` and the native-name table, ensure fonts cover scripts, smoke-test language switcher, and append the new languages to `docs/user-guide.md`. RTL locales (`ur`, `ar`, and Arabic-script `sd` / Perso-Arabic `ks` when those packs choose those scripts) must flip `Directionality` on the same immediate-rebuild path as LTR.

Indian packs may merge independently; the east pack's "all 22 scheduled languages appear" check is integration-level and is only asserted when all four Indian packs are present.

### 8. Number/date formatting

`formatAmountMinor` stays numeric-dot for ledger consistency in v1 unless a follow-up (`localized-money-formatting`) explicitly adopts `NumberFormat`; currency **codes** remain ISO 4217.

On RTL screens, those digit strings MUST still appear left-to-right (e.g. wrap the amount widget in `Directionality(textDirection: ltr)` or a Unicode isolate). Otherwise `1234.56` can visually reverse. This is not locale-specific grouping; it is bidi protection for the existing format.

Material date pickers use Flutter's locale delegates once wired. Register **transaction dates** currently display from stored `YYYY-MM-DD` / `DateTime`; v1 MAY keep that ISO-like display rather than locale date patterns, so a Tamil UI does not silently change `2026-01-02` into a different calendar convention. Locale date patterns are a later improvement, not this change. Production widgets SHALL NOT hardcode `TextDirection.ltr` for whole screens (widget *previews* may).

### 9. How ViewModels get l10n (layering)

Views remain the only widgets with `BuildContext`. On submit/error display, the View passes `AppLocalizations.of(context)` (or the result of `localizeError`) into the ViewModel, **or** the ViewModel stores an `AppErrorCode` + params and the View maps it while building. ViewModels SHALL NOT call `AppLocalizations.of` via a global key / navigator context hack, and SHALL NOT import generated l10n solely to hardcode English by calling the `en` lookup.

Client-side validation messages follow the same rule: the VM exposes a code or the View supplies l10n when constructing the VM for that frame.

### 10. Language picker UX

Each row shows the **endonym** (native script) as the primary label and a **secondary Latin/English name** (e.g. "தமிழ் — Tamil") so a user who cannot read English still recognizes their language, and a user browsing a long list can still search mentally in English.

When more than one locale is registered (i.e. once any pack lands), the picker SHALL offer a filter/search field matching both the endonym and the English/Latin name. Sort: English/Latin name ascending, with "Same as the phone" at the top and English (`en`) next.

Foundation ships the widget with only `en` + same-as-the-phone; search can hide until `supportedLocales.length > 1`.

### 11. Import skip reasons and Settings provider names

`StatementSkippedRow.reason` and similar parser strings are user-visible. Parsers SHALL emit a stable skip-reason **code**; the import preview UI maps it through l10n.

`ExchangeRateProvider.displayName` is user-visible Settings copy and SHALL move to ARB (or a l10n helper keyed by enum), not stay as a Dart string on the enum.

### 12. Accessibility limitation

In-app locale override changes widgets under `MaterialApp`. OS screen readers (TalkBack, VoiceOver) typically continue to speak in the **device** language. The user guide SHALL state this. Do not add a spec that claims the screen reader follows the in-app picker.

## Risks / Trade-offs

- [AI quality for accounting terms] → Mitigation: shared glossary; English fallback; defer human QA to later versions.
- [Widget tests brittle on English] → Mitigation: pin `locale: Locale('en')` in test harness; prefer keys where practical.
- [Exception refactor touches many call sites] → Mitigation: do codes + mapper in one foundation PR before any locale pack.
- [Indic/CJK tofu / layout overflow] → Mitigation: font registry in foundation; script files in packs; flexible layouts already mostly column-based; German overflow smoke in the European pack.
- [Urdu/Arabic/Sindhi/Kashmiri RTL] → Mitigation: packs that choose Arabic-derived scripts must enable RTL; foundation wires `GlobalWidgetsLocalizations` so Directionality works when those locales register; language change rebuilds direction immediately.
- [zh_TW users getting Simplified Chinese] → Mitigation: Decision 3b — unmatched Hant regions fall back to English until a Traditional pack exists.
- [Screen reader language mismatch] → Mitigation: documented limitation (Decision 12).
- [Merge conflict with multi-currency UI] → Mitigation: prefer applying foundation after multi-currency UI stabilizes, or extract strings in small file batches.
- [Household-voice vs ARB English] → Mitigation: Decision 5 coordination note.
- [APK size if all Noto scripts bundled early] → Mitigation: Decision 6 — packs own script files.

## Migration Plan

1. Land dependencies + empty `app_en.arb` + MaterialApp delegates (English only) + `untranslated-messages-file`.
2. Extract UI/VM strings incrementally; app remains English-identical.
3. Introduce error codes; map at UI; keep temporary English message field only if needed during transition, then remove.
4. Add language preference to `SettingsRepository` + picker (follow-device + English).
5. Display-map unchanged system names and the closed list of system journal descriptions.
6. Locale packs merge independently afterward.

Rollback: revert to hardcoded English only if necessary before packs ship; after packs, removing a locale is deleting its ARB + unregistering it; pinned users of that locale fall back per Decision 3.

## Open Questions

None blocking. Prefs storage is `SettingsRepository` (Decision 3). Chinese v1 is Simplified `zh` with Hant devices staying on English (Decision 3b). Portuguese v1 is a single `pt` that absorbs `pt_BR` / `pt_PT` (Decision 3b).
