## ADDED Requirements

### Requirement: Local-network usage is declared for Linked devices
The iOS app SHALL declare local-network / Bonjour usage required for Linked devices discovery and peer sync (Info.plist usage description and any privacy-manifest entries the OS requires), consistent with asking permission only when the user first opens Linked devices. The usage description SHALL match the in-app sentence that nothing goes to the internet for that purpose.

#### Scenario: Archive includes local-network declaration
- **WHEN** the app is archived for App Store Connect submission after Linked devices ships
- **THEN** the local-network usage description is present for discovery/sync
- **AND** it is consistent with the privacy policy's LAN-only description

## MODIFIED Requirements

### Requirement: Export-compliance status is declared in Info.plist
The iOS app SHALL declare its export-compliance status via `ITSAppUsesNonExemptEncryption` in `Info.plist`, reflecting that its cryptography is used for local authentication, data-integrity verification, passphrase-protected Books Copies, and encrypted device-to-device sync on the local network — not for a server account.

#### Scenario: Info.plist states the exemption
- **WHEN** the app is archived for App Store Connect submission
- **THEN** `ITSAppUsesNonExemptEncryption` is present in `Info.plist` with a value matching the app's actual crypto usage (authentication, integrity, local file protection, and LAN peer encryption)

### Requirement: Compliance declarations match the public privacy policy
The data flows declared in the privacy manifest, Info.plist local-network usage, and the export-compliance statement SHALL be consistent with what the public privacy policy page describes, including Linked devices LAN discovery and sync.

#### Scenario: Declarations and policy tell the same story
- **WHEN** a reviewer compares `PrivacyInfo.xcprivacy` and local-network usage text against the privacy policy page
- **THEN** neither describes a data flow the other doesn't also account for
