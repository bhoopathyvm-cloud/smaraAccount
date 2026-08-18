## MODIFIED Requirements

### Requirement: Save a Category Rule From a Group Assignment
When the user assigns a category to a group, the system SHALL offer to save that assignment as a named category rule: a keyword and the assigned category. For a multi-row group, the keyword SHALL default to the group's shared (normalized) description, editable before saving. For a single-row group, the user SHALL supply the keyword explicitly, since a single row's full description is a poor default keyword. Saving a rule is optional and separate from the category assignment itself — assigning a category to a group without choosing to save SHALL only affect rows in the current import. When saving a rule, the system SHALL additionally offer to link or create a payee (from the `payees` capability, when present) using the rule's keyword as the payee name and the rule's category as that payee's default category; declining this leaves the rule exactly as it would without the `payees` capability.

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

#### Scenario: Saving a rule offers to link a payee too
- **WHEN** the user saves a category rule from a group assignment and the `payees` capability is present
- **THEN** the save dialog offers to also create or link a payee named after the rule's keyword, defaulting to the rule's category
- **AND** declining that offer still saves the rule exactly as it would without this option
