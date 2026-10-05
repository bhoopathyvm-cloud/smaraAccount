## Purpose

Decide which component performs cryptography in the App Store builds (iOS and macOS). The goal is that the app encrypts only through Apple's operating system and its "uses only exempt encryption" declaration is accurate, while every platform keeps working with every other.

## ADDED Requirements

### Requirement: Apple builds encrypt only through the operating system
On iOS and macOS, every cryptographic operation the app performs SHALL be carried out by an Apple operating-system framework:
- encryption and decryption;
- key derivation;
- signing and verification;
- message authentication;
- hashing;
- TLS;
- key and certificate generation.

The app SHALL NOT perform any of these through a cryptographic implementation it ships itself. This covers both Dart implementations and libraries compiled into the app.

#### Scenario: Books Copy saved on an iPhone
- **WHEN** the user saves a Books Copy on an iPhone or Mac
- **THEN** the file's key derivation and encryption run in Apple's frameworks, and no app-provided cipher implementation is invoked

#### Scenario: Startup guard in Apple builds
- **WHEN** an iOS or macOS build starts
- **THEN** the cryptography backend in use is the operating system's. A debug or test build that would fall back to an app-provided implementation fails loudly instead of encrypting silently.

### Requirement: Device-to-device TLS on Apple platforms uses the operating system
On iOS and macOS, linked-device sync and join-by-code connections SHALL be established, accepted and encrypted by Apple's TLS implementation. The behaviour SHALL stay the same:
- each device presents its own certificate;
- each side accepts only peers whose certificate fingerprint is pinned, rejecting any other with the same refusal reasons as today;
- connections listen on both IPv4 and IPv6.

#### Scenario: iPhone syncs with an Android peer
- **WHEN** an iPhone (operating-system TLS) and an Android tablet (its existing TLS) are linked and tap Sync now on the same Wi-Fi
- **THEN** they connect, verify each other's pinned certificate, and exchange entries exactly as two devices on the same platform do

#### Scenario: Unknown certificate is refused on every platform
- **WHEN** a device whose certificate fingerprint isn't pinned connects to an iPhone, or an iPhone that isn't pinned connects to an Android device
- **THEN** the receiving device refuses the connection and no data is exchanged

### Requirement: Device identities on Apple platforms are created by the operating system
On iOS and macOS, a device's TLS identity SHALL be created by the operating system: its key pair and its self-signed certificate. The private key SHALL be kept in the Keychain and marked as never leaving the device. The certificate SHALL be one that peers on every other platform can pin and verify.

#### Scenario: New iPhone identity pins on Android
- **WHEN** an iPhone creates its identity and is joined from an Android tablet
- **THEN** the tablet pins the iPhone's certificate fingerprint, and later syncs verify it

### Requirement: Every platform interoperates with every other
Cross-platform operation is the primary constraint. Apple builds (iOS, macOS) and the other builds (Android, Windows, Linux) SHALL interoperate in every combination, for:
- joining by QR or code;
- linked-device sync in both directions, including scoped Claimant sync;
- refusing an unknown peer;
- Books Copy save and restore;
- ledger signature verification.

These SHALL interoperate through:
- one shared Books Copy file format;
- one shared sync wire protocol and certificate-pinning model;
- byte-identical hashes, join codes and certificate fingerprints, whatever platform produced them.

A ledger signature made on any platform SHALL verify on every other platform. Signatures need not be byte-identical, because the operating system may add randomness to signing.

#### Scenario: iPhone and Android sync both ways
- **WHEN** an iPhone and an Android phone are linked and each records an entry
- **THEN** after Sync now each device has both entries, and every signature verifies on both

#### Scenario: Mac Owner with Android and Windows peers
- **WHEN** a Mac Owner joins an Android employee phone and a Windows bookkeeping PC
- **THEN** all three join and sync with each other, and Claimant scoping holds on the Android phone

#### Scenario: Copy from Android restores on iPhone, and back
- **WHEN** a Books Copy saved on Android is restored on an iPhone with the correct passphrase, and a copy saved on that iPhone is restored on Android
- **THEN** both restores bring back every entry, and the signatures verify

#### Scenario: Wrong passphrase fails the same on every platform
- **WHEN** a Books Copy is restored with a wrong passphrase on any platform
- **THEN** the restore is refused and the device's books are untouched

### Requirement: HTTPS lookups on Apple platforms use the operating system
On iOS and macOS, the app's network lookups SHALL go through Apple's URL loading system. These are reference exchange rates, market quotes and instrument search. Requests and responses SHALL be unchanged, and so SHALL the timeout and offline behaviour.

#### Scenario: Exchange rate lookup on a Mac
- **WHEN** the reference-rate lookup is on and a cross-currency transfer is entered on a Mac
- **THEN** the rate is fetched over the operating system's HTTPS and shown as before

### Requirement: The export-compliance declaration matches the code
The iOS and macOS builds SHALL declare `ITSAppUsesNonExemptEncryption = false` only while the requirements above hold. The privacy policy's export-compliance section and the store export-compliance notes SHALL state the basis for that declaration: Apple builds use only the operating system's encryption.

#### Scenario: Declaration and policy agree
- **WHEN** a release is prepared
- **THEN** both Info.plist files say `false`, and the public privacy policy explains that the Apple builds encrypt only through Apple's operating system
