## Purpose

Decide which component performs cryptography in the App Store builds (iOS and macOS). The goal is that the app encrypts only through Apple's operating system and its "uses only exempt encryption" declaration is accurate, while staying fully interoperable with other platforms and with data saved earlier.

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

#### Scenario: Unknown certificate is still refused
- **WHEN** a device whose certificate fingerprint isn't pinned connects to an iPhone
- **THEN** the iPhone refuses the connection and no data is exchanged

### Requirement: Existing device identities and links survive the switch
An iOS or macOS device updated to this version SHALL keep the TLS identity whose fingerprint its linked devices already pinned. Linked devices SHALL NOT need to pair again. A device without an identity SHALL get a new one created through the operating system, with its private key kept in the Keychain and marked as never leaving the device.

#### Scenario: Update keeps the link
- **WHEN** a Mac linked to two iPhones updates to this version
- **THEN** its certificate fingerprint is unchanged and Sync now with both iPhones works without re-pairing

### Requirement: Saved data stays compatible across platforms and versions
Data that crosses devices or versions SHALL be byte-compatible regardless of which platform produced it:
- Books Copy files;
- join codes;
- certificate fingerprints;
- entry and receipt hashes.

A ledger signature made on any platform SHALL verify on every other platform. Signatures need not be byte-identical, because the operating system may add randomness to signing.

#### Scenario: Copy from Android restores on iPhone
- **WHEN** a Books Copy saved on Android is restored on an iPhone with the correct passphrase
- **THEN** the iPhone restores every entry, and its signatures verify

#### Scenario: Copy saved by an earlier version still restores
- **WHEN** a Books Copy saved by version 2026.10.0 is restored on an iPhone running this version
- **THEN** it restores exactly as before

#### Scenario: Wrong passphrase still fails safely
- **WHEN** a Books Copy is restored with a wrong passphrase on an iPhone
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
