## MODIFIED Requirements

### Requirement: User Guide Covers Every Shipped Feature
The repository SHALL contain a user guide at `docs/user-guide.md` that documents, in end-user terms using the household term map (Spent, Received, Fix, account, Moved money) rather than debit, credit, journal, or ledger vocabulary, every screen and flow currently reachable in the app, with money amounts shown throughout using each amount's own currency formatting conventions (grouping, decimal separator, minor-unit digits): onboarding (choosing New Setup or Import From Backup at startup; New Setup guides naming a first account and recording one transaction, with no recovery-phrase step blocking anything afterward), the first-week setup wizard (naming a main account, optionally adding a credit card and cash account), setting the base currency, the Settings backup section (viewing the recovery phrase, exporting an optional keystore file, and exporting a device migration bundle — a single passphrase-protected file combining the ledger data and the signing key for moving to a new device in one step — all optional and reachable at any time, none of them required to keep using the app), restoring the ledger on a new device via Import From Backup (a device migration bundle) or, separately, via a saved recovery phrase or keystore file, backing up and restoring the full ledger (an encrypted file the user chooses a location for, distinct from the recovery phrase/keystore/bundle, which restore identity only or identity-plus-data), the home screen (the Add hub for Spent/Received/Moved money/Import, and this month's category totals), recording a transaction (including splitting one amount across multiple categories and that fixing/reversing a split reverses every category line at once, and payee autocomplete with remembered category/account defaults), recurring templates (creating one, and recording a due template with one tap — never posted automatically without that tap), managing categories (including restoring an archived one, setting an optional monthly spending limit and reading month-to-date progress, and the expanded starter category set), managing accounts and account groups (including multi-currency accounts, credit-card-flagged liability accounts, and restoring an archived account or group), investment accounts (cash in/out, buy including a non-cash/employer-match acquisition and an optional lock-until date, sell, dividends, background market quotes as a labeled estimate, unrealized gain/loss, and that archiving allows a repeatable cash closeout while sell and dividend stay available), transferring between accounts (same-currency and cross-currency, upfront fees, deducted-fee mode, pending/settlement), paying down a credit card (a labeled transfer), importing bank statements (OFX and CSV, column mapping, saved import profiles, keyword-to-category import rules and group assignment on preview, and linking a saved rule to a payee), exporting transactions to CSV for a chosen account and date range, the register and running balance (including searching by text and filtering by date range or direction, and fixing a mistaken entry via the Fix flow, which posts a reversal and a corrected replacement rather than editing the original), the summary screen, settings (language: same as the phone vs pick a language; reference exchange rate lookup and provider selection), and the optional app lock (PIN or device biometrics, idle timeout, and app-switcher snapshot hiding). The guide SHALL also document that recovery words stay English, that notes the user typed and names they changed are not translated, that switching the app language does not change how a given currency amount is formatted (ISO codes such as USD remain), and that the phone's spoken screen reader usually follows the phone's language, not the in-app choice. The guide SHALL NOT describe planned or proposed functionality that has not shipped. The guide SHALL NOT teach debit, credit, journal, or ledger vocabulary.

#### Scenario: Every current route has corresponding guide content
- **WHEN** a screen or flow is reachable via `lib/ui/app_router.dart` in the current codebase
- **THEN** the user guide contains a section describing how and why a user would use it

#### Scenario: Unshipped functionality is not documented as real
- **WHEN** the user guide is written
- **THEN** it does not describe any feature that exists only as an OpenSpec proposal not yet implemented

#### Scenario: Import category rules are documented
- **WHEN** a user reads the importing-bank-statements section of the user guide
- **THEN** it explains saved keyword-to-category rules, group assignment on the preview screen, and that a matching rule is suggested before an exact-memo match

#### Scenario: Onboarding order is documented accurately
- **WHEN** a user reads the onboarding section of the user guide
- **THEN** it describes the New Setup vs Import From Backup choice at startup, that New Setup guides naming a first account and recording one transaction, and that nothing blocks further use of the app afterward — the recovery phrase, keystore export, and device migration bundle are all optional and found later in Settings

#### Scenario: First-week wizard is documented
- **WHEN** a user reads the onboarding section of the user guide
- **THEN** it explains the first-week setup wizard's optional steps and that they can be skipped

#### Scenario: Backup and restore are documented, distinctly from identity restore
- **WHEN** a user reads the settings section of the user guide
- **THEN** it explains ledger backup/restore (data only), the recovery phrase and keystore export (identity only), and the device migration bundle (identity and data together, for moving to a new device in one step) as three distinct, optional mechanisms, and that restore/import always replaces rather than merges

#### Scenario: Home Add hub is documented
- **WHEN** a user reads the home screen section of the user guide
- **THEN** it explains the Add action's choices and the this-month category totals section

#### Scenario: Splitting a transaction is documented
- **WHEN** a user reads the recording-a-transaction section of the user guide
- **THEN** it explains adding category lines, the running remainder, and that reversing a split reverses every line together

#### Scenario: Payees are documented
- **WHEN** a user reads the recording-a-transaction section of the user guide
- **THEN** it explains payee autocomplete, remembered defaults, and that suggestions are always overridable

#### Scenario: Recurring templates are documented
- **WHEN** a user reads the recording-a-transaction section of the user guide
- **THEN** it explains creating a recurring template and that a due template is only recorded when the user taps it, never automatically

#### Scenario: Unarchiving is documented
- **WHEN** a user reads the accounts or categories section of the user guide
- **THEN** it explains restoring an archived item, that unarchiving an account also restores its archived group if needed, and that this doesn't reverse a prior closeout

#### Scenario: Monthly limits are documented
- **WHEN** a user reads the categories section of the user guide
- **THEN** it explains setting a monthly limit, that progress is informational, and that exceeding it never blocks recording a transaction

#### Scenario: Credit card flow is documented
- **WHEN** a user reads the accounts section of the user guide
- **THEN** it explains marking a liability account as a credit card, the "Paid from card" capture shortcut, and that "Pay card" is an ordinary transfer to the card

#### Scenario: CSV export is documented
- **WHEN** a user reads the register or settings section of the user guide
- **THEN** it explains exporting a date range and account to CSV, and that signing keys are never included

#### Scenario: Register search is documented
- **WHEN** a user reads the register section of the user guide
- **THEN** it explains the search box and the optional date-range and direction filters

#### Scenario: Fix flow is documented
- **WHEN** a user reads the register section of the user guide
- **THEN** it explains tapping Fix on a row, that it posts a reversal plus a corrected entry, and that the original entry stays visible unchanged

#### Scenario: Currency formatting is mentioned where amounts first appear
- **WHEN** a user reads the recording-a-transaction section of the user guide
- **THEN** it notes that amounts display and accept input using the transaction's own currency's formatting, not a fixed period-and-two-decimals style

#### Scenario: App lock is documented
- **WHEN** a user reads the settings section of the user guide
- **THEN** it explains how to enable app lock, choose PIN or biometrics, set the idle timeout, and what snapshot hiding does (and on which platforms it's available)

#### Scenario: Language setting is documented when reachable
- **WHEN** the language list is reachable in Settings
- **THEN** the user guide explains same-as-the-phone vs picking a language, that switching updates the running app, and what is not translated (typed notes, recovery words, how money looks in this version)

#### Scenario: Guide uses household vocabulary throughout
- **WHEN** a user reads any section of the user guide
- **THEN** it uses the household term map's vocabulary (Spent/Received, Fix, account, Moved money) rather than debit/credit, journal entry, or "reverse"

#### Scenario: Investment accounts are documented
- **WHEN** a user reads the investment-accounts section of the user guide
- **THEN** it explains cash in/out, buy (including a non-cash acquisition example and lock-until), sell, dividends, that quoted prices are a labeled market estimate not the signed book, and that archiving still allows selling down and closing out cash
- **AND** it does not describe order placement, broker connectivity, or any dealing capability the app does not have

### Requirement: User Guide Explains the Signing-Key Tradeoff
The user guide SHALL clearly explain, before or alongside the Settings backup instructions, that the device signing key cannot be recovered if lost, what a lost key means in practice (all entries must be re-created from scratch, or migrated forward with their original-verification status marked historical), and the three ways to preserve access to an existing identity (the recovery phrase, the optional keystore export, and the device migration bundle) — consistent with the tradeoff already stated in `README.md`. The guide SHALL make clear that none of these three is required to keep using the app.

#### Scenario: Guide states the consequence of a lost key before the user needs it
- **WHEN** a user reads the Settings backup section of the user guide
- **THEN** it explains, before describing how to use the backup screens, that losing all of the recovery phrase, keystore, and device migration bundle means permanent loss of the signing identity

#### Scenario: Guide explains both backup mechanisms
- **WHEN** a user reads the Settings backup section of the user guide
- **THEN** it describes the recovery phrase, the optional keystore export, and the device migration bundle, when each is used to restore access, and that the bundle alone is sufficient to move to a new device with no separate data restore needed
