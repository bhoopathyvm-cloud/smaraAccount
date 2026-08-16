# ofx-transaction-import

## Purpose

Import bank/credit-card statement history from user-supplied OFX 1.x/2.x
(`.ofx`/`.qfx`) files: parse, match to an existing financial account,
preview with duplicate detection and categorization, and post accepted
rows through the same path as manual entry. (Purpose derived from the
`ofx-transaction-import` change; refine as the capability evolves.)

## Requirements

### Requirement: Parse OFX Statement Files
The system SHALL parse user-supplied OFX 1.x and OFX 2.x files containing bank (`STMTTRN`) or credit-card (`CCSTMTTRN`) statement transactions into a normalized list of parsed transactions, each with a transaction date, an amount (with direction), a payee/memo description, the file's statement currency, and the bank's transaction id (`FITID`) when present. Investment transaction aggregates (e.g. `INVSTMTTRN`) SHALL be ignored. A transaction row that cannot be parsed SHALL be reported to the user as a skipped row with a reason, and SHALL NOT abort parsing of the remaining file.

#### Scenario: Parse an OFX 2.x (XML) file
- **WHEN** the user selects a well-formed OFX 2.x file containing bank statement transactions
- **THEN** the system produces a parsed transaction for each `STMTTRN`/`CCSTMTTRN` entry with its date, amount, description, and `FITID`

#### Scenario: Parse an OFX 1.x (SGML-style) file
- **WHEN** the user selects an OFX 1.x file whose tags are not XML-closed
- **THEN** the system parses it into the same normalized transaction list as an equivalent OFX 2.x file

#### Scenario: Unparseable file is rejected
- **WHEN** the user selects a file that is not a recognizable OFX document
- **THEN** the system rejects the import before offering any account matching or preview step, and explains that the file could not be recognized as OFX

#### Scenario: Investment transactions are ignored
- **WHEN** a selected file contains investment transaction aggregates alongside bank statement transactions
- **THEN** the system parses only the bank/credit-card statement transactions and silently omits the investment ones from the parsed result

#### Scenario: A malformed row does not abort the file
- **WHEN** one transaction row within an otherwise-parseable file is missing a required field (e.g. no amount)
- **THEN** that row is reported to the user as skipped with a reason
- **AND** all other valid rows in the file still parse normally

### Requirement: Match Import to a Financial Account
Before previewing parsed transactions, the user SHALL select which existing, active financial account the file's transactions apply to. The system SHALL NOT attempt to automatically determine the target account from the file's contents. If the import was started from an account's register, that account SHALL be pre-selected as the default target. When the file's statement currency (`CURDEF`) differs from the selected account's group currency, the system SHALL warn the user before proceeding to preview, but SHALL NOT block the import.

#### Scenario: User selects the target account
- **WHEN** the user has parsed a file and no account was pre-selected
- **THEN** the system requires the user to choose one active financial account before showing the preview

#### Scenario: Register-launched import pre-selects the viewed account
- **WHEN** the user starts an OFX import from an active financial account's register
- **THEN** that account is pre-selected as the import target, and the user may change it before proceeding

#### Scenario: Archived accounts are not offered as an import target
- **WHEN** the user is choosing the target account for an import
- **THEN** archived financial accounts do not appear in the selection

#### Scenario: Currency mismatch is a warning, not a block
- **WHEN** the file's statement currency differs from the selected account's group currency
- **THEN** the system displays a warning identifying the mismatch
- **AND** still allows the user to proceed to preview and posting

### Requirement: Preview and Duplicate Detection Before Posting
The system SHALL show the user a preview of all successfully parsed transactions for the chosen account before posting any of them. Each previously-imported transaction, identified by a matching `FITID` already recorded for that financial account, or, when `FITID` is absent, by a matching combination of date, amount, and memo, SHALL be flagged as a possible duplicate and excluded from the default posting selection. The user SHALL be able to deselect any row, and SHALL be able to force-include a flagged duplicate row.

#### Scenario: Prior FITID is flagged and excluded by default
- **WHEN** a parsed transaction's `FITID` matches one already recorded as imported for the selected financial account
- **THEN** the preview flags that row as a possible duplicate
- **AND** the row is not selected for posting by default

#### Scenario: User forces a flagged duplicate to be included
- **WHEN** the user explicitly re-selects a row flagged as a possible duplicate
- **THEN** that row is included in the postable set despite the flag

#### Scenario: Fallback duplicate match without FITID
- **WHEN** a parsed transaction has no `FITID` and its date, amount, and memo match a transaction already imported for the selected financial account
- **THEN** the preview flags that row as a possible duplicate using the same default-exclusion behavior as an FITID match

#### Scenario: User deselects a row
- **WHEN** the user deselects a previewed row that is not flagged as a duplicate
- **THEN** that row is excluded from posting when the user confirms the import

### Requirement: Categorize Rows Before Posting
Every row the user intends to post SHALL have a category selected before it can post. The system SHALL suggest a category for each row using the following priority: first, a saved category rule (see `import-category-rules`) whose keyword matches the row's description, if any; otherwise, the last category used for an exact-memo match previously posted (manually or via import) to the selected financial account, when one exists. Neither suggestion requires the user to accept it. A row with no category selected SHALL be excluded from the postable set without blocking the rest of the batch.

#### Scenario: Suggested category from a matching saved rule takes priority
- **WHEN** a previewed row's description matches a saved category rule's keyword, and that row's memo also exactly matches a prior posted transaction with a different category
- **THEN** the preview pre-fills that row's category from the matching saved rule, not from the exact-memo match

#### Scenario: Suggested category from a prior exact-memo match
- **WHEN** a previewed row's memo exactly matches the memo of a transaction previously posted to the same financial account, and no saved category rule matches that row's description
- **THEN** the preview pre-fills that row's category with the category used for the prior match

#### Scenario: User overrides the suggested category
- **WHEN** the user changes the pre-filled category for a previewed row
- **THEN** the row posts, if selected, using the category the user chose

#### Scenario: Uncategorized row is excluded, not blocking
- **WHEN** the user confirms the import while a selected row has no category assigned
- **THEN** that row is excluded from posting and reported as skipped
- **AND** all other categorized, selected rows still post

### Requirement: Post Accepted Rows as Ordinary Journal Entries
Each accepted, categorized, selected row SHALL post as one ordinary transaction through the same recording path used for manual entry, following all existing validation and currency-handling rules of the `core-ledger-single-account` and `multi-account-ledger` capabilities. Posting SHALL proceed row by row: a failure posting one row SHALL NOT prevent posting of the other accepted rows in the batch. After posting completes, the system SHALL report per-row success or failure, and SHALL record the posted rows' `FITID` (or fallback match key) against the target financial account so future imports can detect them as duplicates.

#### Scenario: Accepted rows post as ordinary transactions
- **WHEN** the user confirms an import with one or more accepted, categorized rows
- **THEN** each row posts as a journal entry indistinguishable in the ledger from a manually entered transaction
- **AND** each posted row's `FITID` (or fallback match key) is recorded against the target account for future duplicate detection

#### Scenario: One row's posting failure does not block the batch
- **WHEN** posting an accepted row fails (e.g. a validation error)
- **THEN** the system continues posting the remaining accepted rows
- **AND** reports which rows failed and why once posting completes

#### Scenario: Excluded and skipped rows are never posted or recorded
- **WHEN** posting completes
- **THEN** rows that were deselected, uncategorized, or unparseable are neither posted as journal entries nor recorded as imported for future duplicate detection
