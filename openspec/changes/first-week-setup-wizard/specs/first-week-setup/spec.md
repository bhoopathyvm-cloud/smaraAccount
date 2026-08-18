# first-week-setup

## Purpose

Capability for first week setup wizard.

## Requirements

### Requirement: First-Week Setup Wizard
After onboarding the system SHALL offer a short wizard to name the user's main bank account optionally add credit card and cash accounts and expand starter categories. Empty account groups SHALL not dominate the home overview.

#### Scenario: Wizard creates card
- **WHEN the user says they have a credit card**
- **THEN** a liability account is created in the credit group with a user-chosen name

