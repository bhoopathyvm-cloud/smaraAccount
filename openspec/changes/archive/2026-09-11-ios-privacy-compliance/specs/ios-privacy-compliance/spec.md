## ADDED Requirements

### Requirement: Export-compliance status is declared in Info.plist
The iOS app SHALL declare its export-compliance status via `ITSAppUsesNonExemptEncryption` in `Info.plist`, reflecting that its cryptography is used only for local authentication and data-integrity verification.

#### Scenario: Info.plist states the exemption
- **WHEN** the app is archived for App Store Connect submission
- **THEN** `ITSAppUsesNonExemptEncryption` is present in `Info.plist` with a value matching the app's actual crypto usage (authentication/integrity only)

### Requirement: Required-reason API usage is declared in a privacy manifest
The iOS app target SHALL ship a `PrivacyInfo.xcprivacy` declaring any required-reason API its own code uses, and every bundled plugin's required-reason API usage SHALL be covered either by the plugin's own bundled manifest or, where genuinely missing, by the app target's manifest.

#### Scenario: No undeclared required-reason API usage
- **WHEN** the app is archived
- **THEN** every required-reason API touched by the app's own code or an audited plugin without its own manifest is declared in `ios/Runner/PrivacyInfo.xcprivacy`

### Requirement: Compliance declarations match the public privacy policy
The data flows declared in the privacy manifest and the export-compliance statement SHALL be consistent with what the public privacy policy page describes.

#### Scenario: Declarations and policy tell the same story
- **WHEN** a reviewer compares `PrivacyInfo.xcprivacy` against the privacy policy page
- **THEN** neither describes a data flow the other doesn't also account for
