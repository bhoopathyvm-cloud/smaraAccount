## Purpose

Let linked devices that use different app languages share one set of categories: a default language for names, optional translations per language, and safe merging of duplicates.

## ADDED Requirements

### Requirement: Default Category Language and Translations
A set of books SHALL have a default language for category names. Each category name typed or renamed by a person SHALL be stored in that default language, and MAY have a translation for any other app language. A device SHALL show the translation for its app language when one exists, and otherwise the default-language name. Starter categories that were never renamed SHALL keep showing in each device's own language.

#### Scenario: A translated category
- **WHEN** a category "Kids" in default-language English has the German translation "Kinder"
- **THEN** a device set to German shows "Kinder" and a device set to English shows "Kids"

#### Scenario: No translation yet
- **WHEN** a device set to Hindi shows a category with no Hindi translation
- **THEN** it shows the default-language name

### Requirement: Adding a Translation
Any member SHALL be able to add or change a category's translation for their device's language at any time. The screen SHALL offer a "translate with AI" link that opens the person's chosen AI tool in the browser with only that category name and the target language, and nothing else from the books.

#### Scenario: Translation with help
- **WHEN** a member taps "translate with AI" for "Tiffin" into German
- **THEN** the browser opens the chosen AI tool with only "Tiffin" and "German", and the member types the translation they accept

### Requirement: Merging Duplicate Categories
Categories with the same type whose names are identical in any language SHALL be merged automatically after syncing. When a new translation matches another category's name or translation, the system SHALL suggest merging them. A member SHALL be able to merge two categories of the same type by hand. Merged categories SHALL show as one in every list and total, and every record SHALL keep its original category link so its signature stays valid.

#### Scenario: Identical names merge automatically
- **WHEN** "Kids" is created as an Expense category on two devices before they sync
- **THEN** after syncing, one "Kids" category appears and both devices' entries count towards it

#### Scenario: A translation suggests a merge
- **WHEN** a member adds the German translation "Kinder" to "Kids" while an Expense category "Kinder" exists
- **THEN** the app suggests merging "Kids" and "Kinder"

#### Scenario: Signatures survive a merge
- **WHEN** two categories are merged and the books are verified
- **THEN** every entry still verifies, and totals combine both categories
