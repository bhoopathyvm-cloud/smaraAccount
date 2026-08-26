## 1. Export compliance

- [ ] 1.1 Add `ITSAppUsesNonExemptEncryption` (false) to `ios/Runner/Info.plist`, with a comment stating the exemption reasoning

## 2. Privacy manifest audit

- [ ] 2.1 Check `shared_preferences` (installed version) for a bundled `PrivacyInfo.xcprivacy`
- [ ] 2.2 Check `path_provider` for the same
- [ ] 2.3 Check `flutter_secure_storage` for the same
- [ ] 2.4 Check `local_auth` for the same
- [ ] 2.5 Check `file_picker` for the same
- [ ] 2.6 Check `sqlite3`/Drift's native layer for the same
- [ ] 2.7 Check `url_launcher` for the same
- [ ] 2.8 List any genuine gaps found

## 3. App-target manifest

- [ ] 3.1 Add `ios/Runner/PrivacyInfo.xcprivacy` covering the app's own required-reason API usage plus any gaps from task 2
- [ ] 3.2 Cross-check declared data flows against `privacy-policy-page`'s documented data flows for consistency

## 4. Verify

- [ ] 4.1 Xcode build succeeds with the new manifest present (Xcode surfaces manifest-format errors at archive time)
- [ ] 4.2 `flutter analyze` still clean
