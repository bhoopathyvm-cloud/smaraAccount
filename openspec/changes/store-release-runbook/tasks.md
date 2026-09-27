## 1. Runbook document

- [ ] 1.1 Create `docs/release/store-release-runbook.md` with shared prep (ship commit, `pubspec.yaml` version/`+` build bump with Apple reuse warning, pointer to `docs/release/checklist.md` gates), and verify the file exists and opens with an ordered checklist (not a narrative-only essay)
- [ ] 1.2 Add the Google Play closed-testing section: `flutter build appbundle`, artifact path `build/app/outputs/bundle/release/app-release.aab`, optional `keytool -printcert` check, Play Console closed-testing create-release/rollout steps, and a link to `android-upload-keystore.md` for first-time keystore work — verify a reader can follow without opening archived OpenSpec notes
- [ ] 1.3 Add the iOS TestFlight section: Xcode Archive → Distribute → upload path, CLI `xcodebuild` archive/export-upload path consistent with prior uploads, bundle id `com.smaraaccounting.smaraAccounting`, wait-for-processing then Internal/External TestFlight assignment — verify both paths are documented and the build-number reuse pitfall is called out

## 2. Discoverability links

- [ ] 2.1 Update `docs/release/checklist.md` platform release steps to link `store-release-runbook.md` for Play closed testing and TestFlight (keep the keystore link), and verify the checklist still names both locale/macOS gates
- [ ] 2.2 Update `CONTRIBUTING.md` Store release section to link `docs/release/store-release-runbook.md` alongside the checklist and keystore docs, and verify all three links resolve

## 3. Validation

- [ ] 3.1 Run `openspec validate store-release-runbook --strict` and verify it reports the change valid
