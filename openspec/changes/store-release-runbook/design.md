## Context

See proposal.md for why. Today, Play closed-testing updates and TestFlight
uploads are possible, but the procedure is split across
`docs/release/checklist.md`, `docs/release/android-upload-keystore.md`,
`CONTRIBUTING.md`, and archived launch-readiness notes. Current
`pubspec.yaml` is `1.0.0+3`; build `3` was already uploaded for iOS, so
any new runbook must treat build-number monotonicity as a hard rule.

Constraints: documentation-only; no automation of Play Console or App
Store Connect; keep deep keystore material in the existing keystore doc.

## Goals / Non-Goals

**Goals:**
- One ordered runbook a release owner can follow without hunting archives.
- Clear shared prep → Play → TestFlight structure with project-specific
  paths, bundle id, and known failure modes.
- Discoverability via checklist + CONTRIBUTING links.

**Non-Goals:**
- Automating uploads (fastlane, CI store deploy).
- Changing signing configs, entitlements, or listing assets.
- Replacing `localized-release-verification` gates or rewriting the
  keystore enrollment history.
- macOS App Store re-upload steps in this first cut (iOS TestFlight + Play
  closed testing only), unless a short "out of scope / see prior notes"
  pointer is useful.

## Decisions

### 1. Single runbook file at `docs/release/store-release-runbook.md`

**Alternatives:** fold into `checklist.md`; split Play vs Apple docs;
live only in CONTRIBUTING.

**Decision:** one dedicated runbook. The checklist stays the gate
document; the keystore doc stays the signing deep-dive; CONTRIBUTING
stays the pointer. Splitting Play/Apple would force the shared version-
bump rules to be duplicated.

### 2. Checklist style with copy-pasteable commands

Numbered steps and fenced commands for `flutter build appbundle`, version
bump location, and the Xcode/CLI archive path already proven in
`app-store-launch-readiness` archives. Prefer "do this" over background
essays; put pitfalls (reused `CFBundleVersion`, waiting for TestFlight
processing) as callouts next to the step they affect.

### 3. Link, don't duplicate, keystore and gate docs

Play section: build + console rollout steps here; "first-time keystore /
Play App Signing" → `android-upload-keystore.md`. Shared prep: "complete
gates" → `checklist.md`.

### 4. Document both Xcode and CLI for iOS

Owners already used both. Xcode first for ease; CLI second with the
`xcodebuild archive` / `-exportArchive` upload pattern from prior
success. Bundle id: `com.smaraaccounting.smaraAccounting`.

## Risks / Trade-offs

- **[Risk]** Console UI labels drift over time. → **Mitigation:** describe
  intent ("Closed testing → Create new release") plus artifact paths that
  do not change; revisit when a release owner hits a renamed screen.
- **[Risk]** Runbook goes stale after the next version bump convention
  change. → **Mitigation:** state the rule (monotonic `+N`), not a fixed
  next number.
- **[Trade-off]** Omitting macOS App Store upload keeps the first version
  short; macOS can be a follow-up section later.

## Migration Plan

1. Add `docs/release/store-release-runbook.md`.
2. Update `docs/release/checklist.md` platform steps and
   `CONTRIBUTING.md` Store release section to link it.
3. No runtime migration; rollback = delete the runbook and revert links.

## Open Questions

- None for this cut; macOS App Store steps deferred intentionally.
