# Letting the Operating System Do the Encryption

**Apple asks one question about encryption before an app ships. Answering it honestly changed how Smara Account is built.**

*One developer's experience, not legal advice.*

App Store Connect asks: *does your app use encryption beyond what Apple's operating system provides?* Version 2026.10.0 added encrypted Books Copy files and encrypted device sync, and my old "no" no longer matched the code.

## What the question really asks

It isn't "is the app secure?" It's "who wrote the encryption?". An app that only calls the operating system's encryption is exempt. An app that ships its own has extra export paperwork. The setting `ITSAppUsesNonExemptEncryption` should be true to the code. I chose to make the code match the simple answer.

## Where our own crypto was hiding

More places than I expected: Books Copy encryption, the app-lock PIN, ledger signing, device-sync TLS, each device's certificate, and even HTTPS lookups for exchange rates.

## The design: one door

There is now one interface, `CryptoBackend`, and it is the only way the app encrypts, signs, hashes or derives a key. Android, Windows and Linux use the Dart implementation behind it. iOS and macOS use a small Swift plugin that calls Apple's own frameworks. In a debug build, reaching the Dart one on Apple *throws*, and a test fails if any other file imports a crypto library.

I rejected a package that routes our calls to Apple automatically, because it falls back to Dart silently. A rule that says "only the operating system" can't allow a silent fallback.

## Staying compatible

The app syncs iPhone, Mac and Android, so both sides must agree on every byte. Formats and the sync protocol stayed fixed; only the engine changed. The same test vectors run against both backends, and a Books Copy made on an Android tablet restores on an iPhone and back. One surprise: Apple's Ed25519 signatures differ on every run, so tests must verify signatures, never compare them.

## Challenges

- A Network framework option I used doesn't exist on iOS or macOS.
- Two handle counters overwrote each other.
- Events from Swift arrived before Dart was listening.
- Closing a connection dropped its last message.
- Mac Keychain prompts, solved with the data-protection keychain and team-signed debug builds.
- A "No route to host" that was just a missing Local Network permission.

## Lessons

Treat the question as a design constraint early. Put crypto behind one seam. Never allow a silent fallback. Keep formats fixed while swapping the engine. Test on real devices.

## One thing I can't remove

The Flutter engine still contains BoringSSL, which `dart:io` uses. Our code doesn't call it on Apple, but removing it would need a custom engine build, which I don't think is worth maintaining. The same copy ships in every Flutter iOS app. So I record, before each submission, that I made this call knowingly.
