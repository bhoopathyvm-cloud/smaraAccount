## 1. Master icon (blocking prerequisite)

- [ ] 1.1 Resolve `design.md`'s Open Question: obtain or design a 1024×1024+ master icon

## 2. Generate platform icons

- [ ] 2.1 Add `flutter_launcher_icons` as a dev dependency; configure it with the master icon path
- [ ] 2.2 Run it to regenerate `ios/`, `macos/`, and `android/` icon assets
- [ ] 2.3 Delete any leftover default-Flutter icon files it doesn't overwrite

## 3. Verify

- [ ] 3.1 Clean build on iOS Simulator: home-screen icon shows the new artwork
- [ ] 3.2 Clean build on macOS: Dock/Finder icon shows the new artwork
- [ ] 3.3 Clean build on Android emulator: launcher icon shows the new artwork
- [ ] 3.4 Spot-check legibility at the smallest generated size per platform (e.g. iOS notification-size icon)
