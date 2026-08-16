# import-category-rules

## Purpose

Store, match, and manage user-defined keyword-to-category rules, and the
grouped-row bulk-categorization interaction on the statement-import
preview screen, so a category assigned once to a counterparty applies to
that counterparty in every future import. (Purpose derived from the
`import-category-rules` change; refine as the capability evolves.)

## Requirements

### Requirement: Group Preview Rows by Matching Description
On the statement-import preview screen, the system SHALL group rows whose description is identical after trimming whitespace and case-folding, and SHALL let the user assign a category to an entire group in one action. A group of a single row SHALL be assignable the same way as a multi-row group. Assigning a category to a group SHALL set that category on every row currently in the group; it SHALL NOT retroactively affect rows added to the preview afterward.

#### Scenario: Rows with identical descriptions are grouped
- **WHEN** the preview contains multiple rows whose descriptions are identical after trimming and case-folding
- **THEN** those rows are shown grouped together on the preview screen

#### Scenario: Assigning a category to a group sets it on every row in the group
- **WHEN** the user assigns a category to a group of rows
- **THEN** every row in that group is pre-filled with the assigned category
- **AND** each row's category remains individually editable afterward

#### Scenario: A row with a unique description is still bulk-assignable
- **WHEN** a row's description does not match any other previewed row
- **THEN** the user can still assign it a category using the same group-assignment action, as a group of one

### Requirement: Save a Category Rule From a Group Assignment
When the user assigns a category to a group, the system SHALL offer to save that assignment as a named category rule: a keyword and the assigned category. For a multi-row group, the keyword SHALL default to the group's shared (normalized) description, editable before saving. For a single-row group, the user SHALL supply the keyword explicitly, since a single row's full description is a poor default keyword. Saving a rule is optional and separate from the category assignment itself — assigning a category to a group without choosing to save SHALL only affect rows in the current import.

#### Scenario: Saving a rule from a multi-row group pre-fills the keyword
- **WHEN** the user assigns a category to a multi-row group and chooses to save it as a rule
- **THEN** the keyword field defaults to the group's shared normalized description, which the user may edit before saving

#### Scenario: Saving a rule from a single-row group requires an explicit keyword
- **WHEN** the user assigns a category to a single-row group and chooses to save it as a rule
- **THEN** the user must supply a keyword before the rule can be saved

#### Scenario: Declining to save only affects the current import
- **WHEN** the user assigns a category to a group without choosing to save it as a rule
- **THEN** the assignment applies to the current preview's rows only
- **AND** no rule is created

### Requirement: Saved Category Rules Auto-Apply During Preview
When building the preview for a new import (OFX or CSV), the system SHALL check each row's description against all saved category rules' keywords (case-insensitive substring match) and pre-fill the category from a matching rule, per the priority defined in `ofx-transaction-import`'s "Categorize Rows Before Posting" requirement. Saved rules SHALL apply across all financial accounts, regardless of which account a rule was originally created from. When more than one saved rule matches the same row, the most recently created matching rule SHALL be used.

#### Scenario: A saved rule matches a new import's row
- **WHEN** a new import's row description contains a saved rule's keyword (case-insensitive)
- **THEN** that row is pre-filled with the rule's category before the user makes any manual assignment

#### Scenario: Saved rules apply regardless of which account is being imported into
- **WHEN** a saved rule was created while categorizing an import for one financial account
- **THEN** that rule still matches and pre-fills categories for imports into a different financial account

#### Scenario: Multiple matching rules resolve to the most recently created
- **WHEN** a row's description matches the keywords of more than one saved category rule
- **THEN** the category from the most recently created matching rule is used

### Requirement: Manage Saved Category Rules
The user SHALL be able to view all saved category rules, edit a rule's keyword or category, and delete a rule. A deleted or edited rule SHALL take effect on the next preview built after the change; it SHALL NOT retroactively change categories already posted or already shown in an in-progress preview.

#### Scenario: View saved rules
- **WHEN** the user opens category rule management
- **THEN** every saved rule is listed with its keyword and assigned category

#### Scenario: Edit a rule's keyword or category
- **WHEN** the user edits a saved rule's keyword or category and saves the change
- **THEN** subsequent previews match and categorize using the updated rule

#### Scenario: Delete a rule
- **WHEN** the user deletes a saved rule
- **THEN** it no longer matches or pre-fills categories for any future preview
- **AND** transactions already posted using that rule's prior suggestions are unaffected
