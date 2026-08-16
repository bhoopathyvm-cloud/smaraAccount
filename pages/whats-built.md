# What's built

Every capability below exists because a spec was written for it first,
implemented against that spec, and archived once done — the concrete
result of the [spec-driven approach](how-it-was-built.md). Each entry
links to its current spec in the repository, the precise, testable
statement of what that capability does today.

| Capability | What it does |
|---|---|
| [Core ledger](https://github.com/bhoopathyvm-cloud/smaraAccount/blob/main/openspec/specs/core-ledger-single-account/spec.md) | The foundational double-entry ledger: recording transactions without picking debit/credit sides, immutable posted entries (corrections via reversal, never edits), a running register, and an income/expense summary. |
| [Multi-account ledger](https://github.com/bhoopathyvm-cloud/smaraAccount/blob/main/openspec/specs/multi-account-ledger/spec.md) | Multiple asset and liability accounts, account groups, transfers between accounts, per-account balances and registers, and opening balances. |
| [Account currencies](https://github.com/bhoopathyvm-cloud/smaraAccount/blob/main/openspec/specs/account-currency/spec.md) | Each account group has its own currency; net worth is tracked per currency, with no forced conversion. |
| [Home overview](https://github.com/bhoopathyvm-cloud/smaraAccount/blob/main/openspec/specs/accounts-home-overview/spec.md) | The landing screen: every account (active and archived) with its balance, grouped, plus an overall net position. |
| [Foreign-currency settlement](https://github.com/bhoopathyvm-cloud/smaraAccount/blob/main/openspec/specs/foreign-currency-settlement/spec.md) | Cross-currency transfers and foreign-currency transactions, posted at a known rate or provisionally and settled later. |
| [Reference exchange-rate lookup](https://github.com/bhoopathyvm-cloud/smaraAccount/blob/main/openspec/specs/reference-exchange-rate-lookup/spec.md) | An optional, off-by-default lookup showing a comparison exchange rate on cross-currency transfers — never used to fill in or validate an amount. |
| [Ledger integrity & signing](https://github.com/bhoopathyvm-cloud/smaraAccount/blob/main/openspec/specs/ledger-integrity-signing/spec.md) | The device signing identity, hash-chained signed entries, startup integrity verification, and recovery or migration after a lost key. |
| [OFX statement import](https://github.com/bhoopathyvm-cloud/smaraAccount/blob/main/openspec/specs/ofx-transaction-import/spec.md) | Importing bank/credit-card history from OFX/QFX files, with duplicate detection and categorization before posting. |
| [CSV statement import](https://github.com/bhoopathyvm-cloud/smaraAccount/blob/main/openspec/specs/csv-transaction-import/spec.md) | Importing statement history from CSV files via an explicit, never-inferred column mapping, with reusable saved profiles. |
| [Import category rules](https://github.com/bhoopathyvm-cloud/smaraAccount/blob/main/openspec/specs/import-category-rules/spec.md) | Saved keyword-to-category rules and bulk categorization on the import preview screen, so a category assigned once keeps applying. |
| [Shared UI components](https://github.com/bhoopathyvm-cloud/smaraAccount/blob/main/openspec/specs/shared-ui-components/spec.md) | A small set of reusable widgets — destructive-action confirmation, money entry, entity pickers, status banners — used consistently everywhere that shape of UI appears. |
| [User guide](https://github.com/bhoopathyvm-cloud/smaraAccount/blob/main/openspec/specs/user-guide/spec.md) | An accurate, end-user guide covering every shipped screen and flow, never describing planned-but-unbuilt functionality. |
| [Contributor guide](https://github.com/bhoopathyvm-cloud/smaraAccount/blob/main/openspec/specs/contributor-guide/spec.md) | The root-level entry point explaining how to propose and submit a contribution. |

This list reflects the specs under `openspec/specs/` as of when this
page was last updated by hand — see the
[repository](https://github.com/bhoopathyvm-cloud/smaraAccount/tree/main/openspec/specs)
for the current, authoritative list.
