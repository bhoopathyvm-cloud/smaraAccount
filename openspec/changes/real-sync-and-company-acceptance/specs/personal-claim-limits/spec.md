## Purpose

Lets a company give different people different allowances per expense category, shown as hints to the employee and the approver, without ever changing an amount automatically.

When `expense-claims` is archived into `openspec/specs/`, this capability SHOULD
be folded into that spec as a MODIFIED delta of "Spending-Limit Hints"
(`real-sync-and-company-acceptance` task 0.2). Until then it stays separate and
extends the company-wide limit hints already described there.

## ADDED Requirements

### Requirement: Owner Sets Limits per Person and Category
The Owner SHALL be able to set, change and clear a claim limit for a person and an allowed claim category, in the company currency, with an optional unit ("per night", "per day", "per item"). Changes SHALL sync as signed records like other claim settings, and SHALL apply to items decided after the change.

#### Scenario: Setting a personal hotel limit
- **WHEN** the Owner opens People → Ravi → Claim limits and sets Hotel to 120 per night
- **THEN** Ravi's limit list shows "Hotel 120 per night", and the setting reaches the accountant's and Ravi's devices on the next sync

### Requirement: A Personal Limit Replaces the Company Hint for That Person
For a given person and category, a personal limit SHALL be the one shown, in place of the company-wide limit for that category. Where a person has no personal limit, the company-wide limit SHALL apply. Where neither exists, no hint SHALL be shown.

#### Scenario: Personal limit lower than the company limit
- **WHEN** the company Hotel limit is 150 and Ravi's personal Hotel limit is 120
- **THEN** Ravi and the accountant see "Limit 120 per night" on Ravi's hotel items

#### Scenario: Personal limit higher than the company limit
- **WHEN** the company Hotel limit is 150 and Mia's personal Hotel limit is 200
- **THEN** a 190 hotel item from Mia shows no "above the limit" warning

#### Scenario: No personal limit
- **WHEN** Kenji has no personal limits
- **THEN** his hotel items show the company limit of 150

### Requirement: Limits Stay Hints
A personal limit SHALL be shown to the Claimant while entering an item and to the Approver while deciding it, including "Above the <limit> limit" when exceeded. It SHALL NOT block saving or submitting an item, and SHALL NOT change any amount; only the Approver's decision changes what is approved.

#### Scenario: Above a personal limit
- **WHEN** Ravi enters a hotel item worth 210 EUR where his limit is 120
- **THEN** the app shows "Above the 120 limit", saves 210, and the accountant decides the amount

### Requirement: A Claimant Sees Only Their Own Limits
A Claimant's device SHALL receive and show only that person's own limits and the company-wide limits, never another person's personal limits.

#### Scenario: Limits of others stay hidden
- **WHEN** Ravi opens his claim limits
- **THEN** he sees his Hotel 120 and the company limits, and nothing about Mia's Hotel 200
