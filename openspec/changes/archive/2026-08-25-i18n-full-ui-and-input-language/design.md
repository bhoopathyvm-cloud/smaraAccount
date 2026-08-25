## Context

Locale packs and `AppLocalizations` already drive most **labels**. `MaterialApp.router(locale:)` follows `LocaleController`. Domain failures mostly use `AppErrorCode` + `localizeError`. Seeded SQLite names stay English and lists call `localizeStoredName`.

What a Tamil speaker still sees in English:

1. **Field values, not labels.** Onboarding prefills `Cash & Bank`. Rename dialogs use `TextEditingController(text: account.name)` / `group.name` / `category.name`. Labels are Tamil; the text *inside* the field is English.
2. **No IME hint.** No `TextField.hintLocales`. Flutter honors that hint on Android API 24+ only. macOS/iOS keep the system keyboard until the user switches it.
3. **Hardcoded chrome and errors.** `MoneyAmountField` error `'Enter a valid amount'`; CSV/OFX skip reasons are English sentences shown on the import screen; `LockViewModel` always uses `englishAppLocalizations.unlockBiometricReason`; `MaterialApp.title` is `'Smara Accounting'`; calendar chips use ISO `yyyy-MM-dd`; iOS/macOS Face ID usage strings are English; `FirstWeekSetupView` would show a raw `errorMessage` if one were set.
4. **Parser vs spec gap.** `localized-errors` already requires skip *codes*; parsers still emit English `StatementSkippedRow.reason` strings.
5. **Material overlay mix.** Flutter ships Material/Cupertino for Tamil (`ta`) and most packs. App locales **sa, doi, ks, mai, kok, sd, mni, brx, sat** have no Material pack, so date-picker OK/Cancel and the text-selection toolbar stay English while our ARB labels translate.
6. **Research prompt** is a hardcoded English paragraph (`buildInvestmentResearchPrompt`).

Constraints to preserve: BIP39 English; amount formatting by **currency** not UI locale; do not auto-translate user-authored text; do not rewrite SQLite seeds to Tamil (switching language later would freeze the wrong language).

## Goals / Non-Goals

**Goals:**
- Typing and field contents match the selected language for household text (names, payees, memos), with IME hints where the OS allows.
- Unchanged system defaults appear localized in editors; saving without a real rename keeps the English seed.
- Every user-visible error, skip reason, date chip, app title, and biometric/permission prompt uses the active locale (or a documented Material fallback).
- Research prompt template follows the UI locale; identifiers stay as stored.

**Non-Goals:**
- Forcing the OS keyboard language on platforms that do not honor IME hints (cannot install a Tamil keyboard from the app).
- Bundling Noto font files (i18n-foundation follow-up).
- Translating BIP39 or ISO 4217 / ticker / ISIN / PIN input.
- Reformatting ledger amounts to the UI locale.
- Auto-translating payees, memos, or custom account names the user already typed.
- Crowdin / human translation QA.

## Decisions

### 1. Keep English seeds in SQLite; localize in the editor, canonicalize on save

Lists already use `localizeStoredName`. Editors MUST prefill that localized string, not the raw seed.

On save: if the trimmed text equals the localized default **or** the English seed, persist the English seed so language switches keep working. If the user typed something else, persist as typed (today's rename behavior).

**Why not seed Tamil into SQLite on first launch?** A later language change would show frozen Tamil with no mapping. **Why not store l10n keys in the DB?** Same rejection as i18n-foundation (migrations + user renames).

Helper: `editingNameFor(l10n, stored)` and `canonicalNameToPersist(l10n, storedOriginal, edited)`.

Apply the same sentinel pattern to the CSV fallback description `'CSV import'`.

### 2. Shared text-field policy, not 40 one-off `hintLocales`

Add a small wrapper (or `InputDecoration`/`TextField` helper) used by household text fields:

- `hintLocales: [Localizations.localeOf(context)]` unless `latinOnly: true`
- No `FilteringTextInputFormatter` that strips Indic/CJK/Arabic except on latin-only fields (ISO currency, PIN digits, BIP39 English words, ticker/ISIN)

Latin-only fields do **not** set a Tamil IME hint.

**Why not a platform channel that locks macOS `allowedInputSourceLocales`?** Too aggressive (blocks ISO codes and recovery words) and fails if the user never enabled that keyboard. Hint + documentation is the honest contract. Optional later: a non-locking “preferred locale” channel if a safe API exists.

### 3. Skip reasons become codes; UI maps them

Replace English `StatementSkippedRow.reason` with a stable code (+ optional params: raw date, pattern). `localizeError` or a sibling mapper fills ARB. Parsers stay language-agnostic (already required by `localized-errors`).

### 4. Calendar dates follow UI locale; amounts do not

Replace hand-rolled `yyyy-MM-dd` display in register, summary, transfer, holdings, and row tiles with `MaterialLocalizations` / `DateFormat` using the **UI** locale. Date pickers already inherit `MaterialApp.locale` where Flutter has a Material pack.

Do not change `formatAmountMinor` / `localeForCurrency`.

### 5. Material chrome fallback for locales Flutter does not ship

For app locales missing `kMaterialSupportedLanguages`, resolve Material/Cupertino/Widgets delegates to a **script sibling** so overlay chrome is not English:

| App locale | Fallback Material locale |
| --- | --- |
| sa, doi, mai, kok, brx | hi |
| ks, sd | ur |
| mni, sat | en (no honest sibling) |

Our ARB labels still use the user's locale. Document that mni/sat date-picker chrome may stay English.

Tamil/Telugu/etc. use Flutter's own Material pack — no fallback.

### 6. Biometric and Info.plist

`LockViewModel` must resolve `unlockBiometricReason` (and platform Face ID usage copy) via the **active** locale from `LocaleController`, not `englishAppLocalizations`.

Ship `InfoPlist.strings` (iOS/macOS) per supported locale for `NSFaceIDUsageDescription`, generated from ARB so the system dialog is not stuck on English. Brand name “SMARA Account” may stay as the product name inside that sentence.

### 7. Research prompt

Move the English paragraph into ARB (with placeholders for name, ticker, ISIN). `buildInvestmentResearchPrompt` takes `AppLocalizations`. Empty ticker/ISIN use localized “(none provided)” lines. Instrument **name** is stored text (may be English if the user named it in English).

### 8. Leftover English call sites (inventory for apply)

| Location | Issue |
| --- | --- |
| `lib/ui/core/money_amount_field.dart` | Hardcoded `'Enter a valid amount'` |
| `lib/ui/features/onboarding/views/first_account_name_view.dart` | Prefills English seed |
| `lib/ui/features/account_management/views/account_management_view.dart` | Rename account/group controllers use stored English |
| `lib/ui/features/category_management/views/category_management_view.dart` | Rename category controller uses stored English |
| `lib/domain/csv/csv_parser.dart` / `ofx_parser.dart` | English skip sentences; `'CSV import'` fallback |
| `lib/ui/features/lock/view_models/lock_view_model.dart` | English biometric reason |
| `lib/ui/features/first_week_setup/` | Raw `errorMessage`; no `LocalizedErrorMixin` |
| `lib/main.dart` | `title: 'Smara Accounting'` (ARB already has `appTitle`) |
| Register/summary/transfer/holdings/row tile | ISO date strings |
| ViewModels passing `error.toString()` into `params['detail']` | English exception text in otherwise localized templates |
| iOS/macOS `Info.plist` | English Face ID / Touch ID usage |
| `lib/domain/investment_research_prompt.dart` | English prompt |

## Risks / Trade-offs

- [macOS/iOS keyboard stays English] → Mitigation: `hintLocales` where honored; user-guide states the OS keyboard switcher is still required on desktop; never lock input sources.
- [User edits a localized default by one character] → Mitigation: canonicalize only exact match to localized or English seed; otherwise treat as a custom name.
- [Script-sibling Material fallback feels “wrong language”] → Mitigation: only for locales Flutter does not ship; Tamil is unaffected.
- [Detail params still English] → Mitigation: stop forwarding `toString()` into user-visible ARB placeholders; use generic household copy or a nested code.
- [Widget/acceptance tests pin English field values] → Mitigation: tests that type into rename/onboarding use localized or canonical helpers; keep `locale: Locale('en')` in tests that assert English ARB.

## Migration Plan

No schema migration. Existing custom names stay as stored. Unchanged seeds keep matching English constants.

Rollback: revert the change; English seeds and ARB labels remain valid.

## Open Questions

None blocking apply. Platform channel for macOS IME is deferred unless implementation finds a non-locking one-liner already used in-tree.
