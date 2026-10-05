## 1. Crypto backend seam

- [ ] 1.1 Add the `CryptoBackend` interface (D1) and a Dart implementation that wraps today's `cryptography` calls. Verify: existing unit tests pass unchanged.
- [ ] 1.2 Move every call site in the design's Context table to `CryptoBackend`; no `lib/` file except the Dart backend imports `package:cryptography`. Verify: a grep check in a unit test, plus `flutter test` green.
- [ ] 1.3 Golden-vector tests against fixed inputs: AES-256-GCM, PBKDF2, HMAC and SHA-256 (RFC test vectors, plus a Books Copy fixture saved by 2026.10.0). Verify: tests pass on the Dart backend.
- [ ] 1.4 Audit tests and code that compare Ed25519 signature bytes, and convert them to verification checks. Verify: `flutter test` green.

## 2. Apple primitives

- [ ] 2.1 In-repo Swift plugin (iOS and macOS): AES-GCM (CryptoKit), PBKDF2 (CommonCrypto), Ed25519 sign, verify and keygen (CryptoKit), HMAC and SHA-256 including a batched hash call. Verify: plugin unit tests on the macOS and iOS simulators.
- [ ] 2.2 Apple `CryptoBackend` over the plugin, selected for iOS and macOS at startup. Verify: the golden-vector tests (1.3) pass on the macOS and iOS simulators against the Apple backend, and a selection unit test passes.
- [ ] 2.3 Debug-only guard: reaching the Dart backend on iOS or macOS throws. Verify: a test that forces the wrong backend fails loudly.
- [ ] 2.4 Performance: chain verification of 10,000 entries on the Apple backend runs no more than 2× today's time. Verify: a measured integration run, with the result noted here.

## 3. Apple TLS transport

- [ ] 3.1 Swift Network.framework byte-stream API: listen (IPv4 and IPv6), connect, send, receive, close; local identity; client certificate requested; a verify block that returns the peer's leaf DER. Verify: plugin tests for loopback connect, and refusal of a certificate that isn't pinned.
- [ ] 3.2 Apple implementation behind the existing `SyncTransport` seam, keeping the length-prefixed JSON framing and the Dart fingerprint pinning; used on iOS and macOS. Verify: the existing transport tests run against it on the macOS simulator.
- [ ] 3.3 Join-by-code session on the Apple transport. Verify: the join-code session tests run on macOS.

## 4. Device identity in the Keychain

- [ ] 4.1 Migrate an existing device's PEM key and certificate into a Keychain identity: import, test-sign, then delete the PEM; on failure keep the PEM and retry next launch. Verify: a test that the fingerprint is unchanged and the PEM is removed only after success.
- [ ] 4.2 New-device identity: Keychain RSA-2048 key, certificate signed by the OS (D4); `basic_utils` not used on Apple. Verify: a test that a new certificate parses, and that its fingerprint pins on a Dart peer.

## 5. Apple HTTPS

- [ ] 5.1 `cupertino_http` client injected into the exchange-rate and quote services on iOS and macOS. Verify: unit test of the injection; manual lookup of a rate and a quote on a Mac.

## 6. Cross-platform verification

- [ ] 6.1 `tool/run_acceptance_tests.sh -d macos` green, and the iOS simulator acceptance run green.
- [ ] 6.2 Company-sync `--employees 2 --ios-only` and the household run green (Apple TLS on every Apple role).
- [ ] 6.3 Mixed-platform pair: Mac or iPhone (Apple TLS) linked with an Android emulator (Dart TLS). Join, sync both ways, and refuse an unknown peer.
- [ ] 6.4 Books Copy round trips: Android → iPhone, iPhone → Android, and a copy saved by 2026.10.0 restored on iPhone and on Mac.
- [ ] 6.5 Real devices: update a Mac and both iPhones from 2026.10.0 in place; links survive and Sync now works without re-pairing.

## 7. Declaration and docs

- [ ] 7.1 Owner confirms the export-compliance classification (exempt; Apple builds use only the operating system's encryption) before the first App Store submission of this change. Record the date here.
- [ ] 7.2 Update the privacy policy's export-compliance section, `docs/release/store-listing/app-privacy.md` and the runbook's export-compliance row. Add an ADR for "Apple builds use only OS cryptography".
- [ ] 7.3 Test that both Info.plist files declare `ITSAppUsesNonExemptEncryption = false` and that the policy states the operating-system-only basis (D6).
- [ ] 7.4 `dart format`, `flutter analyze` and `flutter test` green.
