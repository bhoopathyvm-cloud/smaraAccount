# Replacing Open-Source Encryption With Apple's Own: What I Learned

**Apple asks one question about encryption before an app ships. I learned what it means, and how to change the app to answer it.**

Building Smara Account is a learning journey for me. An AI assistant writes the code and I make the decisions. This is another thing I learned along the way.

App Store Connect asks: *does your app use encryption beyond what Apple's operating system provides?* Version 2026.10.0 added encrypted Books Copy files and device sync, and my old "no" no longer matched the code.

## The decision

The question isn't "is the app secure?" It's "who wrote the encryption?". An app that only calls the operating system's encryption is exempt. An app that ships its own has extra export paperwork. I saw three ways forward:

1. Declare it and do the paperwork.
2. Skip the countries where the rules are a burden.
3. Change the app so the simple answer is true.

On my own I would have chosen the second, because the rework would have taken me a month or more. The AI did it in about a week. That amplification changed my decision, so I chose the third. It cost a lot of tokens, but a week is a very different price than a month.

## What the assistant built

All our crypto now sits behind one interface, `CryptoBackend`. Android, Windows and Linux use the Dart implementation. iOS and macOS use a small Swift plugin calling Apple's frameworks. In a debug build, reaching the Dart one on Apple *throws*, so nothing can slip back silently.

## Where the time really went

Writing the code was the easy part. The first version, 63 files, was merged about two hours after the proposal, and it didn't even build on Apple.

The rest of the week went on testing every combination: iPhone, Mac and Android tablets, joining and syncing in both directions on real devices. Each round found something: a Network framework option that doesn't exist on iOS, two handle counters overwriting each other, events arriving before Dart listened, a closing connection dropping its last message, Keychain prompts on every signature, and a "No route to host" that was only a missing Local Network permission.

I believe a human would spend far more time here than on the code: setting up devices, waiting for builds and hunting these bugs. That amplification impressed me most.

## What I learned

My job was the decision, the constraint and the real-device testing. Treat the question as a design constraint early, keep crypto behind one seam, never allow a silent fallback, and test on real devices.

## One thing I don't like yet

The Flutter engine still contains its own copy of BoringSSL, which `dart:io` uses. Our code doesn't call it on Apple, but I don't like carrying something unused. Neither I nor the AI agent has found a clean way to remove it yet, and I'm still researching.
