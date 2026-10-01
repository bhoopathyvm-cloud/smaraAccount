# The private key never leaves the device; new devices continue the books

Until now a person could carry their signing key between devices as a 24-word recovery phrase, a keystore file, or inside a device migration bundle. Ordinary users found three key artifacts confusing, a books backup was useless without restoring the key separately, and anyone who tapped New setup could not bring old books in at all. We decided that the private key never leaves the device — it is stored this-device-only and is never shown, exported or written to any file — and that a device holding books without their key gets its own new Signing Identity that *continues* the verified history (Continuation) instead of importing the old key or re-signing every entry.

This works because verifying an entry only needs the public key of the identity that signed it, and every copy of the books carries those public keys: old entries stay verified forever, the new key signs only new entries, and its first entry chains onto the last verified one. The trade-offs we accepted: a lost or broken phone with no saved copy means the books are gone (mitigated by a time-or-usage reminder to "Save a copy of my books"), and the old key-loss Migration flow, which re-signed history, is retired — books that already contain migrated entries still verify. A stolen copy plus its passphrase can reveal the books but can no longer be used to sign as the user.

## Considered Options

- **Keep the recovery phrase and keystore behind an "Advanced" option** — rejected: it keeps every confusing path in code and support for very few users.
- **Re-sign everything under the new key (the existing Migration)** — rejected: it doubles visible history, rewrites "recorded at" times, and breaks reversal links.
- **Let the key travel in OS backups on iOS** — rejected: one behavior on every platform (Android never moves keys) means one path to test and explain.

## Consequences

Linked devices and sync (planned separately) build on this: each device keeps its own key and its own identity, and devices share public keys, never private ones. Any future idea that exports a private key must reopen this ADR.

Established with the OpenSpec change `books-copy-and-continuation`; named in `CONTEXT.md` (Books Copy, Restore, Continuation) when that change lands.
