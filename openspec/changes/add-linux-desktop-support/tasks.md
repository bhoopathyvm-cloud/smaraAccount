## 1. Scaffold the platform

- [x] 1.1 Run `flutter create --platforms=linux .` from the repo root to generate the `linux/` project directory. Review the generated files (CMake config, GTK embedding code, `main.cc`) rather than assuming they need no attention — confirm the generated app id/name match the project's existing conventions (compare against how `windows/`/`macos/` are named).
- [x] 1.2 Confirm `pubspec.yaml`'s dependencies don't have any Linux-incompatible plugin already in use (check `flutter pub deps` or each plugin's own platform-support table) before assuming everything just works — `flutter_secure_storage`, `path_provider`, `shared_preferences`, `file_picker`, `url_launcher`, and any others this app depends on.

## 2. Get a build running via CI (this session's environment can't build Linux desktop locally)

- [x] 2.1 Add a `workflow_dispatch`-triggered GitHub Actions job on `ubuntu-latest` (mirroring `localized-smoke.yml`'s `if: github.actor == github.repository_owner` gate, manual trigger, not part of `flutter-ci.yml`'s required PR gate) that installs Linux build dependencies (`clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev libstdc++-12-dev` — the standard Flutter-on-Linux CI package set) and runs `flutter build linux`.
- [x] 2.2 Triggered the workflow and confirmed the build succeeded: run [34569574847](https://github.com/bhoopathyvm-cloud/smaraAccount/actions/runs/34569574847) (`workflow_dispatch`, 2026-09-11T06:21:26Z, `main`@`80de59f`, 2m20s) — every step (checkout, install Linux build dependencies, set up Flutter, install dependencies, `flutter build linux --release --no-pub`, package bundle, upload artifact) reported `success`. No dependency or generated-code fixes were needed.

## 3. Get the app launching and interactable

- [x] 3.1 Extended the CI job to launch the built app under Xvfb: [run 34574615287](https://github.com/bhoopathyvm-cloud/smaraAccount/actions/runs/34574615287) shows the app starting (Impeller/OpenGLESSDF backend selected), staying alive for the full 10s check, and being killed cleanly — no crash on launch.
- [x] 3.2 Added `gnome-keyring` + `dbus-x11`, running the app inside `dbus-run-session` with an unlocked keyring (`gnome-keyring-daemon --unlock` / `--start --components=secrets`). The same run above completed the 10s liveness window with the keyring active and no hang — onboarding's actual read/write exercise happens in task 4.1, but nothing here suggests `flutter_secure_storage` blocks with this setup.
- [x] 3.3 Not needed: the keyring/D-Bus setup in 3.2 resolved secure storage on its own — task 4's `identity_restore` group (real secure-storage reads/writes/deletes) passed with no `LinuxOptions` added, so `FlutterSecureKeyStorage` is unchanged.

## 4. Manual smoke check

- [x] 4.1 Ran the existing `onboarding` acceptance group (`completeOnboardingWithGuidedEntry`: first-week-setup wizard, a guided transaction, the recovery-phrase gate) against the real Linux build under Xvfb: [run 34575076425](https://github.com/bhoopathyvm-cloud/smaraAccount/actions/runs/34575076425) — "🎉 3 tests passed." (see design.md for why this automated group, not a hands-on walkthrough, is this task's evidence in a headless CI environment).
- [x] 4.2 Ran the existing `identity_restore` acceptance group (clears only the signing key from secure storage, simulating a reinstall, then restores it from the recovery phrase — a stronger persistence check than a simple relaunch) against the same build: same run, "🎉 1 test passed." No `LinuxOptions` change was needed — `flutter_secure_storage` works with its Linux defaults.
- [x] 4.3 Nothing beyond secure storage and windowing surfaced as broken. Both acceptance groups passed as-is, with no harness or app-code changes needed for Linux; the only hit-test warning in the log is the suite's own benign, known noise pattern (also seen on macOS runs), not a failure.

## 5. Document what was learned

- [x] 5.1 Updated `design.md`'s Open Questions and added a "What was actually found" section: no `LinuxOptions` needed, the exact keyring/D-Bus CI steps that worked, headless CI validation (Xvfb + two targeted acceptance groups) was sufficient with no real Linux machine needed, and what remains unexercised (the other 11 acceptance groups, multi-locale coverage).
