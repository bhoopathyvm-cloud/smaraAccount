# smara_apple_crypto

In-repo Flutter plugin for iOS and macOS. It exists so that the App Store
builds of Smara encrypt only through Apple's operating system (OpenSpec
change `os-provided-encryption`, ADR 0005):

| Channel | Apple framework | Used for |
|---|---|---|
| `smara_apple_crypto/crypto` | CryptoKit (`AES.GCM`, `Curve25519.Signing`, `HMAC<SHA256>`, `SHA256`), CommonCrypto (`CCKeyDerivationPBKDF`) | Books Copy files, app-lock PIN, ledger signing, join codes, hashes |
| `smara_apple_crypto/identity` | Security framework (`SecKeyCreateRandomKey`, `SecKeyCreateSignature`, Keychain) | The device's TLS key pair and self-signed certificate |
| `smara_apple_crypto/tls` (+ `tls_events`) | Network framework (`NWListener`, `NWConnection`, `sec_protocol_options`) | Linked-device sync and join-by-code TLS |

The Dart side (`lib/`) is a thin typed wrapper over the method channels.
Pinning decisions stay in the app: the TLS verify block hands the peer's leaf
certificate (DER plus its SHA-256 fingerprint, computed by CryptoKit) back to
Dart and waits for its answer.

Android, Windows and Linux never load this plugin; they keep the app's Dart
implementations.
