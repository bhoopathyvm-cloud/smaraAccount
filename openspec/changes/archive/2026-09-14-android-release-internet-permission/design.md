## Context

See proposal.md for motivation. This is a one-line permission fix, not
an architectural change.

## Goals / Non-Goals

**Goals:**
- Release Android builds have the same network capability Debug/Profile
  builds already have.

**Non-Goals:**
- Auditing every other permission for the same debug-vs-release gap —
  out of scope for this change, though worth a mental note that Flutter's
  per-build-type manifest split is an easy place for this exact class of
  bug to recur.
- Any change to what the two network features actually do or send — only
  whether the OS allows the socket call at all.

## Decisions

### 1. Add the permission to the main manifest, not the release-only one
Flutter's template already put `INTERNET` in `debug`/`profile` overlays
specifically for the dev-tooling connection, not for the app's own
features. The app's own use of the network (exchange rate lookup,
investment quotes) is a real feature needed in every build type,
including Release, so it belongs in `android/app/src/main/AndroidManifest.xml`
— present everywhere — rather than duplicating it into a
`release`-specific overlay that doesn't exist yet.

**Alternative considered:** create `android/app/src/release/AndroidManifest.xml`
with just this permission. Rejected — adds a new file and a second place
this permission is declared, for no benefit over adding it once to the
manifest already merged into every build type.

## Risks / Trade-offs

- **[Risk]** Verifying this fix requires inspecting a real release
  (or at least release-signed) build's merged manifest, not just
  re-running the debug-based acceptance suite, which would pass either
  way since it never exercised the missing permission → **Mitigation**:
  verification task explicitly builds a release APK and dumps its
  permissions with `aapt`, the same way the bug was originally confirmed.

## Migration Plan

Not applicable — additive permission, no data or behavior migration.
Rollback = remove the one line.
