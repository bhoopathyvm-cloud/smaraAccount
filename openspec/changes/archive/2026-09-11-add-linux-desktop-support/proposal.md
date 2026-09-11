## Why

The app already builds for macOS, Windows, iOS, and Android — `windows/`, `macos/`, `ios/`, and `android/` project directories all exist — but there is no `linux/` directory at all. The product's stated goal is to support every platform Flutter can target, not just the ones already scaffolded, and Linux is the one genuine gap. Before Linux can be part of any future release-publishing pipeline or platform-specific testing, the platform itself needs to exist, build, and actually work — the same bring-up-and-debug process this session already went through for macOS's own acceptance-testing infrastructure, but for basic platform functionality this time, on a platform nothing has ever been run on before.

## What Changes

- Scaffold Linux desktop as a supported Flutter build target (`flutter create --platforms=linux .`), adding the generated `linux/` project directory and any CMake/GTK embedding code Flutter generates.
- Get the app actually building (`flutter build linux`) and launching on Linux, using a GitHub Actions `ubuntu-latest` runner as the build/validation environment (this session runs on macOS, which cannot cross-build or run a Linux desktop Flutter target locally).
- Work through whatever platform-specific issues surface — this is explicitly a discovery process, not a pre-planned fix list, since nothing about this app's actual behavior on Linux is known yet. Likely areas needing attention, based on what mattered for macOS:
  - `flutter_secure_storage`'s Linux backend (typically `libsecret`/a secret-service daemon) — needs a running D-Bus session and keyring service, which a bare CI runner doesn't have by default.
  - Window/rendering behavior under a virtual display (Xvfb or equivalent) in a headless CI environment.
  - Any other platform-conditional code in the app that currently only branches for macOS/iOS/Android (e.g., `lib/domain/crypto/secure_key_storage.dart` and anywhere else secure-storage options are configured per platform).
- Scope is **basic platform functionality only**: the app builds, launches, and its core flows work (onboarding, recording a transaction, basic navigation) — a manual smoke-level check, not the full acceptance suite and not multi-locale testing. Both of those are explicitly deferred to future, separate changes once this foundation exists.

## Capabilities

### New Capabilities
- `linux-desktop-platform`: the app is a genuinely supported, working Flutter target on Linux desktop, not just a claim.

### Modified Capabilities

(none)

## Impact

- New `linux/` directory (Flutter-generated CMake/GTK scaffolding).
- Possible changes to `lib/domain/crypto/secure_key_storage.dart` (or wherever secure-storage backend selection lives) if Linux needs its own handling, the way macOS already has `MacOsOptions`.
- A new or extended CI workflow step to build (and manually validate) the Linux target — kept separate from `flutter-ci.yml`'s existing PR gate unless the team decides otherwise once this works, since adding a slow new build target to every PR's required checks is a separate decision from just getting Linux working at all.
- No changes to the acceptance-test-suite tooling, the localized-release-verification proposal, or any release-publishing pipeline — all explicitly out of scope here.
