# Replacing Open-Source Encryption With Apple's Own: What I Learned

**Apple asks one question about encryption before an app ships. I learned what it means, and how to change the app to answer it.**

Building Smara Account is a learning journey for me. An AI assistant writes the code and I make the decisions. This is another thing I learned along the way.

App Store Connect asks: *does your app use encryption beyond what Apple's operating system provides?* Version 2026.10.0 added encrypted Books Copy files and encrypted device sync, and my old "no" no longer matched the code.

## The decision

The question isn't "is the app secure?" It's "who wrote the encryption?". An app that only calls the operating system's encryption is exempt. An app that ships its own has extra export paperwork. I saw three ways forward:

1. Declare it and do the paperwork.
2. Skip the countries where the rules are a burden.
3. Change the app so the simple answer is true.

On my own I would have chosen the second, because the rework would have taken me a month or more. The AI did it in about a week. That amplification changed my decision, so I chose the third: only Apple's own encryption on iOS and macOS. It cost a lot of tokens, but a week is a very different price than a month.

## What the assistant built

Our own crypto lived in many places: Books Copy, the app-lock PIN, ledger signing, device-sync TLS, device certificates and HTTPS lookups. The assistant put it all behind one interface, `CryptoBackend`. Android, Windows and Linux use the Dart implementation. iOS and macOS use a small Swift plugin calling Apple's frameworks. In a debug build, reaching the Dart one on Apple *throws*, and a test fails if any other file imports a crypto library. It rejected a package that routes calls to Apple automatically, because it falls back to Dart silently.

## Where the time really went

Writing the code was the easy part. The first version, 63 files, was merged about two hours after the proposal. It didn't even build on Apple.

The rest of the week went on testing every combination: iPhone, Mac and Android tablets, each pair joining and syncing in both directions on real devices. Each round found something:

- A Network framework option that doesn't exist on iOS or macOS.
- Two handle counters overwriting each other.
- Events from Swift arriving before Dart was listening.
- A closing connection dropping its last message.
- Mac Keychain prompts on every signature.
- A "No route to host" that was only a missing Local Network permission.

Even Apple's Ed25519 signatures surprised us: they differ on every run, so tests verify them and never compare them.

I believe a human would spend far more time here than on the code, setting up devices, waiting for builds and hunting these bugs. Of everything the AI did, this amplification impressed me most.

## What I learned

My job was the decision, the constraint and the real-device testing. Treat the question as a design constraint early, keep crypto behind one seam, never allow a silent fallback, and test on real devices.

## One thing I don't like yet

The Flutter engine still contains its own copy of BoringSSL, which `dart:io` uses. Our code doesn't call it on Apple, but I don't like carrying something we don't use. Neither I nor the AI agent has found a clean way to remove it yet. I'm still researching how to remove it fully.
