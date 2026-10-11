# Letting the Operating System Do the Encryption

**Apple asks one question about encryption before an app can ship. Answering it honestly changed how Smara Account is built, and the change turned out to be a good design lesson.**

*This is one developer's experience, not legal advice. Check your own situation with someone qualified.*

When I uploaded the first TestFlight build of Smara Account, App Store Connect asked a question I had answered quickly in the past: *does your app use encryption beyond what Apple's operating system provides?*

For a long time the honest answer was "no". Then the app grew. Version 2026.10.0 added encrypted Books Copy files (a saved copy of your books) and encrypted sync between your own devices. When I read Apple's wording again, my old answer no longer matched the code. This post is about what I learned from that, and how we changed the app so the answer is true again.

## What the question really asks

Apple's question isn't about whether the app is secure. It's about *who wrote the encryption*. If the app only calls the encryption that comes with iOS and macOS, it is in the simple, exempt category. If the app ships its own encryption code, it falls into a category with extra paperwork: export documentation and reporting duties.

I'm not a lawyer, and the rules differ by country, so I won't summarize them here. What matters for the engineering is this: the app declares the answer in one setting, `ITSAppUsesNonExemptEncryption`, and that setting should be *true to the code*. A declaration that the code contradicts is worse than an honest "yes".

I could have answered "yes" and done the paperwork. I decided instead to make the code match the simpler answer, for two reasons: it keeps the app's promise small ("we use your operating system's encryption, nothing of our own"), and it's a nicer rule to enforce.

## Where our own encryption was hiding

I expected to find a few places. There were more:

- **Books Copy files:** AES-256-GCM encryption with a key from your passphrase, from a Dart package.
- **App lock PIN:** a key-derivation function (PBKDF2), same package.
- **Ledger signing:** every entry is signed with Ed25519 so devices can check who wrote it.
- **Device sync:** TLS, the same technology as HTTPS, from the runtime Dart ships with.
- **Device identity:** a key pair and certificate for each device, made by a third-party library.
- **Exchange rates and quotes:** ordinary HTTPS requests, also through Dart's own client.

All of it worked. None of it was "Apple's".

## The design: one door for all cryptography

The key decision was not to sprinkle `if (isApple)` through the code. Instead there is now a single interface, `CryptoBackend`, and it is the only way the app encrypts, signs, hashes or derives a key.

- On Android, Windows and Linux, a Dart implementation sits behind it, exactly as before.
- On iOS and macOS, a small Swift plugin sits behind it and calls Apple's own frameworks (CryptoKit and CommonCrypto).

The backend is chosen once at startup. On Apple platforms, a debug build *throws an error* if the Dart implementation is ever reached, so a future change can't quietly slip our own encryption back in. A test also fails if any file outside the one Dart backend imports a crypto library.

The same shape repeated for the other pieces: a socket factory for TLS (Apple's Network framework on iOS and macOS), a device-identity store that keeps the key in the Keychain, and Apple's URLSession for HTTPS lookups.

One option I looked at and rejected: a ready-made package that routes our Dart crypto calls to Apple's frameworks. It's convenient, but it falls back to pure Dart for anything it doesn't accelerate, silently. For a rule that says "only the operating system", a silent fallback is the one behavior I can't allow, and no test can rule it out. A visible seam that throws is better than a clever shortcut that hides.

## The hard part: staying compatible with everyone else

The app syncs between an iPhone, a Mac and Android devices, so the Apple side and the Dart side must agree on every byte. That became the main constraint, and I treated it as the release gate.

What helped:

- **Don't change the formats.** The Books Copy file layout, the sync protocol and the certificate pinning model stay exactly the same. Only the code underneath changes.
- **One set of test vectors for both backends.** The same known-answer tests (from the RFCs and NIST) run against the Dart and the Apple implementations. A Books Copy saved on one restores on the other, and a wrong passphrase is refused on both.
- **Real devices, not just simulators.** A Books Copy made on an Android tablet restored on an iPhone and the other way around. An unknown device was refused by both an iPhone and an Android tablet.

One surprise worth sharing: Apple's Ed25519 signatures are *hedged*, so signing the same message twice gives different bytes. Both are valid and every platform verifies them, but any test that compared signature bytes would break. The rule became: verify signatures, never compare them.

## Challenges along the way

None of these were dramatic, but each taught me something.

- **A method that doesn't exist.** My first Swift TLS code used a Network framework option that isn't available on iOS or macOS, so both builds failed. The fix was simpler: require the client certificate and let our Dart code decide whether to trust it.
- **Two counters, one map.** Two handles for TLS verification started counting from 1 and overwrote each other, so a server checked a client with the wrong rule. One shared counter and a regression test fixed it.
- **Messages arriving out of order.** Two channels between Dart and Swift aren't ordered with respect to each other, so early bytes were dropped. Holding events until the connection registers fixed it.
- **A dropped last message.** Closing a connection cancelled it before the final message was sent, so a join was missing its last step. Close now sends first, then cancels.
- **Keychain prompts on the Mac.** The legacy keychain asked for permission on every signature. Switching to the data-protection keychain, with debug builds signed by my team, made the prompts disappear. This is where Apple's code signing rules and the encryption rules met: how an app is signed decides how it may use the Keychain.
- **A permission I forgot.** A real iPhone test failed with "No route to host". It wasn't the pin check at all; the app simply hadn't been allowed to use the Local Network yet.

## What I'd tell my past self

1. **Read the question as a design constraint, early.** It's much cheaper to choose "only the operating system" before the app has ten places that encrypt.
2. **Put crypto behind one seam.** It makes the rule enforceable by a test, not by memory.
3. **Never let a fallback be silent.** A loud failure in debug is a gift.
4. **Keep the wire formats fixed while you swap the engine.** Compatibility testing is then a matter of comparing outputs.
5. **Test on real devices.** Several of the bugs above showed up only on a real phone on a real network.

One honest caveat remains: the Flutter engine still contains its own copy of a TLS library that the Apple builds no longer call. Whether an unused copy matters is a judgement for the owner, and I've recorded that I made it consciously before each submission.

If you're building something similar, I hope this saves you a week. The shape of the change is in the project's decision record, `docs/adr/0005-apple-builds-use-only-os-cryptography.md`.
