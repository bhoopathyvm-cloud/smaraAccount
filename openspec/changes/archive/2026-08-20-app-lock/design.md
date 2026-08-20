## Context

An earlier draft's proposal mentioned "optional hide balances in app
switcher snapshot" but the spec never actually carried it as a
requirement — silently dropped between proposal and spec. Restored as
its own requirement (see spec.md) since it's independently useful (a
user may want the snapshot obscured without wanting a full PIN gate)
and mechanically distinct from unlock (it's a platform-level
backgrounding hook, not an authentication check).

## Goals / Non-Goals

**Goals:** Fast unlock; no server; snapshot hiding available
independently of the unlock gate.

**Non-Goals:** Out of scope items in proposal. Building a custom
platform channel per OS beyond what `flutter` and existing plugins
already expose — use whatever the ecosystem's standard mechanism is per
platform, not a bespoke native implementation.

## Decisions

### 1. `local_auth` + `flutter_secure_storage` for the unlock gate
`local_auth` for biometrics, `flutter_secure_storage` (already a
dependency, already used for the signing key) for a PIN hash. Matches
this app's existing crypto-storage pattern rather than introducing a
new one.

### 2. Snapshot hiding is platform-dependent; state that plainly, don't fake it everywhere
This app targets macOS, iOS, Android, and Windows. iOS and Android both
have standard mechanisms (an obscuring view shown on background/iOS, or
`FLAG_SECURE`-equivalent on Android); desktop platforms (macOS, Windows)
don't have an equivalent "app switcher snapshot" concept in the same
way. The setting is offered where a real mechanism exists; where it
doesn't, Settings says so rather than showing a toggle that silently
does nothing.

## Risks / Trade-offs

- [Risk] Snapshot hiding is unavailable or behaves differently across
  the four target platforms. → Mitigation: Decision 2 — state coverage
  plainly per platform rather than implying uniform protection.
- [Risk] Scope creep. → Mitigation: child change stays focused.

## Open Questions

None for v1.

## Correction, found during implementation

### `SnapshotHidingOverlay` crashed with "No Directionality widget found" outside widget tests
Task 1.4's `SnapshotHidingOverlay` wraps the whole app *above*
`MaterialApp.router` (`lib/main.dart`), specifically so its cover is the
last thing rendered before the OS captures the app-switcher snapshot.
That placement means it sits outside any `Directionality` `MaterialApp`
would otherwise provide. Two of its own descendants need one: the
`Stack`'s default `alignment` (`AlignmentDirectional.topStart`), and the
`Icon` in the cover - both throw `No Directionality widget found` the
moment the overlay covers the screen (i.e. as soon as the app is
backgrounded with the setting on). The existing widget test wrapped the
overlay *inside* `MaterialApp`'s `home:`, the opposite of the real
`main.dart` ordering, so it never exercised this path and the crash
only surfaced running the real app (macOS desktop run). Fixed by having
`SnapshotHidingOverlay.build` wrap its own `Stack` in an explicit
`Directionality(textDirection: TextDirection.ltr, child: ...)` -
correct as a `LayoutDirection` choice since this app has no locale/RTL
support yet (English-only) - and giving `Stack` a non-directional
`Alignment.topLeft` since neither child actually needs directional
resolution. Regression test added: builds the overlay with no
`Directionality` ancestor at all (matching `main.dart`'s real ordering)
and asserts `tester.takeException()` is null.
