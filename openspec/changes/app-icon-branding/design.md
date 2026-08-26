## Context

Found during App Store/Play Store distribution planning (2026-08-27). Every platform target was scaffolded (`flutter create`) with its default template icon and never revisited — same situation as `android-release-signing`'s debug-keystore default, just for artwork instead of signing.

## Goals / Non-Goals

**Goals:**
- One real icon, generated consistently across every target platform from a single source image.
- No per-platform hand-maintained icon variants that can drift apart.

**Non-Goals:**
- Designing the app's broader visual identity (color palette, typography) beyond the icon itself.
- Adaptive-icon-specific Android theming (Material You dynamic color) — a nice-to-have follow-up, not required for a first store submission.
- A launch/splash screen redesign — separate concern from the icon, not addressed here.

## Decisions

### 1. `flutter_launcher_icons` generates every variant from one master image

**Options:** (A) Hand-export each required resolution per platform; (B) `flutter_launcher_icons` (the standard Flutter tool for this) driven by one master PNG/SVG.

**Decision: B.** Every platform's exact required icon sizes (iOS's dozen-plus `Icon-App-*` sizes, macOS's set, Android's mipmap densities plus optional adaptive-icon layers) are generated mechanically and consistently from one source file, the same "generate, don't hand-maintain" principle this project's Golden Rule #2 already applies to Drift codegen.

### 2. The master icon is a supplied or separately-designed input, not conjured from nothing

This change's own implementation is blocked on having a real 1024×1024+ source image. That image either comes from the project owner directly, or gets designed as its own small task (visual design, not code) before `flutter_launcher_icons` has anything to generate from. Tracked explicitly as a blocking prerequisite in `tasks.md`, not silently assumed.

## Risks / Trade-offs

- **[Risk]** A generated icon variant looks wrong at a specific size (e.g. the iOS 20×20 notification-size icon becomes illegible if the source design is too detailed) → **Mitigation:** visually spot-check the generated icon set at its smallest sizes on-device, not just the 1024×1024 master.
- **[Trade-off]** Adds one dev dependency (`flutter_launcher_icons`) — acceptable; it's a build-time-only tool, not shipped in the app binary.

## Migration Plan

1. Obtain or design the master icon (blocking prerequisite).
2. Add `flutter_launcher_icons` as a dev dependency; configure it (master image path, per-platform generation flags).
3. Run it; review the generated assets across all three platforms.
4. Clean build each platform; confirm the new icon shows in the app switcher/dock/home screen.
5. Rollback = revert the generated asset files and `pubspec.yaml` change; no data migration.

## Open Questions

- Who supplies the master icon, and what it should depict — a literal mark evoking "Smara" (remembrance/memory), a ledger/notebook motif, or something else. Blocks task 1 below until resolved.
