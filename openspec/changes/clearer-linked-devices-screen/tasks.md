## 1. Device names

- [x] 1.1 Default device name from platform and form factor; "Name this device" dialog shown before the first Add my device / Add a person / Scan join QR when no name is stored
- [x] 1.2 Rename for the local device: updates the membership row, the stored setting and enqueues a `linked_device` `displayName` op
- [x] 1.3 Unit test: rename emits the op and a peer applying it shows the new name

## 2. Screen layout and wording

- [x] 2.1 Three sections (My devices, People, Join or sync) with headings and one-line explanations; "More ways to connect" expander for code and address
- [x] 2.2 "(this device)" marker on the local entry
- [x] 2.3 Plain role labels and role-picker explanations
- [x] 2.4 New ARB strings in en and all other locales; regenerate localizations
- [x] 2.5 Widget tests for sections, marker, role labels and the name prompt

## 3. Verification

- [x] 3.1 `dart format`, `flutter analyze`, `flutter test` green
- [ ] 3.2 `tool/run_acceptance_tests.sh -d macos` green and company-sync `--employees 2 --ios-only` green (finders still work)
- [ ] 3.3 Manual check on the Mac and both iPhones: the user can tell devices and people apart
