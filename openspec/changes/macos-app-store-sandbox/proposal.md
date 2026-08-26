## Why

`macos/Runner/Release.entitlements` and `DebugProfile.entitlements` both have `com.apple.security.app-sandbox` set to `false`, with an inline comment already flagging this: *"Revisit before any App Store submission - sandboxing is required there."* The Mac App Store rejects any submission without App Sandbox enabled — this is non-negotiable, unlike direct/notarized distribution outside the store.

Sandboxing was turned off because two real capabilities depend on entitlements that weren't wired up: `flutter_secure_storage`'s macOS Keychain writes (the device signing key, per `ledger-integrity-signing`) need a `keychain-access-groups` entitlement, and `file_picker`'s save/open dialogs need `com.apple.security.files.user-selected.*`. The current `files.user-selected.read-only` entitlement only covers *opening* a file (OFX/CSV import) — it does not cover *saving* one, and this app has two save-to-a-chosen-location flows that would silently break under a naive sandbox flip: `ledger-backup`'s "Save backup" and `ledger-data-export`'s "Export CSV," both of which call `FilePicker.saveFile`.

## What Changes

- Enable `com.apple.security.app-sandbox` in `Release.entitlements` (and align `DebugProfile.entitlements` once real Apple Developer signing is configured for local builds — see Open Questions in `design.md`).
- Add `com.apple.security.keychain-access-groups` as an empty array (confirmed sufficient by `flutter_secure_storage`'s own macOS example entitlements — no App Group needed since this app doesn't share Keychain items with a companion app or extension).
- Upgrade `com.apple.security.files.user-selected.read-only` to `com.apple.security.files.user-selected.read-write`, so `FilePicker.saveFile` (backup export, CSV export) keeps working once sandboxed.
- Verify, under a real sandboxed build: OFX/CSV import (`file_picker` open), CSV export and ledger backup save (`file_picker` save), signing-key read/write (`flutter_secure_storage`), and Face ID/Touch ID unlock (`local_auth`) all still work.

## Capabilities

### New Capabilities
- `macos-app-store-sandbox`: the macOS build runs under App Sandbox with exactly the entitlements its actual file/Keychain access patterns need — no broader grant than necessary.

### Modified Capabilities
- (none — no product behavior changes; this is a build/entitlement change only)

## Impact

- `macos/Runner/Release.entitlements`, `macos/Runner/DebugProfile.entitlements`
- Requires a real Apple Developer Team configured in Xcode signing settings for the entitlements to actually resolve at build/run time (external prerequisite, not a code change — see `design.md`)
- Acceptance coverage: OFX/CSV import, CSV export, ledger backup save/restore, and app-lock unlock, all spot-checked on a sandboxed macOS build before this is considered done
