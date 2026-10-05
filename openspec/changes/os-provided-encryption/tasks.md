## 1. Crypto backend seam

- [x] 1.1 Add the `CryptoBackend` interface (D1) and a Dart implementation that wraps today's `cryptography` calls. Verify: existing unit tests pass unchanged.
- [x] 1.2 Move every call site in the design's Context table to `CryptoBackend`; no `lib/` file except the Dart backend imports `package:cryptography`. Verify: a grep check in a unit test, plus `flutter test` green.
- [x] 1.3 Golden-vector suite shared by both backends: AES-256-GCM, PBKDF2, HMAC and SHA-256 (RFC test vectors), plus a Books Copy fixture saved by the Dart backend, and Ed25519 sign-on-one, verify-on-the-other. Verify: the suite passes on the Dart backend.
- [x] 1.4 Audit tests and code that compare Ed25519 signature bytes, and convert them to verification checks. Verify: `flutter test` green.
  - Audit result: no test or `lib/` code compared signature bytes (only `isNotEmpty` and Drift's generated row equality); `Ed25519Signing.sign` and `CryptoBackend.ed25519Sign` now document that bytes must never be compared, and the golden suite verifies a reference signature instead.

## 2. Apple primitives

- [x] 2.1 In-repo Swift plugin (iOS and macOS): AES-GCM (CryptoKit), PBKDF2 (CommonCrypto), Ed25519 sign, verify and keygen (CryptoKit), HMAC and SHA-256 including a batched hash call. Verify: plugin unit tests on the macOS and iOS simulators.
  - Verified 2026-10-05 (fix branch): compiles for iOS and macOS after removing a non-existent Network API call; `integration_test/crypto_backend_golden_test.dart` 12/12 on macOS and on the iOS 26.5 simulator (iPhone 17 Pro Max).
- [x] 2.2 Apple `CryptoBackend` over the plugin, selected for iOS and macOS at startup. Verify: the golden-vector tests (1.3) pass on the macOS and iOS simulators against the Apple backend, and a selection unit test passes.
  - Verified 2026-10-05: golden suite 12/12 against the Apple backend on macOS and the iOS simulator (Books Copy fixture now embedded so it is readable on iOS); selection test green.
- [x] 2.3 Debug-only guard: reaching the Dart backend on iOS or macOS throws. Verify: a test that forces the wrong backend fails loudly.
- [x] 2.4 Performance: chain verification of 10,000 entries on the Apple backend runs no more than 2× today's time. Verify: a measured integration run, with the result noted here.
  - Verified 2026-10-05 (`integration_test/crypto_backend_perf_test.dart`, the chain verifier's crypto: one batched SHA-256 over 10,000 canonical entries plus one Ed25519 verify each): iOS 26.5 simulator apple=1171 ms vs dart=24019 ms (ratio 0.05); macOS apple=1123 ms vs dart=25136 ms (ratio 0.04). Well within 2x; CryptoKit's native Ed25519 outweighs the per-call channel cost.

## 3. Apple TLS transport

- [x] 3.1 Swift Network.framework byte-stream API: listen (IPv4 and IPv6), connect, send, receive, close; local identity; client certificate requested; a verify block that returns the peer's leaf DER. Verify: plugin tests for loopback connect, and refusal of a certificate that isn't pinned.
  - Verified 2026-10-05: `apple_tls_loopback_test.dart` 4/4 on macOS and the iOS simulator after fixing: verifier-handle collision between connect and listen, early bytes dropped before the connect reply, close() hanging on a paused StreamIterator, last frame discarded by an abrupt cancel, and a TLS-1.3-unaware refusal assertion. Regression tests in `test/platform/apple_tls_plugin_test.dart` fail on the old code.
- [x] 3.2 Apple implementation behind the existing `SyncTransport` seam, keeping the length-prefixed JSON framing and the Dart fingerprint pinning; used on iOS and macOS. Verify: the existing transport tests run against it on the macOS simulator.
  - Verified 2026-10-05: two-device exchange (100 kB message) over `TlsSyncTransport` on the Apple socket on macOS and iOS; Apple<->Dart interop in both directions in `integration_test/cross_stack_tls_test.dart` (6/6 on macOS and iOS).
- [x] 3.3 Join-by-code session on the Apple transport. Verify: the join-code session tests run on macOS.
  - Verified 2026-10-05: join-by-code over the Apple socket on macOS and iOS, and Apple host <-> Dart joiner both ways (cross_stack_tls_test).

## 4. Device identity in the Keychain

- [x] 4.1 Apple device identity: Keychain RSA-2048 key, certificate signed by the OS (D4); `basic_utils` not used on Apple; no migration path. Verify: a test that a new certificate parses, and that a Dart peer pins and accepts it.
  - Verified 2026-10-05: Keychain identities on macOS now use the data-protection keychain (the legacy keychain blocked TLS signing on per-signature "allow access" dialogs); macOS Debug/Profile are team-signed with a Mac development profile (this Mac registered). A Dart (BoringSSL) peer pins and accepts the Apple certificate in cross_stack_tls_test.

## 5. Apple HTTPS

- [~] 5.1 `cupertino_http` client injected into the exchange-rate and quote services on iOS and macOS. Verify: unit test of the injection; manual lookup of a rate and a quote on a Mac.
  - Done: `lib/data/http/platform_http_client.dart`; `cupertino_http` 2.4 -> 3.1 (native-assets build, so Flutter no longer falls back to CocoaPods). Verified 2026-10-05: live rate lookup on a Mac over URLSession (CupertinoClient, HTTP 200). Open: a quote lookup on a Mac.

## 6. Cross-platform verification (release gate for this change)

- [ ] 6.1 `tool/run_acceptance_tests.sh -d macos` green, and the iOS simulator acceptance run green.
  - macOS half verified 2026-10-05 on the fix branch: `tool/run_acceptance_tests.sh -d macos` 46 passed, 1 skipped, no keychain dialogs (team-signed debug build). Open: the iOS simulator acceptance run.
- [ ] 6.2 Company-sync `--employees 2 --ios-only` and the household run green (Apple TLS on every Apple role).
- [ ] 6.3 Matrix, join and sync both ways: iPhone ↔ Android, Mac ↔ Android, iPhone ↔ Mac, with an Android emulator as the Dart-TLS peer. Verify: each pair joins by QR and by code, syncs entries both ways, and every signature verifies on both sides.
- [ ] 6.4 Company run with mixed platforms: a Mac Owner, an Android Claimant and an iPhone Claimant. Verify: claims, decisions and Claimant scoping hold on each device.
- [ ] 6.5 Unknown-peer refusal in both directions: an unpinned Android device to an iPhone, and an unpinned iPhone to Android. Verify: the connection is refused and nothing is exchanged.
- [ ] 6.6 Books Copy round trips: Android → iPhone, iPhone → Android, Mac → Android; a wrong passphrase is refused on each.
- [ ] 6.7 Real devices: the Mac and both iPhones, plus an Android emulator, rerun join and sync from fresh installs.
- [ ] 6.8 Linux desktop peer, where a Linux machine or VM is available: joins and syncs with a Mac. Otherwise note it as covered by the shared Dart implementation (6.3).

## 7. Declaration and docs

- [ ] 7.1 Owner confirms the export-compliance classification (exempt; Apple builds use only the operating system's encryption) before the first App Store submission of this change. Record the date here.
- [x] 7.2 Update the privacy policy's export-compliance section, `docs/release/store-listing/app-privacy.md` and the runbook's export-compliance row. Add an ADR for "Apple builds use only OS cryptography".
- [x] 7.3 Test that both Info.plist files declare `ITSAppUsesNonExemptEncryption = false` and that the policy states the operating-system-only basis (D6).
- [~] 7.4 `dart format`, `flutter analyze` and `flutter test` green.
  - `dart format` and `flutter analyze` clean; `flutter test` green on Linux except `tls_sync_transport_test.dart`'s dual-stack case, which needs IPv6 and the CI container has none (pre-existing environment limit, unrelated to this change). Re-confirm on a machine with IPv6 / in CI.
