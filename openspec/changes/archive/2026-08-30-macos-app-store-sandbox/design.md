## Context

Found during App Store distribution planning (2026-08-27). App Sandbox has been off since `DebugProfile.entitlements` was first written, with its own comment explaining why: `flutter_secure_storage`'s Keychain writes need a `keychain-access-groups` entitlement whose `$(AppIdentifierPrefix)` only resolves under real Apple Developer code signing, not the "Sign to Run Locally" mode used for day-to-day local development. That workaround needs to end before a Mac App Store submission, since the store requires sandboxing unconditionally.

## Goals / Non-Goals

**Goals:**
- App Sandbox on for the Release configuration, with the minimum entitlement set the app's actual features need.
- No regression in signing-key storage, file import/export, backup save/restore, or biometric unlock.

**Non-Goals:**
- Setting up the actual paid Apple Developer Team / signing certificates — that's an account-level prerequisite the user completes outside this repo (Xcode's "Signing & Capabilities" tab, `Runner` and `RunnerTests` targets).
- Changing anything about iOS or Android sandboxing — iOS is sandboxed by default already; Android's permission model is a separate, unrelated mechanism.
- Notarization/hardened-runtime setup for *non*-App-Store (direct) distribution — out of scope; this change is specifically about the Mac App Store path.

## Decisions

### 1. Empty `keychain-access-groups` array, not an App Group string

`flutter_secure_storage`'s own macOS example (`example/macos/Runner/Release.entitlements` in the installed `flutter_secure_storage: 11.0.0` package) uses:

```xml
<key>com.apple.security.app-sandbox</key>
<true/>
<key>keychain-access-groups</key>
<array/>
</dict>
```

An empty array is sufficient — an explicit `$(AppIdentifierPrefix)<group>` entry is only needed if a Keychain item must be shared across multiple apps or an app extension, which this app doesn't have. Using the plugin's own confirmed-working example over a hand-derived guess avoids introducing a mismatched entitlement that "looks right" but silently fails at runtime (the exact failure mode this repo's existing comment already warns about).

### 2. `files.user-selected.read-write`, not `read-only`

Two existing flows call `FilePicker.saveFile` to write to a user-chosen location outside the sandbox container: `ledger-backup`'s "Save backup" and `ledger-data-export`'s "Export CSV." The current `read-only` entitlement covers only the *open* dialogs (OFX/CSV import). `read-write` is required for `saveFile` to function under sandbox — confirmed against `file_picker`'s documented macOS entitlement requirements.

### 3. Debug entitlements stay unsandboxed until real signing is available for local dev, tracked as an explicit follow-up

Flipping `DebugProfile.entitlements` to sandboxed too would require every contributor's local `flutter run -d macos` to use real Apple Developer signing, which isn't true today ("Sign to Run Locally" per the existing comment). Rather than block this change on that unrelated setup, `Release.entitlements` changes now (it's the configuration that actually ships to the App Store and is only ever built with real signing for that purpose); `DebugProfile.entitlements` is revisited once real signing is routinely available for local runs too, so local development doesn't regress in the meantime.

## Risks / Trade-offs

- **[Risk]** Sandboxing surfaces a file-access path this audit missed (e.g. a temp-file read/write during CSV/OFX parsing that assumes unrestricted filesystem access) → **Mitigation:** exercise every file-touching flow (import, export, backup save/restore) on a real sandboxed build before merging, not just `flutter analyze`/unit tests, per this repo's own "run the acceptance suite after wiring/config changes" rule.
- **[Risk]** `keychain-access-groups` entitlement is present but the build still isn't signed with a real Team ID at test time, so the failure mode this change is meant to fix can't actually be verified locally → **Mitigation:** call this out explicitly as a blocking prerequisite in `tasks.md` rather than silently deferring verification.
- **[Trade-off]** `DebugProfile.entitlements` staying unsandboxed means local debug builds and the eventual App Store release build now behave slightly differently at the sandbox boundary — accepted for now (Decision 3), revisited once real signing is routine for local dev.

## Migration Plan

1. Update `Release.entitlements` per Decisions 1–2.
2. Build and run a signed Release macOS build (requires a real Apple Developer Team configured in Xcode).
3. Exercise OFX import, CSV import, CSV export, backup save, backup restore, and app-lock unlock on that build.
4. If any flow breaks, add the specific entitlement it needs (not a broader grant) and re-verify.
5. Rollback = revert the entitlements file; no data migration.

## Open Questions

- Resolved during apply: keep `DebugProfile.entitlements` unsandboxed
  until a real Apple Developer Team is routine for local `flutter run -d
  macos` (Decision 3). `Release.entitlements` is the store configuration.
