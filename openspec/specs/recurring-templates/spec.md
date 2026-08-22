# recurring-templates

## Purpose

Let the user define recurring transaction templates (amount, category,
account, monthly schedule) and record a due one with a single tap,
never posting automatically without that tap.

## Requirements

### Requirement: Recurring Transaction Templates
The user SHALL define recurring templates with amount category account and monthly schedule. The system SHALL surface due templates for one-tap recording without auto-posting.

#### Scenario: Due template
- **WHEN** a monthly template is due today
- **THEN** Home shows a due item that records the transaction on tap
