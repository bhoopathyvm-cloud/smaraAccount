## 1. Write the page

- [ ] 1.1 `pages/open-source/smara-account/privacy-policy.md`: no server/no account, on-device storage (signing key location, ledger database location), the two opt-in network calls and exactly what each sends, biometric data handling, backup/export file contents, contact point
- [ ] 1.2 Link it from `pages/open-source/smara-account/index.md`
- [ ] 1.3 Link it from `pages/open-source/smara-account/whats-built.md`

## 2. In-app link

- [ ] 2.1 Add an injectable URL-opener to `SettingsViewModel`, matching `HoldingsViewModel`'s `launchUrlFn` pattern
- [ ] 2.2 Add the "Privacy Policy" row under Settings' existing About section
- [ ] 2.3 Add the new l10n string(s) to the source `.arb` file; regenerate (never hand-edit `lib/l10n/generated/`)

## 3. Verify

- [ ] 3.1 `mkdocs build --strict` passes with the new page and links
- [ ] 3.2 Widget test: tapping the Settings row calls the injected opener with the expected URL (matching how the research-tool link is tested)
- [ ] 3.3 Cross-check the page's content against `ios-privacy-compliance`'s manifest/export-compliance declarations for consistency
