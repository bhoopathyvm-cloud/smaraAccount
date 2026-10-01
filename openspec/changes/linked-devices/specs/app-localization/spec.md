## MODIFIED Requirements

### Requirement: System Default Names Display Localized When Unchanged
System-seeded account group and category names that still match their original seeded English defaults SHALL be displayed using localized labels when available. User-typed or renamed category names SHALL be shown using the translation for the active locale when one exists (see `category-translations`), and otherwise exactly as stored in the books' default category language. Other user-renamed values SHALL be shown exactly as stored.

#### Scenario: Unchanged system group name
- **WHEN** a system group still has its seeded default name and a localization key exists for it
- **THEN** the UI shows the localized label for the active locale

#### Scenario: User-renamed account or category
- **WHEN** the stored name differs from the seeded default and no translation exists for the active locale
- **THEN** the UI shows the stored name without translation

#### Scenario: Translated category name
- **WHEN** a renamed category has a translation for the active locale
- **THEN** the UI shows that translation
