## Context

`FlutterSecureKeyStorage` (`lib/domain/crypto/secure_key_storage.dart`) already has a real, documented macOS-specific workaround: `MacOsOptions(usesDataProtectionKeychain: false)`, needed because ad-hoc signed local builds hang indefinitely under the modern Data Protection Keychain API. No `LinuxOptions` is configured today, because Linux isn't a target at all yet. `flutter_secure_storage`'s Linux backend uses `libsecret` (a secret-service D-Bus API, typically backed by `gnome-keyring` or an equivalent), which needs a running keyring daemon and D-Bus session — present on a real Linux desktop, but not on a bare CI runner by default.

This session's macOS acceptance-testing work found several real, non-obvious platform bugs only discoverable by actually running the app (a fixed 800×600 window causing off-screen-target taps, a `NavigationRail` label hit-test quirk, a `MaterialLocalizations` context-resolution bug). There's no reason to assume Linux will have zero equivalent surprises, and good reason to expect at least one (the secure-storage backend is a bigger, more fundamental difference than anything that varied between locales on macOS).

This session runs on macOS and cannot cross-build or execute a Linux desktop Flutter target locally — validation has to happen on a real Linux environment, which for this proposal means a GitHub Actions `ubuntu-latest` runner (public repo, free hosted minutes, already used for `localized-smoke.yml`).

## Goals / Non-Goals

**Goals:**
- `flutter create --platforms=linux .` scaffolds the platform, and `flutter build linux` succeeds on a GitHub Actions Linux runner.
- The app actually launches and its core flows work: onboarding completes, a transaction can be recorded, basic navigation works — verified by hand (screenshots/logs from a CI run, or a local Linux machine if one becomes available), not by the full acceptance suite.
- Any Linux-specific code needed (most likely `LinuxOptions` on `FlutterSecureStorage`, possibly a CI-only keyring setup step) is added and documented with the same rationale-comment convention `MacOsOptions` already uses.

**Non-Goals:**
- Running the full `integration_test/acceptance/acceptance_test.dart` suite on Linux. That suite's harness has macOS-Keychain-specific reset/cleanup code (`resetToFreshDevice`'s `MacOsOptions`-configured `FlutterSecureStorage` instance) that would need its own Linux equivalent, and the suite's own runtime (7h57m-10h03m per locale on macOS) makes even a single full run a substantial commitment to validate on a brand-new platform. A future change, once basic Linux functionality is confirmed solid.
- Multi-locale testing on Linux. Same reasoning as above, and explicitly deferred per the `localized-release-verification` proposal's own scoping.
- Any release-publishing pipeline. A separate, later change once Linux (and any other gaps) are confirmed working.
- Making Linux part of `flutter-ci.yml`'s required PR gate. Getting Linux building at all comes first; deciding whether every PR should wait on a Linux build is a separate, later decision once the build is known to be fast and stable.

## Decisions

1. **Validate via a GitHub Actions Linux runner, not local emulation.** This session's environment (macOS) can't build or run a Linux Flutter target at all — there's no cross-compilation path for desktop GTK apps. A `workflow_dispatch`-triggered Linux job (mirroring `localized-smoke.yml`'s own pattern: `if: github.actor == github.repository_owner`, manual trigger, not part of the required PR gate) is the practical way to get real build/run feedback without needing a local Linux machine.

2. **Expect to add `LinuxOptions` to `FlutterSecureStorage`, and a CI keyring setup step, but confirm by running first rather than guessing the exact configuration up front.** The macOS precedent (`MacOsOptions(usesDataProtectionKeychain: false)`) exists because of a specific, discovered failure mode (a silent hang), not because it was anticipated in the abstract. The Linux equivalent is unknown until the first real build attempt surfaces it — likely either a working default, an error naming a missing D-Bus/secret-service dependency, or a hang similar to the macOS case. `apt-get install gnome-keyring dbus-x11` plus starting a keyring session before running the app is the standard workaround the Flutter community uses for this exact CI scenario, so tasks.md plans for needing it, without assuming it's the whole story until confirmed.

3. **A manual smoke check, not new automated tests, for this change's own verification.** Since the full acceptance suite is explicitly out of scope, "does this work" is verified by hand: launch the built Linux app (via the CI job's logs/artifacts, or VNC/screenshot if the runner supports it, or a real Linux machine if the user has one available) and walk through onboarding and recording one transaction. This mirrors how any brand-new platform bring-up is normally validated before investing in automated coverage for it.

## Risks / Trade-offs

- **[Linux CI runners may not support a real windowing session for a GUI app]** → `ubuntu-latest` runners are headless; a GTK app may need Xvfb (a virtual X server) even just to launch, let alone to be interacted with. Mitigation: confirm this is solvable (it's a very common Flutter-on-Linux-CI pattern, well documented in the Flutter community) before assuming the whole approach is blocked; fall back to "build succeeds, manual launch happens on a real Linux machine" if headless launch proves unworkable.
- **[Unknown number of Linux-specific bugs]** → Genuinely can't be estimated in advance, the same way macOS's real bugs weren't known until real runs surfaced them. Mitigation: treat this change's task list as investigation-first (get a build, see what breaks, fix what's found), not a fixed checklist assumed complete up front.
- **[This could balloon into a much bigger effort if the app has extensive macOS-only or mobile-only assumptions baked in beyond secure storage]** → Mitigation: if `flutter build linux` or a first launch surfaces a large class of problems beyond secure storage (e.g., pervasive platform-conditional UI code, file-path assumptions), pause and report back rather than continuing to dig — that would mean this proposal's scope needs revisiting, not more silent debugging.

## Migration Plan

N/A — purely additive (a new platform directory, possibly a new CI workflow, possibly new `LinuxOptions` config). Nothing existing changes behavior on macOS/iOS/Android/Windows.

## Open Questions

- Does the user have a real Linux machine available for hands-on validation, or is CI-runner-only validation (build succeeds, logs/screenshots reviewed) sufficient for this change's scope?
- Once basic functionality is confirmed, should Linux join `flutter-ci.yml`'s required PR gate, stay a manual/on-demand check indefinitely (like the acceptance suite), or something in between (e.g., a build-only check, no GUI interaction, on every PR)? Not decided here.

## Implementation findings (2026-09-10)

- Generated the runner with Flutter 3.47.1. The binary and window title remain
  `smara_accounting`, matching Windows/macOS. The GTK application ID is
  `com.smaraaccounting.smaraAccounting`, matching macOS's bundle identifier.
  Preserved the existing platforms' migration metadata while adding Linux.
- Inspected the resolved plugins' platform declarations: secure storage,
  path provider, shared preferences, file picker, and URL launcher provide
  Linux implementations. `local_auth` has none; the existing
  `LocalAuthBiometricAuthenticator` catches unsupported-plugin errors and
  returns false, so biometrics remain unavailable instead of crashing.
  This is a source audit, not runtime proof.
- `flutter_secure_storage_linux` 3.0.2's CMake configuration requires
  `libsecret-1 >= 0.18.4`; the build workflow installs `libsecret-1-dev`
  alongside Flutter's Linux build dependencies. The generated FFI plugin
  list also includes transitive `jni`; its actual build is still unverified.
- Added `.github/workflows/linux-desktop.yml`: manual dispatch, repository-owner
  gate, Ubuntu runner, Flutter 3.47.1, release build, and a tarred bundle
  artifact preserving executable permissions. No launch or acceptance step
  is included before the first build has been confirmed.
- First dispatch succeeded once the workflow reached the default branch:
  [run 34569574847](https://github.com/bhoopathyvm-cloud/smaraAccount/actions/runs/34569574847)
  (`workflow_dispatch`, 2026-09-11T06:21:26Z, `main`@`80de59f`, 2m20s total).
  Every step — checkout, installing Linux build dependencies, Flutter setup,
  `flutter pub get`, `flutter build linux --release --no-pub`, packaging the
  bundle, and uploading the artifact — reported `success`. This confirms task
  2.2: the app builds cleanly on a GitHub Actions `ubuntu-latest` runner with
  no dependency or generated-code fixes needed.
- Keyring/D-Bus runtime requirements, any need for `LinuxOptions`, onboarding,
  and identity persistence remain unknown until the app is actually launched
  and walked through (tasks 3-4) — a successful build proves compilation, not
  runtime behavior. No speculative secure-storage option has been added.
