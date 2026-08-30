## Why

Apple requires two declarations this repo doesn't have yet, for every App Store Connect submission: an **export-compliance** answer (the app uses cryptography — device-generated signing keys, PBKDF2 for the app-lock PIN, chain verification — for `ledger-integrity-signing` and `app-lock`), and a **Privacy Manifest** (`PrivacyInfo.xcprivacy`) declaring any "required-reason API" usage, both the app's own and (transitively) any bundled third-party SDK's. Neither is present today. Without them, App Store Connect blocks submission or (for export compliance) re-asks the same questionnaire on every single build upload.

## What Changes

- Add `ITSAppUsesNonExemptEncryption` to `ios/Runner/Info.plist` with the correct value for this app's actual crypto usage — it signs/verifies locally for authentication and data-integrity purposes only, uses no proprietary or non-standard algorithms, and isn't itself a cryptography product, which is the standard exemption category — so App Store Connect stops re-asking on every upload.
- Add a `PrivacyInfo.xcprivacy` for the `Runner` app target declaring the required-reason APIs the app's own Dart/Swift code touches (audited, not assumed).
- Audit each bundled plugin that's historically touched required-reason APIs (`shared_preferences`, `path_provider`, `flutter_secure_storage`, `local_auth`, `file_picker`, `sqlite3`/Drift's native layer, `url_launcher`) for whether their installed versions already bundle their own manifest — most current versions do; note any gap found.
- Cross-reference the data types actually collected/transmitted (documented in the `privacy-policy-page` change) so the eventual App Store Connect "App Privacy" questionnaire answers stay consistent with both the manifest and the public privacy policy, rather than three documents independently drifting.

## Capabilities

### New Capabilities
- `ios-privacy-compliance`: the iOS build declares its export-compliance status and required-reason API usage accurately, matching its actual (minimal, on-device-only, no third-party data sharing beyond two labeled opt-in lookups) data behavior.

### Modified Capabilities
- (none — no product behavior changes; this is a compliance-declaration change only)

## Impact

- `ios/Runner/Info.plist`
- New `ios/Runner/PrivacyInfo.xcprivacy`
- Depends on `privacy-policy-page` for a single, consistent source of truth on what data the app actually handles — implement that change first, or in parallel, not after
- App Store Connect's "App Privacy" questionnaire itself is filled in per-submission in Apple's own console, not a code artifact — this change makes sure the code-side declarations back up whatever answers go in there
