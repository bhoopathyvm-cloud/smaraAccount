## Context

`FlutterSecureKeyStorage` already sets `MacOsOptions(usesDataProtectionKeychain: false)` to avoid Data Protection Keychain hangs without Developer Team entitlements. Despite that, acceptance observed `AppLockService.verifyPin` hanging after a same-process "relaunch" on an ad-hoc signed macOS build when reading the PIN record from real secure storage. Locking (set PIN + show Lock screen) works; unlock does not. Signing keys use the same storage abstraction and generally work in acceptance, so the bug may be PIN-specific (key, timing, multiple isolates) or a broader read-after-write edge case exposed by the lock flow.

## Goals / Non-Goals

**Goals:**
- Make PIN verify complete (true/false) without hanging for real users on supported macOS developer and release signing modes the project ships.
- Acceptance: full lock → enter PIN → unlock to main shell, green on macOS, iOS, and Android.
- Prefer one production code path for storage — no acceptance-only fake Keychain.

**Non-Goals:**
- Biometric unlock / Patrol native dialogs.
- Changing PBKDF2 parameters or PIN UX copy unless required by the storage fix.
- CI automation of acceptance.

## Decisions

### Decision 1 — Production-correct fix, not a harness bypass

**Alternatives:** (A) Skip unlock in tests forever; (B) Inject in-memory `SecureKeyStorage` only in acceptance; (C) Fix entitlements/options/signing/storage usage so production verify works.

**Decision: C** (grilled). B would green the suite while leaving users broken on the same ad-hoc builds developers use.

### Decision 2 — Investigate shared storage vs PIN-only

**Decision:** First reproduce hang with a minimal call to `SecureKeyStorage.read` for the PIN key after setPin + simulated relaunch; compare with signing-key reads. Fix at the lowest correct layer (`FlutterSecureKeyStorage`, macOS entitlements, or AppLockService usage). If proper Apple Team signing + `keychain-access-groups` is the correct long-term path, document and implement it for macOS builds the project actually distributes/runs — do not leave ad-hoc as a known-broken unlock platform if developers are expected to use PIN locally.

### Decision 3 — Acceptance DoD is three platforms

**Decision:** Unlock scenario must pass on macOS, iOS (simulator or wipeable physical device), and Android emulator. Same test code, no platform branches.

### Decision 4 — Extend existing lock scenario

**Decision:** Complete the existing `home_and_lock_test.dart` scenario (or split lock vs unlock only if timeouts demand it) rather than a new capability group file, unless file clarity wins.

## Risks / Trade-offs

- **[Risk]** Enabling Data Protection Keychain requires real signing secrets not available to all contributors → **Mitigation:** choose a storage configuration that works for both ad-hoc local runs and release signing; document required Xcode/signing steps in the change's tasks if Team ID becomes mandatory.
- **[Risk]** Fixing Keychain breaks signing-key storage assumptions → **Mitigation:** re-run identity/backup acceptance groups after the storage change.
- **[Risk]** 210k PBKDF2 iterations make unlock slow on device → **Mitigation:** already product behavior; acceptance waits must use long `pumpUntilFound` / timeouts, not fixed 200ms pumps.
- **[Trade-off]** Broader than "add a test" — touches security-sensitive platform config.

## Migration Plan

- Existing installs: PIN records already in secure storage; verify read path remains compatible (same key name / JSON shape).
- If storage backend changes, clear-and-reset PIN may be required once; document in release notes / user guide only if users must re-set PIN.

## Open Questions

- Root cause of hang (entitlement vs plugin vs isolate) — resolve in implementation task 1.
- Whether release notarized builds already work (if yes, narrow fix to ad-hoc/dev configuration parity).
