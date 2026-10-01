## MODIFIED Requirements

### Requirement: A public privacy policy page exists and describes actual data handling
The project website SHALL contain a privacy policy page describing, in plain language: that there is no server or account, what is stored on-device and where, each opt-in network call and exactly what data it sends (including local-network discovery and device-to-device sync for Linked devices, and that those flows never leave the LAN or send books to the internet), how biometric unlock is handled, what a Books Copy or CSV export file contains, and a contact point for privacy questions. It SHALL NOT describe data handling the app doesn't actually do.

#### Scenario: Policy covers every actual data flow
- **WHEN** a visitor reads the privacy policy page
- **THEN** it accounts for the signing key, the local ledger database, the reference-exchange-rate lookup, the investment quote lookup, biometric unlock, Books Copy / export file contents, and Linked-devices local-network discovery and peer sync

#### Scenario: Policy does not overclaim or underclaim
- **WHEN** the policy is compared against `ios-privacy-compliance`'s manifest and export-compliance declarations
- **THEN** neither describes a data flow the other doesn't also account for

#### Scenario: LAN sync is described without inventing a cloud
- **WHEN** a visitor reads the Linked devices / sync portion of the policy
- **THEN** it states that discovery and sync stay on the local Wi-Fi
- **AND** it does not claim a server, account, or push service holds the books
