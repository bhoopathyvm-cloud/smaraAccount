# Replacing Open-Source Encryption With Apple's Own: What I Learned

**Apple asks one question about encryption before an app ships. Answering it honestly meant replacing the open-source encryption in my app with Apple's own.**

Building Smara Account is my learning journey. An AI assistant writes the code and I make the decisions. This is one more lesson.

## The question

App Store Connect asks: *does your app use encryption beyond what Apple's operating system provides?* My answer was "no", until version 2026.10.0 added encrypted Books Copy files and device sync.

The question isn't "is the app secure?" It's "who wrote the encryption?". Our encryption came from open-source libraries: a Dart crypto package for the algorithms, Dart's built-in TLS for sync, and another library for device certificates. An app that ships its own encryption has extra export paperwork. An app that only uses the operating system's encryption is exempt.

## The decision

I saw three ways forward:

1. Declare it and do the paperwork.
2. Skip the countries where the rules are a burden.
3. Replace the open-source encryption with Apple's own on iOS and macOS.

On my own I would have chosen the second, because the rework would have taken me a month or more. The AI did it in about a week. That amplification changed my decision, so I chose the third. It cost a lot of tokens, but a week is far cheaper than a month.

## The replacement

The assistant put all crypto behind one interface, `CryptoBackend`. Android, Windows and Linux keep the open-source Dart implementation. iOS and macOS use a small Swift plugin that calls Apple's frameworks. In a debug build, reaching the Dart one on Apple *throws*, so it can't slip back in silently.

## Where the time really went

Writing the code was the easy part. The first version, 63 files, was merged two hours after the proposal, and it didn't even build on Apple.

The rest of the week went on testing every combination: iPhone, Mac and Android tablets, joining and syncing in both directions on real devices. Each round found something: a Network framework option that doesn't exist on iOS, two counters overwriting each other, a closing connection dropping its last message, Keychain prompts on every signature, and a "No route to host" that was only a missing Local Network permission.

I believe a human would spend far more time here than on the code, setting up devices and hunting these bugs.

## What I learned

My job was the decision and the real-device testing. Treat the question as a design constraint early, keep crypto behind one seam, never allow a silent fallback, and test on real devices.

## One thing I don't like yet

The Flutter engine still contains its own copy of BoringSSL, which `dart:io` uses. Our code doesn't call it on Apple, but I don't like carrying something unused. Neither the AI agent nor I have found a clean way to remove it yet. I'm still researching.
