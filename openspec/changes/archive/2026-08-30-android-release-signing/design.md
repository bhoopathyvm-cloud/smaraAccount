## Context

Found during App Store/Play Store distribution planning (2026-08-27). This is the default Flutter-template state (`signingConfigs.getByName("debug")` left as a placeholder) that every project is expected to replace before its first real release build — it was simply never done here since no release build had shipped yet.

## Goals / Non-Goals

**Goals:**
- Release builds signed with a real, app-specific key.
- The signing key material never enters version control.
- A missing signing key produces a clear build failure, not a silent debug-signed artifact.

**Non-Goals:**
- Automating keystore generation itself — a private key is exactly the kind of artifact this repo's own security posture (no secrets committed, ever) says a human generates and safeguards, not something scripted into existence and left on disk for an agent to find.
- Setting up Play App Signing enrollment in Google Play Console — an external, account-level step, not a code change (see Migration Plan).
- CI/CD signing automation (e.g. injecting `key.properties` from a CI secret store) — worth a future change once there's an actual CI release pipeline; out of scope here.

## Decisions

### 1. `key.properties` file, the standard Flutter pattern

**Options:** (A) Hard-code signing values as Gradle properties in a tracked file; (B) A git-ignored `key.properties` file read at build time; (C) Environment variables only.

**Decision: B**, matching the pattern Flutter's own official Android deployment docs use and that most Flutter projects already follow — familiar to anyone who has shipped a Flutter app before, and simple to extend with environment-variable overrides later (C) if a CI pipeline is added, without changing the Gradle wiring itself.

### 2. Fail loudly, not silently, when the key is missing

The build script checks for `key.properties`'s existence before configuring the release `signingConfig`; if absent, the Gradle build fails with an explicit error naming the missing file, rather than falling back to `signingConfigs.getByName("debug")`. A release build that's accidentally debug-signed and uploaded is a worse failure mode than a build that simply refuses to run.

## Risks / Trade-offs

- **[Risk]** The generated keystore or `key.properties` gets committed by accident → **Mitigation:** both added to `.gitignore` in the same change; `git status` after generation should show neither as trackable.
- **[Risk]** Losing the upload keystore after Play App Signing enrollment locks the app out of future updates (Google can help recover access under Play App Signing, but it's a real support process, not instant) → **Mitigation:** call out explicitly in `tasks.md` that the generated `.jks` file must be backed up somewhere durable and private (a password manager or encrypted backup) before first upload — the same “no recovery backdoor” discipline this app’s own signing-key design already asks of its *users*.
- **[Trade-off]** None beyond the one-time manual keystore-generation step.

## Migration Plan

1. Add the `key.properties`-driven `signingConfig` to `build.gradle.kts`; wire the `release` build type to it; add the fail-loudly check.
2. Update `.gitignore`.
3. (Human step, outside this repo) Generate an upload keystore with `keytool -genkeypair -v -keystore <path> -keyalg RSA -keysize 2048 -validity 10000 -alias upload`; store it somewhere durable and private; populate `android/key.properties` locally.
4. (Human step) Build a signed release AAB (`flutter build appbundle`), enroll in Play App Signing on first upload to Google Play Console.
5. Rollback = revert the Gradle/`.gitignore` changes; no data migration.

## Open Questions

- None outstanding — the only open item is the human keystore-generation step, tracked as a task, not a design decision.
