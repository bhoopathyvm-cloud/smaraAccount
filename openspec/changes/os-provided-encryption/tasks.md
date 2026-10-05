## 1. Crypto backend seam

- [x] 1.1 Add the `CryptoBackend` interface (D1) and a Dart implementation that wraps today's `cryptography` calls. Verify: existing unit tests pass unchanged.
- [x] 1.2 Move every call site in the design's Context table to `CryptoBackend`; no `lib/` file except the Dart backend imports `package:cryptography`. Verify: a grep check in a unit test, plus `flutter test` green.
- [x] 1.3 Golden-vector suite shared by both backends: AES-256-GCM, PBKDF2, HMAC and SHA-256 (RFC test vectors), plus a Books Copy fixture saved by the Dart backend, and Ed25519 sign-on-one, verify-on-the-other. Verify: the suite passes on the Dart backend.
- [x] 1.4 Audit tests and code that compare Ed25519 signature bytes, and convert them to verification checks. Verify: `flutter test` green.
  - Audit result: no test or `lib/` code compared signature bytes (only `isNotEmpty` and Drift's generated row equality); `Ed25519Signing.sign` and `CryptoBackend.ed25519Sign` now document that bytes must never be compared, and the golden suite verifies a reference signature instead.

## 2. Apple primitives

- [~] 2.1 In-repo Swift plugin (iOS and macOS): AES-GCM (CryptoKit), PBKDF2 (CommonCrypto), Ed25519 sign, verify and keygen (CryptoKit), HMAC and SHA-256 including a batched hash call. Verify: plugin unit tests on the macOS and iOS simulators.
  - Done: `packages/smara_apple_crypto` (Swift under `darwin/`, SwiftPM + podspec; Dart wrapper). Open: not yet compiled or run on a macOS or iOS simulator (this session had no Apple toolchain); run `flutter test integration_test/crypto_backend_golden_test.dart -d macos` and on an iOS simulator.
- [~] 2.2 Apple `CryptoBackend` over the plugin, selected for iOS and macOS at startup. Verify: the golden-vector tests (1.3) pass on the macOS and iOS simulators against the Apple backend, and a selection unit test passes.
  - Done: `AppleCryptoBackend`, startup selection in `main.dart`, selection test green (`test/domain/crypto/crypto_backend_selection_test.dart`). Open: the golden suite against the Apple backend on the macOS and iOS simulators (`integration_test/crypto_backend_golden_test.dart`).
- [x] 2.3 Debug-only guard: reaching the Dart backend on iOS or macOS throws. Verify: a test that forces the wrong backend fails loudly.
- [ ] 2.4 Performance: chain verification of 10,000 entries on the Apple backend runs no more than 2× today's time. Verify: a measured integration run, with the result noted here.
  - Prepared: `LedgerChainVerifier` now hashes each chain with one batched `sha256Many` call. Open: the measured run on an Apple device/simulator.

## 3. Apple TLS transport

- [~] 3.1 Swift Network.framework byte-stream API: listen (IPv4 and IPv6), connect, send, receive, close; local identity; client certificate requested; a verify block that returns the peer's leaf DER. Verify: plugin tests for loopback connect, and refusal of a certificate that isn't pinned.
  - Done: `TlsConnections.swift` and the `AppleTls` Dart wrapper; loopback and refusal tests written in `integration_test/apple_tls_loopback_test.dart`. Open: run them on the macOS and iOS simulators.
- [~] 3.2 Apple implementation behind the existing `SyncTransport` seam, keeping the length-prefixed JSON framing and the Dart fingerprint pinning; used on iOS and macOS. Verify: the existing transport tests run against it on the macOS simulator.
  - Done: `TlsSocketFactory` seam under `TlsSyncTransport` (`DartTlsSocketFactory`, `AppleTlsSocketFactory`), `AppleTlsSyncTransport`, platform selection; the Dart half of the Apple path is covered over mocked channels (`test/platform/apple_tls_plugin_test.dart`). Open: the transport exchange and refusal cases against the real socket on the macOS simulator (`integration_test/apple_tls_loopback_test.dart`).
- [~] 3.3 Join-by-code session on the Apple transport. Verify: the join-code session tests run on macOS.
  - Done: `JoinCodeHost` and `SecureJoinCodeLookup` run on the `TlsSocketFactory` seam; the existing join-code session tests pass on the Dart socket; a join-by-code case over the Apple socket is in `integration_test/apple_tls_loopback_test.dart`. Open: run it on macOS.

## 4. Device identity in the Keychain

- [~] 4.1 Apple device identity: Keychain RSA-2048 key, certificate signed by the OS (D4); `basic_utils` not used on Apple; no migration path. Verify: a test that a new certificate parses, and that a Dart peer pins and accepts it.
  - Done: `AppleDeviceCertificateStore` + `x509_der.dart` (Dart assembles the TBSCertificate, the OS signs), `KeychainIdentity.swift`; `test/domain/linked_devices/apple_device_certificate_store_test.dart` proves the certificate parses and a Dart (BoringSSL) peer pins and accepts it, using a fake OS signer. Open: the real Keychain path on a macOS/iOS simulator (first test in `integration_test/apple_tls_loopback_test.dart`).

## 5. Apple HTTPS

- [~] 5.1 `cupertino_http` client injected into the exchange-rate and quote services on iOS and macOS. Verify: unit test of the injection; manual lookup of a rate and a quote on a Mac.
  - Done: `lib/data/http/platform_http_client.dart`, services default to it; `test/data/http/platform_http_client_test.dart` green. Open: manual lookup of a rate and a quote on a Mac.

## 6. Cross-platform verification (release gate for this change)

- [ ] 6.1 `tool/run_acceptance_tests.sh -d macos` green, and the iOS simulator acceptance run green.
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
