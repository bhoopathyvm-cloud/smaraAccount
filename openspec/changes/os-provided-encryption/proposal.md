## Why

App Store Connect's export-compliance form asks whether the app contains encryption beyond what Apple's operating system provides. Today it does. Smara compiles its own implementations into the app:
- AES-256-GCM, Ed25519, HMAC and PBKDF2 from the pure-Dart `cryptography` package;
- TLS from Dart's built-in BoringSSL, used for linked-device sync, join-by-code and every HTTPS lookup;
- RSA key and certificate generation from `basic_utils`.

Since 2026.10.0 added encrypted Books Copy files and encrypted device sync, the app's declaration of `ITSAppUsesNonExemptEncryption = false` no longer matches Apple's definition. The owner doesn't want the app in that category, which brings export documentation and reporting duties. On iOS and macOS the app should therefore encrypt only through Apple's own frameworks, so the exempt declaration is true again.

## What Changes

- On iOS and macOS, every cryptographic operation goes through Apple's operating system (CryptoKit / CommonCrypto / Security framework):
  - AES-256-GCM (Books Copy files, claim receipts);
  - PBKDF2 (Books Copy passphrase, app-lock PIN);
  - Ed25519 (ledger signing);
  - SHA-256 and HMAC (hashes, join codes, certificate pins).

  The app no longer uses a Dart implementation of these on Apple platforms.
- On iOS and macOS, linked-device sync and join-by-code run over TLS from Apple's Network framework instead of Dart's `SecureSocket` / `SecureServerSocket`. Pinning by certificate fingerprint and the TLS wire format stay the same, so an iPhone or Mac still syncs with Android, Windows and Linux peers that keep Dart's TLS.
- On iOS and macOS, each device's TLS identity (key pair and self-signed certificate) is created and used through the Security framework, with the private key kept in the Keychain.
- On iOS and macOS, HTTPS lookups (exchange rates, quotes, instrument search) use Apple's URL loading system instead of Dart's HTTP client.
- **Cross-platform operation is the primary constraint.** Apple builds and the Android, Windows and Linux builds keep one Books Copy format, one sync wire protocol and one pinning model, so every combination of devices can join, sync and restore copies. The app hasn't reached users yet, so there is no saved data or linked install to migrate.
- The privacy policy's export-compliance section and the store export-compliance notes describe the new basis for the exempt declaration. `ITSAppUsesNonExemptEncryption` stays `false` and is kept honest by a check.
- Android, Windows and Linux keep their current Dart implementations. Apple's question applies only to the App Store builds.

## Capabilities

### New Capabilities
- `platform-cryptography`: on Apple platforms, which component may perform encryption, how compatibility with other platforms and with existing data is kept, and how the export-compliance declaration stays consistent with the code.

### Modified Capabilities

## Impact

- **Crypto call sites:**
  - `lib/domain/backup/books_copy_file.dart`
  - `lib/domain/lock/app_lock_service.dart`
  - `lib/domain/crypto/ed25519_signing.dart`, `signing_key_service.dart`, `entry_canonical_hash.dart`
  - `lib/domain/linked_devices/join_code_crypto.dart`
  - `lib/data/repositories/claim_receipt_store.dart`
  - SHA-256 users: `certificate_pinning.dart`, `peer_discovery.dart`, `join_qr_payload.dart`, `device_certificate_store.dart`
- **TLS:**
  - `lib/domain/peer_sync/tls_sync_transport.dart`
  - `lib/data/peer_sync/socket_sync_transport.dart`
  - `lib/domain/linked_devices/join_code_session.dart`
  - `lib/domain/linked_devices/persisting_device_certificate_store.dart`
- **HTTPS:**
  - `lib/data/exchange_rate_service.dart`
  - `lib/data/instrument_quote_service.dart`
- **New native code:** a small iOS/macOS plugin (Swift) for Network-framework TLS and Keychain identities.
- **New dependencies:** `cryptography_flutter` (or equivalent), which routes `cryptography` to CryptoKit, and `cupertino_http`, which provides URLSession for `package:http`.
- **Docs:**
  - `pages/open-source/smara-account/privacy-policy.md` (export-compliance section)
  - `docs/release/store-listing/app-privacy.md`
  - `docs/release/store-release-runbook.md`
  - a new ADR
- **Tests:** golden-vector tests shared by both backends, and a cross-platform matrix: iPhone and Mac paired with Android, both directions, for join, sync, Claimant scoping, unknown-peer refusal and Books Copy restore. Windows and Linux run the same Dart code as Android; a Linux desktop peer is included where available.
- **Legal confirmation:** the owner confirms the exempt classification before the next App Store submission. This change makes the code match the declaration; it isn't legal advice.
