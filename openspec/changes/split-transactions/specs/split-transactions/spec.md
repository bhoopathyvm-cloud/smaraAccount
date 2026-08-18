# split-transactions

## Purpose

Capability for split transactions.

## Requirements

### Requirement: Split a Transaction Across Categories
The user SHALL split one spent or received amount across multiple categories in a single action. The system SHALL post one journal entry with multiple category postings whose amounts sum to the transaction total.

#### Scenario: Split two categories
- **WHEN the user splits 100 into 60 Food and 40 Household**
- **THEN** one entry posts with both category legs

