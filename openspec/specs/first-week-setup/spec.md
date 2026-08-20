# first-week-setup

## Purpose

A short post-onboarding wizard that guides a new user to name their main
bank account and optionally add a credit card and/or cash account, using
account creation the app already supports.

## Requirements

### Requirement: First-Week Setup Wizard
After onboarding completes, the system SHALL offer a short wizard that guides the user to name their main financial account and optionally create a credit card account and a cash account, each created via the existing financial-account creation path with no new validation.

#### Scenario: Wizard names the main account
- **WHEN** the user completes the wizard with a name for their main account
- **THEN** an asset financial account with that name exists in the appropriate group

#### Scenario: Wizard creates a card
- **WHEN** the user says they have a credit card
- **THEN** a liability account is created in the credit group with a user-chosen name

#### Scenario: Wizard is skippable
- **WHEN** the user declines the optional credit card or cash account steps
- **THEN** the wizard completes without creating those accounts, leaving only the main account created
