## MODIFIED Requirements

### Requirement: The Pre-Release Step Is Documented, Not Tribal Knowledge
The release checklist SHALL name both pre-release locale/platform checks
explicitly: the nightly Linux CI tier (automatic, covers every supported
locale, checked rather than run by the release owner) and the macOS
baseline check (manual, English only, run by the release owner). After
those gates, the checklist's platform release steps SHALL point at
`docs/release/store-release-runbook.md` for updating Google Play closed
testing and uploading an iOS build to TestFlight, and SHALL continue to
point at `docs/release/android-upload-keystore.md` for upload-keystore
setup.

#### Scenario: A new contributor prepares a release
- **WHEN** a contributor who has never prepared a release before follows the release checklist
- **THEN** the checklist names where to check the nightly Linux CI tier's latest result, and the exact command for the macOS baseline check, and states plainly that the macOS check no longer covers multiple locales

#### Scenario: Checklist points at the store upload runbook
- **WHEN** a release owner has satisfied the locale and macOS gates and
  needs to push binaries to the stores
- **THEN** the checklist's platform steps link to
  `docs/release/store-release-runbook.md` for Play closed testing and
  TestFlight upload
