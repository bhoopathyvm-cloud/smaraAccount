## Purpose

Keep one shared category catalog across Linked devices and languages:
default names, optional translations, AI-assisted translate handoff, merge
of duplicates, and a joining device that skips starter categories.

## ADDED Requirements

### Requirement: Shared Categories With Default Language
Shared books SHALL carry a default language for category names plus optional translations per language. A device SHALL show its app-language translation when present, otherwise the default-language name. Categories themselves are shared books data, not per-device settings.

#### Scenario: Device shows translation when available
- **WHEN** a category has a default English name and a German translation, and the device's app language is German
- **THEN** category lists and pickers show the German name

#### Scenario: Fallback to default language
- **WHEN** a category has no translation for the device's app language
- **THEN** the default-language name is shown

### Requirement: Anyone Can Add a Translation
Any Member or Owner SHALL be able to add or edit a translation for a category at any time. Typed or renamed names SHALL show exactly as typed until someone adds a translation for another language.

#### Scenario: New translation syncs with books
- **WHEN** a user adds a French translation for a category and devices sync
- **THEN** other linked devices receive that translation as shared books data

#### Scenario: Untouched typed name stays as typed
- **WHEN** a user renames a category in the default language and no other translations exist yet
- **THEN** every device shows exactly the typed name until translations are added

### Requirement: Translate With AI Like the Research Tool
The system SHALL offer a "translate with AI" link that hands only the category word (or short phrase) to the person's chosen Research Tool in the browser or clipboard, the same way Instrument research works today. It SHALL NOT upload the ledger, amounts, or other category rows.

#### Scenario: Only the word is handed off
- **WHEN** the user taps "translate with AI" on a category name
- **THEN** only that name text is placed in the Research Tool prompt or clipboard
- **AND** no amounts, accounts, or other ledger data are included

### Requirement: Duplicate Categories Merge
Categories with the same name and type in any language SHALL merge automatically into one shared category. When a new translation matches another category's name, the system SHALL suggest a merge. A manual "Merge categories" action SHALL exist. Merged categories SHALL show as one in lists and totals; existing journal entries SHALL keep their original category links so signatures stay valid.

#### Scenario: Same name and type merge automatically
- **WHEN** two expense categories share the same display name in any language after a sync
- **THEN** they are merged into one category in lists and totals
- **AND** existing entries still point at their original category ids for verification

#### Scenario: Translation match suggests merge
- **WHEN** a user adds a translation whose text matches another category's name of the same type
- **THEN** the app suggests merging those categories

#### Scenario: Manual merge
- **WHEN** the user chooses "Merge categories" and picks two categories of the same type
- **THEN** lists and totals treat them as one
- **AND** posted entries are not rewritten

### Requirement: Joining Device Skips Starter Categories
A device that joins existing books (via QR or approved join request) SHALL NOT create the New-setup starter category set. It SHALL use the categories already present in the books it receives.

#### Scenario: Join does not seed starters
- **WHEN** a blank or newly continued device completes Add a device into books that already have categories
- **THEN** those books' categories are used
- **AND** the standard starter categories are not added as duplicates
