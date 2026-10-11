# Who Wrote the Encryption? Adapting Smara Account to Apple's Rules

**Apple asks one question about encryption before an app ships. My AI assistant wrote the code that answers it; the decision about how to answer was mine.**

I don't write Smara Account's code by hand. An AI coding assistant builds it, and I make the decisions. This post is about one decision, and what it took for the code to follow.

App Store Connect asks: *does your app use encryption beyond what Apple's operating system provides?* Version 2026.10.0 added encrypted Books Copy files and encrypted device sync, and my old "no" no longer matched the code.

## The decision

The question isn't "is the app secure?" It's "who wrote the encryption?". An app that only calls the operating system's encryption is exempt. An app that ships its own has extra export paperwork. I saw three ways forward:

1. Declare it and do the paperwork.
2. Skip the countries where the rules are a burden.
3. Change the app so the simple answer is true.

A normal developer might have chosen the second. I didn't want a smaller market or ongoing paperwork, so I chose the third: on iOS and macOS, only Apple's own encryption. I also asked that it stay true, not just once.

## What the assistant found and built

Our own crypto lived in more places: Books Copy encryption, the app-lock PIN, ledger signing, device-sync TLS, each device's certificate, and HTTPS lookups for exchange rates.

The assistant put it all behind one interface, `CryptoBackend`. Android, Windows and Linux use the Dart implementation. iOS and macOS use a small Swift plugin calling Apple's frameworks. In a debug build, reaching the Dart one on Apple *throws*, and a test fails if any other file imports a crypto library. It rejected a package that routes calls to Apple automatically, because it falls back to Dart silently, and my rule can't allow that.

## Staying compatible

The app syncs iPhone, Mac and Android, so formats and the sync protocol stayed fixed; only the engine changed. The same test vectors run against both backends, and a Books Copy made on an Android tablet restores on an iPhone and back. One surprise: Apple's Ed25519 signatures differ on every run, so tests verify signatures, never compare them.

## Challenges

- A Network framework option that doesn't exist on iOS or macOS.
- Two handle counters overwriting each other.
- Events from Swift arriving before Dart was listening.
- A closing connection dropping its last message.
- Mac Keychain prompts, solved with the data-protection keychain and team-signed debug builds.
- A "No route to host" that was only a missing Local Network permission.

## What I learned

My job was the decision, the constraint and the real-device testing. The assistant did the implementation, and review agents checked it. Treat the question as a design constraint early, keep crypto behind one seam, never allow a silent fallback, and test on real devices.

## One thing I can't remove

The Flutter engine still contains BoringSSL, which `dart:io` uses. Our code doesn't call it on Apple, and removing it would need a custom engine build I don't think is worth maintaining. The same copy ships in every Flutter iOS app. So before each submission I record that I made this call knowingly.
