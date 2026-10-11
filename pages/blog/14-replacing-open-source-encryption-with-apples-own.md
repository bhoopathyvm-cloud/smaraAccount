# Replacing Open-Source Encryption With Apple's Own: What I Learned

## The question

App Store Connect asks: *does your app use encryption beyond what Apple's operating system provides?* My answer was "no" until version 2026.10.0 added encrypted Books Copy files and sync.

The question isn't "is the app secure?" It's "who wrote the encryption?". Ours came from open-source libraries: a Dart crypto package, Dart's built-in TLS for sync, and a certificate library. An app shipping its own encryption faces extra export paperwork; one using only the operating system's is exempt.

## The decision

An AI assistant writes the code and I make the decisions; this one was mine. I saw three ways forward:

1. Declare it and do the paperwork.
2. Skip the countries where the rules are a burden.
3. Replace the open-source encryption with Apple's own on iOS and macOS.

On my own I would have chosen the second, because the rework would have taken me a month or more. The AI did it in about a week. That amplification changed my decision, so I chose the third. It cost many tokens, but a week beats a month.

## The replacement

The assistant put all crypto behind `CryptoBackend`. Android, Windows and Linux keep the open-source Dart implementation. iOS and macOS use a small Swift plugin that calls Apple's frameworks. In debug builds, reaching the Dart one on Apple *throws*, so it can't slip back in silently.

## Where the time really went

Writing the code was the easy part. The first version, 63 files, was merged two hours after the proposal, yet it didn't build on Apple.

The rest of the week went on testing every combination of iPhone, Mac and Android tablet, joining and syncing both ways. Each round found something: a Network framework option that doesn't exist on iOS, two counters overwriting each other, a closing connection dropping its last message, and a "No route to host" that was only a missing Local Network permission.

I believe a human would spend far more time here than on the code.

## What I learned

This is my first app in the Apple store, so every small step is new, and one question in a store form reshaped the architecture. Had I shipped before, I'd have known earlier.

AI doesn't remove that learning. It probably knew the rule all along, but someone still has to ask the right question, and that is a person. AI amplifies what you know: with good knowledge in an area the result comes very fast, without it you mostly spend tokens.

My job was the decision and the real-device testing. Keep crypto behind one seam and allow no silent fallback.

## One thing I don't like yet

The Flutter engine still contains its own copy of BoringSSL, which `dart:io` uses. Our code doesn't call it on Apple, but I dislike carrying something unused. Neither the AI agent nor I have found a clean way to remove it yet; I'm researching.
