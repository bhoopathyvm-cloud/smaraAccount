## 1. Shared helpers and ARB keys

- [x] 1.1 Add `editingNameFor` / `canonicalNameToPersist` (or equivalent) next to `localizeStoredName`, including the `'CSV import'` display sentinel, with unit tests for Tamil vs custom vs English-seed round-trip
- [x] 1.2 Add a household `AppTextField` (or helper) that sets `hintLocales` from `Localizations.localeOf(context)` and a `latinOnly` path that does not; use it for new and existing household fields
- [x] 1.3 Add English ARB keys for skip reasons, research-prompt template, invalid-amount field error if not reused, CSV-import description, and any new date-related copy; run the existing overlay/sync tool so every locale ARB gets translations (not silent English copies)

## 2. Input language and editor values

- [x] 2.1 Prefill first-account, rename-account, rename-group, and rename-category fields with `editingNameFor`; persist via `canonicalNameToPersist`
- [x] 2.2 Route household name/payee/memo/description fields through the helper in 1.2 so they accept Indic scripts and carry the IME hint after a language change without restart
- [x] 2.3 Keep ISO currency, PIN, BIP39, and ticker/ISIN fields Latin-or-digit restricted and without a Tamil IME hint
- [x] 2.4 Replace `MoneyAmountField`'s hardcoded `'Enter a valid amount'` with `l10n.validationEnterValidAmount` (or the new key)

## 3. Errors, skips, and remaining chrome

- [x] 3.1 Change CSV/OFX parsers so `StatementSkippedRow` carries a stable code + params; map those in the import skipped-rows UI via `localizeError` / ARB
- [x] 3.2 Stop passing `error.toString()` / `'$e'` into user-visible `params['detail']`; use a nested code or generic household string
- [x] 3.3 Put `FirstWeekSetupViewModel` on `LocalizedErrorMixin`, catch create-account failures, and show `errorMessageFor(l10n)` in the view
- [x] 3.4 Pass the active locale into biometric `reason` (not `englishAppLocalizations`); add iOS/macOS `InfoPlist.strings` for `NSFaceIDUsageDescription` per supported locale
- [x] 3.5 Use `onGenerateTitle` / `l10n.appTitle` instead of hardcoded `MaterialApp.title`
- [x] 3.6 Replace ISO `yyyy-MM-dd` display in register row, register date-range chip, summary, transfer, and holdings with UI-locale date formatting; leave amount formatting on currency conventions
- [x] 3.7 Attach Material/Cupertino locale fallbacks for app locales Flutter does not ship (sa/doi/mai/kok/brx → hi, ks/sd → ur, mni/sat → en)

## 4. Research prompt and user guide

- [x] 4.1 Build `buildInvestmentResearchPrompt` from `AppLocalizations` for the active locale; keep stored name/ticker/ISIN; omit quantity/cost/account
- [x] 4.2 Add a Settings language section to `docs/user-guide.md` covering typing, default names in fields, OS keyboard limits, recovery words, amounts, and untranslated typed notes

## 5. Tests and analysis

- [x] 5.1 Unit-test skip-code → localized message (English and one non-English, e.g. Tamil) and that parsers do not require matching English sentences
- [x] 5.2 Widget-test Tamil first-account/rename field shows the localized seed and saving without edit persists `Cash & Bank`
- [x] 5.3 Widget-test amount-field invalid state is not the English literal; widget-test research prompt instructional text follows locale
- [x] 5.4 Run `dart analyze` and the affected unit/widget suites; fix breakages from date format, skip-reason, and seed-name assertion changes
