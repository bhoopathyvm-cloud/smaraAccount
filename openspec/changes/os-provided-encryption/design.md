## Context

See proposal.md for the reasons. These are the facts that shape the approach.

| Use | Today (all platforms) | File(s) |
|---|---|---|
| Books Copy file encryption | `cryptography` AES-256-GCM, key from PBKDF2 | `domain/backup/books_copy_file.dart` |
| App-lock PIN hash | `cryptography` PBKDF2 | `domain/lock/app_lock_service.dart` |
| Ledger signing | `cryptography` Ed25519 | `domain/crypto/ed25519_signing.dart`, `signing_key_service.dart` |
| Join-code proof | `cryptography` HMAC | `domain/linked_devices/join_code_crypto.dart` |
| Hashes (entries, receipts, pins, books-set id) | `cryptography` SHA-256 | `entry_canonical_hash.dart`, `claim_receipt_store.dart`, `certificate_pinning.dart`, `peer_discovery.dart`, `join_qr_payload.dart`, `device_certificate_store.dart` |
| Device TLS identity | `basic_utils` RSA key pair and self-signed X.509 cert, PEM in secure storage | `persisting_device_certificate_store.dart` |
| Device sync and join TLS | `dart:io` `SecureSocket` / `SecureServerSocket` (BoringSSL), pinned by cert SHA-256 | `peer_sync/tls_sync_transport.dart`, `data/peer_sync/socket_sync_transport.dart`, `linked_devices/join_code_session.dart` |
| HTTPS lookups | `package:http` (`dart:io` HttpClient, BoringSSL) | `data/exchange_rate_service.dart`, `data/instrument_quote_service.dart` |

Peers on other platforms (Android, Windows, Linux) keep these implementations. So an Apple device must keep speaking the same TLS, framing, pinning and file formats.

## Goals / Non-Goals

**Goals:**
- On iOS and macOS, every call that encrypts, derives a key, signs, verifies, authenticates or hashes goes through Apple frameworks. So do all TLS, and all key and certificate generation.
- Apple builds fail loudly rather than fall back to an app-provided implementation.
- Interoperability with other platforms and with existing saved data and links stays unchanged.

**Non-Goals:**
- Changing Android, Windows or Linux.
- Changing file formats, the sync wire protocol, or the pinning model.
- Removing the BoringSSL copy that ships inside the Flutter engine and Dart runtime. See Risks.

## Decisions

### D1. One explicit crypto backend seam, not a silent plugin
- **Seam:** add a `CryptoBackend` interface with the operations the app needs:
  - `aesGcmEncrypt/Decrypt`;
  - `pbkdf2HmacSha256`;
  - `ed25519` generate, sign and verify;
  - `hmacSha256`;
  - `sha256`, and a batched `sha256Many` for chain verification.
- **Implementations:** a Dart one (today's `cryptography` calls) for Android, Windows and Linux, and an Apple one backed by a small in-repo Swift plugin using CryptoKit and CommonCrypto.
- **Wiring:** chosen once at startup from the platform and injected through the existing provider tree. Call sites stop importing `package:cryptography` directly.
- *Alternative considered:* `cryptography_flutter`, which routes `package:cryptography` to CryptoKit. Rejected, because it falls back to its pure-Dart code for any algorithm or parameter set it doesn't accelerate. That breaks "only the operating system" without telling anyone, and the fallback can't be ruled out by a test.

### D2. Primitives on Apple

| Operation | Apple API | Compatibility note |
|---|---|---|
| AES-256-GCM | CryptoKit `AES.GCM` | Same nonce, tag and AAD layout as today's `SecretBox` concatenation. Covered by golden-file tests. |
| PBKDF2-HMAC-SHA256 | CommonCrypto `CCKeyDerivationPBKDF` | Same iterations and salt, so output is identical. |
| Ed25519 | CryptoKit `Curve25519.Signing` with a raw 32-byte seed | Same keys (RFC 8032 seed). Signatures are hedged, not deterministic, but verify everywhere; no test may compare signature bytes. |
| HMAC-SHA256, SHA-256 | CryptoKit `HMAC<SHA256>`, `SHA256` | Identical output. |

Platform calls are asynchronous method-channel calls. Chain verification already hashes many entries, so it uses the batched call to keep channel overhead small.

### D3. TLS on Apple through Network.framework, with Dart keeping the framing
- **Native side:** the Swift plugin exposes listen, connect, send, receive and close over `NWListener` / `NWConnection`, with TLS options:
  - local identity: `sec_protocol_options_set_local_identity`;
  - TLS 1.2 minimum, so Dart's BoringSSL peers interoperate;
  - client certificate requested by the listener;
  - a `sec_protocol_options_set_verify_block` that hands the peer's leaf certificate DER back to Dart.
- **Dart side:** decides pinning in its existing SHA-256 fingerprint check, so pinning logic stays in one place and keeps its current refusal reasons. Dart's `TlsSyncTransport` and the join-code session keep their length-prefixed JSON framing over a byte stream. Only the socket underneath changes, behind the existing `SyncTransport` seam.
- **Listening:** both IPv4 and IPv6, as now (#226).
- *Alternative considered:* URLSession WebSockets. Rejected, because it changes the wire protocol and breaks peers on other platforms.

### D4. Device TLS identity in the Keychain
- **Existing devices:** at first launch on this version, import the stored RSA private key with `SecKeyCreateWithData` and the certificate DER as a Keychain identity (this-device-only, not synchronizable). Then delete the PEM key from secure storage. The fingerprint is unchanged, so pins and links survive.
- **New devices:**
  - generate an RSA-2048 key with `SecKeyCreateRandomKey` (in the Keychain);
  - Dart builds the X.509 TBSCertificate DER (plain ASN.1 encoding, no cryptography);
  - the OS signs it with `SecKeyCreateSignature` (`rsaSignatureMessagePKCS1v15SHA256`);
  - Dart assembles the certificate.

  `basic_utils` key and certificate generation is no longer used on Apple.
- *Alternative considered:* switching to P-256 keys. Not needed for the goal, and it would change the certificate type that other platforms' peers pin.

### D5. HTTPS on Apple through URLSession
- Use `cupertino_http` as the `http.Client` for the exchange-rate and quote services on iOS and macOS, injected where those services are constructed.
- Requests, timeouts and offline handling stay as they are.

### D6. Keep the declaration honest
- A unit test asserts the Apple backend is selected for `TargetPlatform.iOS` and `TargetPlatform.macOS`.
- A debug-only startup check fails if a Dart crypto implementation is reached on those platforms.
- A test checks both Info.plist files declare `ITSAppUsesNonExemptEncryption = false`, and that the privacy policy's export-compliance section states the operating-system-only basis.

## Risks / Trade-offs

- **BoringSSL is still inside the binary.** The Flutter engine and Dart runtime link BoringSSL for `dart:io` even when the app never calls it. Apple's question is about the encryption the app uses or implements. After this change the app calls none of it on Apple platforms, but whether shipping an unused copy matters is a judgement for the owner. → The owner confirms the classification (task 7.1) before submitting a build that declares `false`.
- **Native code surface.** Swift TLS and Keychain code is new and security-relevant. → Keep the plugin small, unit-test it on macOS and iOS simulators, and repeat the real-device sync runs: household and company, plus a Mac↔Android pair.
- **Channel overhead** on hashing-heavy paths. → Batched hashing; measure chain verification on 10,000 entries against today's time.
- **Migration of existing keys** has to run once and atomically. → Import first, verify the identity can sign, then delete the PEM. On failure keep the PEM and retry on the next launch; never regenerate, which would break pins.
- **Signature determinism.** Any test or code that compares Ed25519 signature bytes breaks on Apple. → Audit and convert those to verification checks.
