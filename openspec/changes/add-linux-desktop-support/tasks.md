## 1. Scaffold the platform

- [x] 1.1 Run `flutter create --platforms=linux .` from the repo root to generate the `linux/` project directory. Review the generated files (CMake config, GTK embedding code, `main.cc`) rather than assuming they need no attention — confirm the generated app id/name match the project's existing conventions (compare against how `windows/`/`macos/` are named).
- [x] 1.2 Confirm `pubspec.yaml`'s dependencies don't have any Linux-incompatible plugin already in use (check `flutter pub deps` or each plugin's own platform-support table) before assuming everything just works — `flutter_secure_storage`, `path_provider`, `shared_preferences`, `file_picker`, `url_launcher`, and any others this app depends on.

## 2. Get a build running via CI (this session's environment can't build Linux desktop locally)

- [x] 2.1 Add a `workflow_dispatch`-triggered GitHub Actions job on `ubuntu-latest` (mirroring `localized-smoke.yml`'s `if: github.actor == github.repository_owner` gate, manual trigger, not part of `flutter-ci.yml`'s required PR gate) that installs Linux build dependencies (`clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev libstdc++-12-dev` — the standard Flutter-on-Linux CI package set) and runs `flutter build linux`.
- [x] 2.2 Triggered the workflow and confirmed the build succeeded: run [34569574847](https://github.com/bhoopathyvm-cloud/smaraAccount/actions/runs/34569574847) (`workflow_dispatch`, 2026-09-11T06:21:26Z, `main`@`80de59f`, 2m20s) — every step (checkout, install Linux build dependencies, set up Flutter, install dependencies, `flutter build linux --release --no-pub`, package bundle, upload artifact) reported `success`. No dependency or generated-code fixes were needed.

## 3. Get the app launching and interactable

- [x] 3.1 Extended the CI job to launch the built app under Xvfb: [run 34574615287](https://github.com/bhoopathyvm-cloud/smaraAccount/actions/runs/34574615287) shows the app starting (Impeller/OpenGLESSDF backend selected), staying alive for the full 10s check, and being killed cleanly — no crash on launch.
- [x] 3.2 Added `gnome-keyring` + `dbus-x11`, running the app inside `dbus-run-session` with an unlocked keyring (`gnome-keyring-daemon --unlock` / `--start --components=secrets`). The same run above completed the 10s liveness window with the keyring active and no hang — onboarding's actual read/write exercise happens in task 4.1, but nothing here suggests `flutter_secure_storage` blocks with this setup.
- [ ] 3.3 If a working keyring/D-Bus setup doesn't resolve it, add `LinuxOptions(...)` to `FlutterSecureKeyStorage` (`lib/domain/crypto/secure_key_storage.dart`) with whatever configuration the real failure mode calls for, documented with a rationale comment matching the existing `MacOsOptions` comment's style and level of detail.

## 4. Manual smoke check

- [ ] 4.1 Walk through first-launch onboarding on the running Linux build (language selection → currency → first account → guided transaction → recovery phrase) and confirm it completes, the same way it does on macOS. Use CI job logs/screenshots, VNC into the runner, or a real Linux machine if one becomes available — whichever actually lets you see what's happening.
- [ ] 4.2 Close and relaunch the app; confirm the signing identity persists (task 3's secure-storage work actually holds up across a real relaunch, not just a single session).
- [ ] 4.3 If anything beyond secure storage and windowing surfaces as broken (per design.md's risk about scope ballooning), stop and report back rather than continuing to dig — that means this proposal's scope needs revisiting.

## 5. Document what was learned

- [ ] 5.1 Update `design.md`'s Open Questions with what was actually found (real keyring/D-Bus requirements, any `LinuxOptions` needed, whether headless CI validation was sufficient or a real machine was needed) so the next person extending this (release publishing, multi-locale testing) doesn't have to rediscover it.
