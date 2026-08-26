## ADDED Requirements

### Requirement: A public privacy policy page exists and describes actual data handling
The project website SHALL contain a privacy policy page describing, in plain language: that there is no server or account, what is stored on-device and where, each opt-in network call and exactly what data it sends, how biometric unlock is handled, what a backup or CSV export file contains, and a contact point for privacy questions. It SHALL NOT describe data handling the app doesn't actually do.

#### Scenario: Policy covers every actual data flow
- **WHEN** a visitor reads the privacy policy page
- **THEN** it accounts for the signing key, the local ledger database, the reference-exchange-rate lookup, the investment quote lookup, biometric unlock, and backup/export file contents

#### Scenario: Policy does not overclaim or underclaim
- **WHEN** the policy is compared against `ios-privacy-compliance`'s manifest and export-compliance declarations
- **THEN** neither describes a data flow the other doesn't also account for

### Requirement: The policy is reachable from both the website and in-app Settings
A user SHALL be able to reach the privacy policy from the public website (for store-listing links) and from within the app's Settings screen, without the two ever pointing at different documents.

#### Scenario: In-app Settings links to the same live page
- **WHEN** a user taps "Privacy Policy" in Settings
- **THEN** their default browser opens the same URL used as the store-listing privacy-policy link
