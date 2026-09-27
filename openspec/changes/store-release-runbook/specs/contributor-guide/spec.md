## ADDED Requirements

### Requirement: Store Release Section Links the Runbook
`CONTRIBUTING.md`'s Store release section SHALL link to
`docs/release/store-release-runbook.md` as the step-by-step procedure for
updating Google Play closed testing and uploading to Apple TestFlight, in
addition to linking the release checklist and Android upload-keystore
reference.

#### Scenario: Contributors find the runbook from CONTRIBUTING
- **WHEN** a reader opens the Store release section of `CONTRIBUTING.md`
- **THEN** it links to `docs/release/store-release-runbook.md`
- **AND** it still links to `docs/release/checklist.md` and
  `docs/release/android-upload-keystore.md` for gates and signing setup
