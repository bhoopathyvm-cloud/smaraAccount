# What's Built

Every capability below exists because a spec was written for it first,
implemented against that spec, and archived once done — the concrete
result of the [spec-driven approach](how-it-was-built.md). Each entry
links to its current spec in the repository, the precise, testable
statement of what that capability does today.

| Capability | What it does |
|---|---|
| [Core ledger](https://github.com/bhoopathyvm-cloud/smaraAccount/blob/main/openspec/specs/core-ledger-single-account/spec.md) | The foundational double-entry ledger: recording transactions without picking debit/credit sides, immutable posted entries (corrections via reversal, never edits), a running register, and an income/expense summary. |
| [Onboarding language selection](https://github.com/bhoopathyvm-cloud/smaraAccount/blob/main/openspec/specs/onboarding-language-selection/spec.md) | First launch starts with a language picker showing every supported language in its own script, with the device language pre-highlighted. |
| [Books Copy & Continuation](https://github.com/bhoopathyvm-cloud/smaraAccount/blob/main/openspec/changes/books-copy-and-continuation/specs/books-copy/spec.md) | First launch offers **New setup** or **Restore from a copy**. The signing key never leaves the device. A passphrase-protected Books Copy moves books between phones; Continuation continues books under a new this-device key when the private key is missing. |
| [First-week setup wizard](https://github.com/bhoopathyvm-cloud/smaraAccount/blob/main/openspec/specs/first-week-setup/spec.md) | A short, skippable, one-time wizard right after onboarding to name a main bank account and optionally add a credit card and cash account. |
| [Multi-account ledger](https://github.com/bhoopathyvm-cloud/smaraAccount/blob/main/openspec/specs/multi-account-ledger/spec.md) | Multiple asset and liability accounts, account groups, transfers between accounts, per-account balances and registers, and opening balances. |
| [Account currencies](https://github.com/bhoopathyvm-cloud/smaraAccount/blob/main/openspec/specs/account-currency/spec.md) | Each account group has its own currency; net worth is tracked per currency, with no forced conversion. |
| [Home overview](https://github.com/bhoopathyvm-cloud/smaraAccount/blob/main/openspec/specs/accounts-home-overview/spec.md) | The landing screen: every account (active and archived) with its balance, grouped, an overall net position, a single Add hub for Spent/Received/Moved money/Import, and this month's category totals. |
| [Split transactions](https://github.com/bhoopathyvm-cloud/smaraAccount/blob/main/openspec/specs/split-transactions/spec.md) | Spread one purchase across multiple categories with a running remainder, instead of squeezing it into one category or splitting it into separate entries. |
| [Recurring templates](https://github.com/bhoopathyvm-cloud/smaraAccount/blob/main/openspec/specs/recurring-templates/spec.md) | Define a repeating bill or paycheck once; a due template shows up on Home and is recorded with a single tap — never posted automatically. |
| [Payees](https://github.com/bhoopathyvm-cloud/smaraAccount/blob/main/openspec/specs/payees/spec.md) | Autocomplete on the description field that remembers a payee's usual category and account, always overridable, and updates itself from what you actually use. |
| [Monthly category limits](https://github.com/bhoopathyvm-cloud/smaraAccount/blob/main/openspec/specs/monthly-category-limits/spec.md) | An optional, purely informational month-to-date spending guide per expense category — never blocks recording a transaction. |
| [Credit card household flow](https://github.com/bhoopathyvm-cloud/smaraAccount/blob/main/openspec/specs/credit-card-household-flow/spec.md) | Flag a liability account as a credit card to get "Paid from card"/"Paid from bank" capture shortcuts and a pre-filled "Pay card" transfer — the account itself behaves like any other liability. |
| [Foreign-currency settlement](https://github.com/bhoopathyvm-cloud/smaraAccount/blob/main/openspec/specs/foreign-currency-settlement/spec.md) | Cross-currency transfers and foreign-currency transactions, posted at a known rate or provisionally and settled later. |
| [Reference exchange-rate lookup](https://github.com/bhoopathyvm-cloud/smaraAccount/blob/main/openspec/specs/reference-exchange-rate-lookup/spec.md) | An optional, off-by-default lookup showing a comparison exchange rate on cross-currency transfers — never used to fill in or validate an amount. |
| [Investment holdings](https://github.com/bhoopathyvm-cloud/smaraAccount/blob/main/openspec/specs/investment-holdings/spec.md) | An investment account as cash plus a lot-tracked instrument inventory: buy (including non-cash acquisitions), sell, dividends, and a labeled market-estimate valuation from background quotes — not a broker, no order routing. |
| [Investment research](https://github.com/bhoopathyvm-cloud/smaraAccount/blob/main/openspec/specs/investment-research-enablement/spec.md) | Tap a held instrument's name to open a pre-filled research prompt in your favourite consumer AI tool — no API integration, no in-app model call. |
| [Instrument identifier assist](https://github.com/bhoopathyvm-cloud/smaraAccount/blob/main/openspec/specs/instrument-identifier-assist/spec.md) | When adding an instrument: an identifier look-up prompt, offline ISIN validation, a currency-mismatch warning, a default-exchange setting, and a confirm-the-listing step so market quotes match the account's currency. |
| [Ledger integrity & signing](https://github.com/bhoopathyvm-cloud/smaraAccount/blob/main/openspec/specs/ledger-integrity-signing/spec.md) | Verified history for the user's books: each entry is signed and linked to the previous one, the app checks that chain on startup, and entries that no longer verify are shown as unverified instead of being trusted in totals. |
| [Correction (Fix) wizard](https://github.com/bhoopathyvm-cloud/smaraAccount/blob/main/openspec/specs/correction-wizard/spec.md) | A guided flow that corrects a posted transaction by pairing a reversal with a new corrected entry, so the original stays visible and history is never rewritten in place. |
| [Register search](https://github.com/bhoopathyvm-cloud/smaraAccount/blob/main/openspec/specs/register-search/spec.md) | Text search plus optional direction and date-range filters over an account's register, narrowing what's shown without ever changing what's posted. |
| [OFX statement import](https://github.com/bhoopathyvm-cloud/smaraAccount/blob/main/openspec/specs/ofx-transaction-import/spec.md) | Importing bank/credit-card history from OFX/QFX files, with duplicate detection and categorization before posting. |
| [CSV statement import](https://github.com/bhoopathyvm-cloud/smaraAccount/blob/main/openspec/specs/csv-transaction-import/spec.md) | Importing statement history from CSV files via an explicit, never-inferred column mapping, with reusable saved profiles. |
| [Import category rules](https://github.com/bhoopathyvm-cloud/smaraAccount/blob/main/openspec/specs/import-category-rules/spec.md) | Saved keyword-to-category rules and bulk categorization on the import preview screen, so a category assigned once keeps applying. |
| [Ledger data export](https://github.com/bhoopathyvm-cloud/smaraAccount/blob/main/openspec/specs/ledger-data-export/spec.md) | Export a chosen account's transactions for a date range to CSV, with each row's verification status, and never any signing-key material. |
| [Books Copy save & restore](https://github.com/bhoopathyvm-cloud/smaraAccount/blob/main/openspec/changes/books-copy-and-continuation/specs/books-copy/spec.md) | An encrypted, passphrase-protected copy of the books (never the private key). Restoring replaces rather than merges; device settings stay on the phone. |
| [App lock](https://github.com/bhoopathyvm-cloud/smaraAccount/blob/main/openspec/specs/app-lock/spec.md) | Optional PIN or device-biometric lock with an idle timeout and app-switcher snapshot hiding, so an unlocked or backgrounded device doesn't expose the ledger at a glance. |
| [Full app localization](https://github.com/bhoopathyvm-cloud/smaraAccount/blob/main/openspec/specs/app-localization/spec.md) | The app's interface, input, and error messages in dozens of languages spanning East Asian, European, global-major, and every major Indian language family — with money still formatted by each currency's own convention regardless of chosen language. |
| [Linux desktop](https://github.com/bhoopathyvm-cloud/smaraAccount/blob/main/openspec/specs/linux-desktop-platform/spec.md) | Linux is a real, CI-validated target alongside iOS, Android, and macOS — it builds, launches, onboards, and keeps its signing key in the desktop's secure storage. |
| [Privacy policy](https://github.com/bhoopathyvm-cloud/smaraAccount/blob/main/openspec/specs/privacy-policy-page/spec.md) | A plain-language privacy policy, linked from in-app Settings and the store listings, describing exactly what stays on the device and each network lookup. |
| [Shared UI components](https://github.com/bhoopathyvm-cloud/smaraAccount/blob/main/openspec/specs/shared-ui-components/spec.md) | A small set of reusable widgets — destructive-action confirmation, money entry, entity pickers, status banners — used consistently everywhere that shape of UI appears. |
| [User guide](https://github.com/bhoopathyvm-cloud/smaraAccount/blob/main/openspec/specs/user-guide/spec.md) | An accurate, end-user guide covering every shipped screen and flow, never describing planned-but-unbuilt functionality. |
| [Contributor guide](https://github.com/bhoopathyvm-cloud/smaraAccount/blob/main/openspec/specs/contributor-guide/spec.md) | The root-level entry point explaining how to propose and submit a contribution. |
| [Acceptance test suite](https://github.com/bhoopathyvm-cloud/smaraAccount/blob/main/openspec/specs/acceptance-test-suite/spec.md) | 37 end-to-end tests that drive a real, launched build of the app — real database, real OS keychain — run nightly on Linux in every supported language, plus a macOS baseline before each release. |

## Why The Integrity Feature Matters

For a normal user, the value is not the phrase "tamper-evident ledger."
The value is that financial history becomes harder to rewrite quietly.
If an old amount, date, description, or link in the history is changed
outside the app, the app can detect that the chain no longer matches and
keep that damaged part out of balances.

That helps when restoring a backup, checking whether a local database was
damaged, reviewing an old mistake, or exporting records for an accountant.
The app still cannot prove that a transaction was truthful when originally
entered; it can prove whether the stored history still matches what was
signed at the time.

This capability follows the same broad ideas behind accounting audit
trails and tamper-aware logs: keep enough chronological evidence to
reconstruct what happened, and protect that evidence from silent change.
For background, see [OpenStax on accounting audit trails](https://openstax.org/books/principles-financial-accounting/pages/7-1-define-and-describe-the-components-of-an-accounting-information-system),
[NIST's audit-trail definition](https://csrc.nist.gov/glossary/term/audit_trail),
and [OWASP's logging guidance](https://cheatsheetseries.owasp.org/cheatsheets/Logging_Cheat_Sheet.html).

This list reflects the specs under `openspec/specs/` as of when this
page was last updated by hand — see the
[repository](https://github.com/bhoopathyvm-cloud/smaraAccount/tree/main/openspec/specs)
for the current, authoritative list.

The [privacy policy](privacy-policy.md) is the public description of
on-device storage and the app's network lookups, kept in sync
with the iOS privacy manifest.
