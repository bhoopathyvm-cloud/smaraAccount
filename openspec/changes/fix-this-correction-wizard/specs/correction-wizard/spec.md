
## Purpose

Capability for fix this correction wizard.

## ADDED Requirements

### Requirement: Fix a Posted Transaction
The user SHALL correct a posted transaction via a Fix flow that posts a reversal of the original entry and a new entry with the corrected fields. The original entry SHALL remain visible and unchanged.

#### Scenario: Fix changes category
- **WHEN the user fixes a posted entry to a different category**
- **THEN** the system posts a reversal and a new entry with the new category AND the original entry remains visible

#### Scenario: Fix is not silent edit
- **WHEN the user completes a fix**
- **THEN** no posted entry is modified in place

