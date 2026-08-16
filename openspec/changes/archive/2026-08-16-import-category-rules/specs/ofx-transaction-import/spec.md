## MODIFIED Requirements

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
