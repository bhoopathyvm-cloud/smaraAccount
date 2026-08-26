## Why

`ios/Runner/Assets.xcassets/AppIcon.appiconset/`, `macos/Runner/Assets.xcassets/AppIcon.appiconset/`, and every `android/app/src/main/res/mipmap-*/ic_launcher.png` still contain the default `flutter create` template icon (the blue Flutter "F" mark) — confirmed by inspecting the actual image files. Both Apple and Google review guidelines expect a distinctive app icon; shipping the framework's own placeholder reads as unfinished and risks review friction, independent of it simply not representing SMARA Account.

## What Changes

- Produce (or receive from the user) one master icon — a square, high-resolution (at minimum 1024×1024) source image reflecting SMARA Account's identity, consistent with the "Smara" (remembrance/memory) naming story already used on the project website.
- Add `flutter_launcher_icons` as a dev dependency and configure it to generate every required per-platform, per-resolution icon variant from that one master image — not hand-resized PNGs per platform, which drift out of sync over time.
- Run it to replace every default-Flutter icon asset across `ios/`, `macos/`, and `android/`.
- Verify each platform's launcher/home-screen/dock icon shows the new artwork after a clean build.

## Capabilities

### New Capabilities
- `app-icon-branding`: SMARA Account ships a real, distinctive app icon on every target platform, generated from one source-of-truth master image.

### Modified Capabilities
- (none — no product behavior changes; this is an asset/branding change only)

## Impact

- `ios/Runner/Assets.xcassets/AppIcon.appiconset/`
- `macos/Runner/Assets.xcassets/AppIcon.appiconset/`
- `android/app/src/main/res/mipmap-*/ic_launcher.png` (and adaptive-icon foreground/background if configured)
- `pubspec.yaml` (new dev dependency + `flutter_launcher_icons` config)
- A new master icon source asset needs to be supplied or designed before this change can be implemented — see `design.md`'s Open Questions
