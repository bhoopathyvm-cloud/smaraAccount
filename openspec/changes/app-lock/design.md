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
