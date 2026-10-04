# Research: Syncing and claiming without the same Wi-Fi

Research notes for choosing how Linked devices could sync, and how expense
Claims could be submitted, when the devices are not on the same network.
Gathered 2026-10-04. This is not a proposal: it compares options so that
an OpenSpec change (and an ADR) can be written for the chosen one.

External facts were read at the primary source: official docs, RFCs, the
project's own repository or pub.dev page. Each one is cited inline with a
link to the [Sources](#sources) list. Facts about this repo cite the file.
**UNVERIFIED** marks anything I could not confirm at a primary source.

---

## 1. Question and hard constraints

The person asked:

1. How can the app sync when devices are **not on the same network**?
2. How can a person **claim remotely**?
3. List at least five options, easiest first. "Easy" means both easy to
   build and easy to use.
4. Security can't be compromised: **account data must never be visible to
   anyone** except the devices linked to the books.

In this codebase "claim" means two things, and these notes cover both:

- An **expense Claim** submitted by a Claimant (employee) to an Approver.
  The current design says claims "arrive at the office only on the office
  Wi-Fi", and it lists submitting claims outside office Wi-Fi as an
  explicit follow-up (`openspec/changes/shared-accounts-and-expense-claims/proposal.md`,
  "Submit on office Wi-Fi" and "Out of scope").
- **Joining or linking remotely**: "Add a device" or "Add a person" when
  the two people are not in the same room or on the same Wi-Fi. Today
  joining needs a QR code scanned in person, or a join code plus a check
  code on the same network
  (`openspec/changes/real-sync-and-company-acceptance/design.md`, Decision 3).

(The Member's "claim sole ownership after 7 days" is a membership operation
that syncs like any other. Every transport below carries it unchanged.)

Constraints that every option has to meet:

- **End-to-end confidentiality.** No server, relay, cloud provider, VPN
  vendor or app operator may ever see books data in plaintext. Metadata
  leakage (who syncs with whom, when, how much, from which IP) is assessed
  for each option.
- **ADR 0004.** The private signing key never leaves the device. Only
  public keys and signed records travel
  (`docs/adr/0004-private-key-never-leaves-the-device.md`).
- **The product principle in the architecture doc** says sync stays on the
  same Wi-Fi, with "no relay and no internet-hosted component — carried
  over as a hard constraint"
  (`Specs/architecture/smara-architecture.md`, lines 21–25 and 244–246).
  **Every option here except (1) needs that principle reopened, through a
  new ADR, before it is built.** Option 1 changes only the "same Wi-Fi"
  wording, because Smara itself still talks directly to the other device.
- **Platforms:** Android, iOS, macOS and Linux (validated), plus Windows
  (scaffolded). See the `android/`, `ios/`, `macos/`, `linux/` and
  `windows/` folders and the architecture doc, lines 13–16.

---

## 2. What exists today (the starting point)

Read from `main` plus the open PR #226 (`real-sync-and-company-acceptance`,
WIP), which carries the final LAN-sync work.

| Piece | Today | Where |
|---|---|---|
| Records | Every journal entry is signed with the device's Ed25519 Signing Identity and chained per identity (`deviceChainSequence`). Sync is **insert-only**: it adds the other devices' signed records and never edits them. | `lib/domain/crypto/ed25519_signing.dart`; linked-devices design, Decision 3 |
| Payloads | `EntryBatch`, `MetadataOps` (last-write-wins per field with a hybrid logical clock), `NoticeOps`, `ClaimBatch` and receipt blobs, sent as length-prefixed JSON | `lib/domain/peer_sync/sync_payloads.dart`, `claim_sync_payloads.dart`, `hybrid_logical_clock.dart` (PR #226) |
| Transport seam | `SyncTransport` / `SyncConnection` (`send`, `receive`, `connect`, `listen`). Implemented by `InProcessSyncTransport` and `TlsSyncTransport`, which uses `dart:io` `SecureSocket` and pins self-signed device certificates by their SHA-256 fingerprint | `lib/domain/peer_sync/sync_transport.dart`, `tls_sync_transport.dart`, `certificate_pinning.dart` |
| Discovery | `PeerDiscovery`, with Bonjour/NSD through `bonsoir` 7.1.5 (`_smara._tcp`) and a **`DirectAddressPeerDiscovery` "Connect by address"** fallback | `lib/domain/peer_sync/bonsoir_peer_discovery.dart`, `direct_address_peer_discovery.dart` |
| LAN gate | The `LocalNetworkReachability` interface is wired in `main.dart` as `FakeLocalNetworkReachability(onLocalNetwork: true)`. The TLS server binds `InternetAddress.anyIPv4`. | `lib/main.dart` lines 201–202, `tls_sync_transport.dart` line 20 (PR #226) |
| Join | QR code (`qr_flutter` / `mobile_scanner`) or "Enter code instead": an 8-character code over a 31-symbol alphabet, a code proof by HMAC, then a 6-digit check code that both people confirm | `lib/domain/linked_devices/join_code*.dart` (PR #226) |
| Claimant scoping | The sender filters outbound batches by the receiver's role, so a Claimant phone never receives company bank registers | `PeerSyncSessionHooks` in `peer_sync_session.dart`; claims design, Decision 4 |
| Offline carry | Books Copy: AES-256-GCM with PBKDF2-HMAC-SHA256 at 210,000 iterations, protected by a passphrase | `lib/domain/backup/books_copy_file.dart` |
| Crypto library | `cryptography` 2.9.0 (also `crypto`, and `basic_utils` for certificates) | `pubspec.yaml` |

**What this means for remote sync.** The data model is already right for
remote sync. Records are signed, append-only and verifiable by any
receiver, and the merge rules (HLC last-write-wins, first-Fix-wins) don't
depend on the transport. So **every option below reuses the merge engine,
the payload types and the verifier unchanged.** What differs is:

- how bytes travel;
- whether the two devices must be online at the same time;
- whether confidentiality still comes from the TLS session (enough
  device-to-device), or has to move into the payload itself (needed
  whenever anything stores or forwards the data).

The `cryptography` package already ships X25519, Ed25519, AES-GCM,
ChaCha20-Poly1305 / XChaCha20-Poly1305, HKDF and Argon2id on all six
Flutter platforms ([cryptography on pub.dev](#s-cryptography)). So the
"sealed envelope" that options 2–5 need adds **no new crypto dependency**.

### 2.1 A shared building block: the sealed sync envelope (options 2–5)

When data is stored or forwarded by someone else (a file in a chat app, a
cloud folder, a mailbox server), TLS between the two devices no longer
exists. The payload itself must then be encrypted and authenticated.

1. **Each device gets an X25519 "inbox" key pair** next to its Ed25519
   Signing Identity. The private key is this-device-only, like the signing
   key, so ADR 0004 holds. The public key is signed by the device's Signing
   Identity and travels in the join payload. Devices that are already
   linked send it as a signed membership metadata op on their next LAN
   sync.
2. **Building an envelope:**
   - Serialize the existing `EntryBatch` / `MetadataOps` / `ClaimBatch` /
     receipt messages.
   - Encrypt them once with a random content key, using XChaCha20-Poly1305
     or AES-256-GCM.
   - Wrap that content key separately for **each recipient device's** inbox
     key (X25519 + HKDF). This is the construction standardised as HPKE,
     with the DHKEM(X25519, HKDF-SHA256) suite ([RFC 9180](#s-rfc9180)).
     libsodium "sealed boxes" are an equivalent alternative; the `sodium`
     package exposes `crypto_box_seal` ([sodium on pub.dev](#s-sodium)).
   - Sign the envelope header (sender identity, recipients, books-set id,
     sequence range) with the sender's Ed25519 key.
3. **Claimant scoping becomes cryptographic.** The Approver's device builds
   a separate envelope for the Claimant's slice and encrypts it only to the
   Claimant's inbox key. Even if a storage provider leaked everything, the
   Claimant could not decrypt company data that was never encrypted to
   them.
4. **Known limits:**
   - Static recipient keys give no forward secrecy: if a device is later
     compromised, envelopes it could read in the past can be decrypted.
     Mitigation: rotate inbox keys, for example on each LAN sync and on
     every membership change (a removed device gets no new keys).
   - MLS ([RFC 9420](#s-rfc9420)) solves group key agreement with forward
     secrecy and post-compromise security, but it is far more than a
     household or small office needs for now.
   - **UNVERIFIED:** I found no maintained, verified HPKE package for Dart.
     Building it from `cryptography` primitives, with RFC 9180 test
     vectors, looks like the safer route than adding an unmaintained
     package.

---

## 3. Summary comparison (easiest first)

**Scoring.**

- **Build effort:** 1 = a few days, mostly UI and copy; 5 = a new runtime
  or protocol stack.
- **Use effort:** 1 = invisible and automatic; 5 = several third-party
  installs or setup steps for every person.
- **Rank** = build + use, lower is easier. Ties go to the option that
  keeps the "no server" principle intact.

**Security** is a pass/fail gate, not a score: every listed option keeps
books content end-to-end encrypted if it is built as described.

| # | Option | Build | Use | Total | Both online at once? | Cross-person (remote **Claim**)? | Remote **join** | Who sees metadata | Running cost |
|---|---|---|---|---|---|---|---|---|---|
| 1 | **Overlay VPN** (Tailscale / Headscale / ZeroTier) + the existing "Connect by address" | 1 | 3 | **4** | Yes | Yes (everyone in one tailnet) | Yes (join code over the tailnet + check code by voice) | VPN control plane: device list, IPs, connection times; relay: IPs and volume | Free tier (Tailscale Personal: 6 users) |
| 2 | **Sealed sync packet via the share sheet** (WhatsApp, Signal, email, AirDrop, USB) | 2 | 2 | **4** | **No** (async) | **Yes**, the natural fit for "send my claim" | Partly (signed invite link; check code by voice) | The chat or email provider: who sent a file to whom, its size and time | None |
| 3 | **Encrypted mailbox in the person's own cloud** (Google Drive appDataFolder, iCloud Drive, Dropbox app folder) | 3 | 2 | **5** | No (async) | **No** for Drive appDataFolder and iCloud (per account); only the same person's devices | No | Cloud provider: file count, sizes, times, account identity | None (user's own quota) |
| 4 | **Blind store-and-forward mailbox** run by Smara (e.g. Cloudflare Worker + Durable Objects / R2) | 4 | 1 | **5** | No (async) | **Yes**, automatic | **Yes** (Magic-Wormhole-style rendezvous) | Smara's operator plus Cloudflare: IPs, mailbox ids, sizes, times | Free tier likely enough; it's an ops duty |
| 5 | **WebRTC data channel** (flutter_webrtc) + signaling + STUN/TURN | 4 | 2 | **6** | Yes | Yes | Yes (same signaling) | Signaling and TURN operators: IPs, timing, volume | Signaling host plus TURN bandwidth |
| 6 | **Adopt a P2P / local-first engine** (iroh, Automerge-repo, Ditto, PowerSync) | 5 | 1–2 | **6–7** | Varies | Yes | Varies | Engine relay or vendor cloud | Varies; vendor lock-in |

**Remote join / "Add a person" mechanisms** are compared separately in
[section 5](#5-remote-join-and-remote-claim-trust-bootstrap). They plug
into options 1, 2, 4 and 5.

---

## 4. Options in detail

### Option 1: Overlay VPN, with the current LAN sync unchanged

**How it works.** Each person installs a mesh VPN app: Tailscale, a
self-hosted Headscale control server with the Tailscale clients, or
ZeroTier. Every device gets a stable private address and name, and Smara
connects to that address exactly as it does on Wi-Fi.

- Tailscale tries a direct peer-to-peer path first. When that fails it
  falls back to its DERP relays: "the relayed connection won't be as fast"
  ([Tailscale firewall ports](#s-ts-ports)).
- DERP relays can't read traffic: "Because Tailscale private keys never
  leave the local device that generated them, it's impossible for a DERP
  server to decrypt your traffic", and a DERP server "blindly forwards
  already-encrypted traffic" ([Tailscale DERP](#s-ts-derp)).
- MagicDNS gives every device a name ([Tailscale MagicDNS](#s-ts-magicdns)).

**Fit with existing code.**

- **Reused unchanged:** `TlsSyncTransport`, pinning, the payloads, merge,
  Claimant filtering, and **`DirectAddressPeerDiscovery`** ("Connect by
  address"). The TLS server already binds every IPv4 interface
  (`tls_sync_transport.dart`, line 20).
- **Changes needed:**
  - Accept a hostname such as a MagicDNS name, not just an IP address.
  - Remember a peer's last good address, so "Sync now" works without
    retyping it.
  - Relax the "same Wi-Fi" wording and the reachability gate.
  - Add a user-guide page.
- **Discovery won't work over the tunnel.** Bonjour can't find peers there:
  Tailscale's mDNS request is still open, because "Tailscale only operates
  at layer 3" and Apple's mDNSResponder skips point-to-point interfaces
  ([tailscale#1013](#s-ts-mdns)). So "Connect by address" is the path to
  use.
- **iOS / macOS permission:** Apple's local network privacy covers
  broadcast-capable interfaces "such as Wi-Fi and Ethernet, but not
  cellular (WWAN) or VPN" ([Apple TN3179](#s-tn3179)). Connecting over the
  tunnel therefore should not trigger or need the Local Network prompt.
  This is inferred from the technote; **verify it on a device**.

**Security.**

- **Books content:** it is encrypted twice: once by WireGuard and once by
  Smara's own TLS, which is pinned to the certificates exchanged at join.
- **A malicious control plane:** a compromised control server could add a
  node to the network. Tailscale says it could "stealthily insert new
  nodes" ([Tailnet Lock](#s-ts-lock)). Even then, that node can't complete
  Smara's pinned TLS handshake, so it can't read or inject books data.
  Tailnet Lock or Headscale shrink this risk further for people who want
  that ([Tailnet Lock](#s-ts-lock), [Headscale](#s-headscale)).
- **Metadata:** the VPN vendor sees the device list, account emails, IP
  addresses and connection times. A DERP relay sees IPs and traffic volume.
- **Keys:** nothing new; ADR 0004 holds.

**Platforms and packages.** No new Dart package. Tailscale clients exist
for iOS, Android, macOS, Windows and Linux
([Tailscale install](#s-ts-install)). Headscale targets "a *single*
Tailscale network … suitable for a personal use, or a small open-source
organisation" ([Headscale](#s-headscale)). ZeroTier is an alternative.

**Effort.** Build: about 1 (address memory, hostnames, copy, docs and a
manual test). Use: about 3. Every person installs a VPN app and signs in;
the Owner invites the others into one tailnet; **both devices must be
online with Smara open at the same time**. iOS allows only one VPN at a
time, which conflicts with a work VPN (**UNVERIFIED** as an iOS rule;
widely observed).

**Cost.**

- Tailscale Personal is free for up to 6 users with unlimited devices
  ([Tailscale pricing](#s-ts-pricing)).
- ZeroTier's free plan covers 10 devices, for personal, non-commercial use
  only ([ZeroTier pricing](#s-zt-pricing)). A small company would need a
  paid ZeroTier plan.

**Offline.** No store-and-forward. A Claim waits on the phone until both
the phone and the office Mac are online and open at the same time.

**Verdict.** The least code by far, and data safety stays exactly as
strong as today. The cost is setup friction and a dependence on a
third-party app, so it suits technical households and offices better than
the general public. It is a good **"power user" path to ship first.**

---

### Option 2: Sealed sync packet sent through any app (share sheet)

**How it works.**

- **Sending:** "Send update" (or, for a Claimant, "Send claim") builds a
  sealed envelope (section 2.1) of everything the recipient's devices are
  missing, and opens the OS share sheet. The person sends the file over
  WhatsApp, Signal, email, AirDrop, a USB stick, anything.
- **Receiving:** the recipient opens the file in Smara. Smara checks the
  signatures, decrypts with its inbox key, and runs the same merge as a LAN
  batch.
- **Replying:** the Approver's decision and payment come back the same way.

The same idea is already used for the Books Copy file
(`books_copy_file.dart`), but this file is sealed to device keys, not a
passphrase, and it carries only the missing records.

**Fit with existing code.**

- **Reused:** the payloads, `SyncLedgerView.entriesFrom` /
  `nextSequenceByIdentity` (to pick what to send), merge, the verifier and
  the Claimant filter.
- **New:**
  - inbox keys and the envelope format (section 2.1);
  - a per-peer "last acknowledged sequence" record, so packets stay small;
  - receiving files through Android intents, iOS document types and
    desktop "open with";
  - the UI.
- **Tolerant by design:** a packet can be imported twice, out of order or
  late. Inserts are idempotent and keyed by identity +
  `deviceChainSequence`, so a duplicate is skipped and a gap waits for an
  earlier packet.

**Security.**

- **Content:** the transport app only ever holds ciphertext encrypted to
  specific device keys. Forwarding the file to the wrong person reveals
  nothing.
- **Metadata:** the transport provider sees who sent a file to whom, its
  size and the time. That's visible to WhatsApp, Gmail and so on, and not
  to Smara.
- **Forgery and replay:** a forged or tampered packet fails the signature
  check, and replay is harmless because inserts are idempotent.
- **No new server**, so the "no server" principle holds. The principle is
  bent only in the sense that the user chooses an internet channel.

**Platforms and packages.**

- `share_plus` 13.3.1 is the file-sharing package (verified publisher
  fluttercommunity.dev). It shares files on Android, iOS, macOS, Windows
  and web, but file sharing is "not supported on Linux"
  ([share_plus](#s-share-plus)). On Linux, use "Save to file" instead.
- No other new dependency is needed for the crypto.

**Effort.** Build: about 2. The envelope, the file association and the
UI are new; the sync logic is reused. Use: about 2. It's familiar ("send
a file") with no accounts and no installs, but it is manual, and both
sides must act.

**Cost / ops.** None.

**Offline.** Fully asynchronous. A Claimant can submit from a hotel, and
the Approver imports whenever they like.

**Verdict.** The **best fit for remote expense Claims**, and the only
remote option that keeps "no server, no relay" fully true. It is a little
more code than option 1 but much less friction for each person.

---

### Option 3: Encrypted mailbox folder in the person's own cloud

**How it works.** Each device writes sealed envelopes (section 2.1) as
files into a hidden app folder in the person's own cloud storage, and
reads the files addressed to it. The provider stores only ciphertext.

The candidate folders:

- **Google Drive `appDataFolder`.** It "is only accessible by your app and
  its contents are hidden from the user and from other Google Drive apps".
  It needs the non-sensitive `drive.appdata` scope. **"You can't share
  files or folders inside the application data folder."**
  ([Drive appDataFolder](#s-gdrive))
- **Dropbox app folder.** The app gets "read and write access to this
  folder only" ([Dropbox developer guide](#s-dropbox)).
- **iCloud.** Under standard data protection, iCloud Drive and third-party
  app data are encrypted with keys Apple holds. Only Advanced Data
  Protection makes them end-to-end encrypted ([Apple iCloud data
  security](#s-icloud)). CloudKit's `encryptedValues` fields are encrypted
  with key material from the user's iCloud Keychain
  ([CloudKit encrypting user data](#s-cloudkit)).

This is why Smara must encrypt the envelopes itself rather than rely on
the provider.

**Fit with existing code.** It reuses the envelope from option 2. On top
of that it needs:

- a `SyncTransport`-like "mailbox" adapter (list, upload, download,
  delete);
- OAuth sign-in for each provider;
- a background-safe polling loop.

**Security.**

- **Content:** the provider sees ciphertext only. Smara's own encryption
  means even iCloud without Advanced Data Protection, and Drive, see no
  plaintext.
- **Metadata:** the provider sees the account, file names (use random
  ids), sizes and timestamps.
- **Keys:** no key ever goes to the cloud, so ADR 0004 holds.

**The blocker for Claims.** These folders belong to one account and are
not shareable: Drive `appDataFolder` explicitly can't be shared. So this
option syncs **one person's own devices**, such as a phone and a laptop on
the same Google account. It **doesn't** carry a Claimant's claim to a
different person's office Mac.

**Platforms and packages.**

- `googleapis` 17.0.0 (verified publisher google.dev) includes Drive v3 on
  all platforms ([googleapis](#s-googleapis)).
- `google_sign_in` 7.2.0 supports Android, iOS, macOS and web, **not
  Windows or Linux** ([google_sign_in](#s-gsignin)). The desktop targets
  would need their own OAuth loopback flow.
- `icloud_storage` 2.2.0 was last published in January 2023 by an
  unverified uploader, and runs on iOS and macOS only
  ([icloud_storage](#s-icloud-storage)). That is a maintenance risk, and
  a platform channel would be safer.
- A mixed Android + iPhone household needs a provider that works on both,
  which in practice means Drive or Dropbox.

**Effort.** Build: about 3 (OAuth on 5 platforms, provider adapters,
polling, quota and error handling). Use: about 2 (sign in once, then it's
automatic).

**Cost.** None to Smara.

**Offline.** Asynchronous; catch-up happens whenever each device next
opens the app.

**Verdict.** Good for "my phone and my laptop, anywhere". It is **not a
remote-claim solution**, and it adds OAuth and provider maintenance.

---

### Option 4: A blind store-and-forward mailbox server (run by Smara)

**How it works.** A tiny service holds sealed envelopes per recipient
device until that device collects them. The server stores ciphertext
blobs keyed by random mailbox ids and never holds keys. The same service
can host a short-lived **rendezvous** for remote joining, the way the
Magic Wormhole mailbox server "delivers messages from one client to
another" ([Magic Wormhole](#s-wormhole)).

**Hosting.** One cheap, low-ops shape is a Cloudflare Worker with Durable
Objects, which "uniquely combine compute with storage" and support
WebSocket hibernation ([Durable Objects](#s-do)). Receipt-sized blobs can
go in R2. The free tiers:

- Workers: 100,000 requests per day; Durable Objects only with the SQLite
  storage backend on the free plan ([Workers pricing](#s-workers-pricing)).
- R2: 10 GB-month of storage, 1 million Class A and 10 million Class B
  operations a month, and free egress ([R2 pricing](#s-r2-pricing)).

**Fit with existing code.** It reuses the envelope and merge. On top of
that it needs:

- a mailbox `SyncTransport` adapter (upload, list, fetch, acknowledge);
- authentication on the mailbox: each device signs its fetch requests
  with its Ed25519 key, registered at join;
- the server code itself, with retention and deletion rules and abuse
  limits.

**Security.**

- **Content:** the server and Cloudflare see ciphertext only. A fully
  compromised server can delay, drop or replay envelopes, but not read or
  forge them. Signatures plus idempotent inserts handle replay. A
  withheld envelope shows up as a sequence gap, which the app can report.
- **Metadata:** this is the weakest point. The operator sees IP addresses,
  which mailbox ids talk to each other, sizes and timing. Mitigations:
  - random mailbox ids, rotated;
  - padding envelopes to size buckets;
  - Signal-style "sealed sender", where the server learns the recipient
    but not the sender ([Signal sealed sender](#s-sealed-sender)).
- **Principle:** it directly contradicts the architecture's "no relay and
  no internet-hosted component", so it needs a new ADR and a privacy
  policy update.

**Platforms.** It is pure Dart HTTP or WebSocket (the `http` package is
already a dependency), so it runs on every platform.

**Effort.** Build: about 4 (server, adapter, auth, retention, monitoring,
privacy policy and App Store disclosures). Use: about 1. It's invisible:
"Sync now" works anywhere, and Claims flow automatically.

**Cost / ops.** Likely free-tier sized for households, but someone must
operate it permanently (keep it up, handle abuse, decide data retention).
If the project stops running it, remote sync stops.

**Offline.** Fully asynchronous and automatic.

**Verdict.** The best **user** experience, the most server
responsibility, and a principle change. It's a good **phase 2** if
options 1 and 2 prove the demand.

---

### Option 5: WebRTC peer-to-peer data channel

**How it works.**

- **Connecting:** devices exchange connection offers through a signaling
  channel, find a direct path with STUN (ICE), and fall back to a TURN
  relay when NAT blocks a direct path. In WebRTC's own words, "a server is
  required for relaying the traffic between peers, since a direct socket
  is often not possible" ([webrtc.org TURN](#s-webrtc-turn)).
- **Data channel:** "All data channels MUST be secured via DTLS"
  ([RFC 8827](#s-rfc8827)).

**Fit with existing code.**

- **New pieces:** a `SyncTransport` adapter over an `RTCDataChannel`, and
  a signaling service (WebRTC doesn't define one), which is the same
  hosting duty as option 4.
- **Reused:** payloads and merge.
- **DTLS must be tied to the pinned identity.** Bind the DTLS certificate
  fingerprint to the pinned device certificate, or run Smara's own
  authenticated encryption inside the channel.

**Security.**

- **The signaling server:** RFC 8827 warns that "the signaling server can
  potentially mount a man-in-the-middle attack unless implementations have
  some mechanism for independently verifying keys" ([RFC 8827](#s-rfc8827)).
  Smara's pinned certificates are exactly that mechanism, so check them
  inside the channel.
- **TURN:** a TURN server relays data and sees the peers' IP addresses
  and ports, timing and volume. RFC 8656 advises that "Applications that
  want end-to-end security should encrypt the data"
  ([RFC 8656](#s-rfc8656)).

**Platforms and packages.** `flutter_webrtc` 1.6.2 (verified publisher
flutter-webrtc.org) covers Android, iOS, macOS, Windows, Linux and web
([flutter_webrtc](#s-flutter-webrtc)). It's a large native dependency,
mostly media code that Smara doesn't need.

**Effort.** Build: about 4 (signaling, TURN hosting, a native dependency,
NAT edge cases, testing). Use: about 2 (automatic once set up, but both
devices must be online at the same time).

**Cost.** Signaling hosting plus TURN bandwidth, which is billed on
traffic volume.

**Offline.** Synchronous only.

**Verdict.** It's more work than option 4 and still needs a server, but
gives a worse offline story. **Not recommended**, unless real-time
co-editing ever becomes a goal.

---

### Option 6: Adopt a peer-to-peer or local-first sync engine

These were assessed and are listed for completeness.

- **iroh (n0).** It offers QUIC with hole punching. Relays "do not have
  access to the data being transmitted, as it's encrypted end-to-end", and
  "roughly 9 out of 10 networking conditions allow a direct connection".
  The public relays are rate-limited, with no uptime guarantees
  ([iroh relays](#s-iroh-relays)).
  - **No Dart bindings.** In February 2025, n0 paused its FFI releases
    ("we won't be updating these bindings with iroh releases")
    ([iroh FFI update](#s-iroh-ffi-blog)). The `iroh-ffi` repository lists
    Python, Swift, Kotlin and JS ([iroh-ffi](#s-iroh-ffi)). Flutter would
    need a custom Rust bridge, through `flutter_rust_bridge`, on every
    platform.
- **Automerge-repo.** Its documentation shows JS and Rust APIs, and no
  Dart ([Automerge networking](#s-automerge)). Its sync server would need
  application-level encryption to stay blind.
- **PowerSync.** It encrypts in transit with TLS. For end-to-end
  encryption, the app encrypts and decrypts the data itself
  ([PowerSync data encryption](#s-powersync)). It's built around a central
  backend database, which fits Smara's signed ledger poorly.
- **Ditto.** It syncs over "Bluetooth, peer-to-peer Wi-Fi, or local LAN"
  and has a cloud server component ([Ditto](#s-ditto)). It's a commercial
  SDK. **UNVERIFIED:** whether its cloud can be kept to ciphertext only
  for Smara's data.

**Verdict.** Each one replaces or duplicates a sync engine that Smara
already has and has verified (signed chains, HLC last-write-wins, Claimant
filters). Build effort is about 5, with lock-in or native bridge risk.
**Not recommended.**

---

## 5. Remote join and remote claim: trust bootstrap

Every transport above needs the same thing first: the two devices must
learn each other's **public keys** (Signing Identity, device certificate,
and, for options 2–5, the inbox key) **without an attacker swapping
them**. In person, the QR code does this. Remotely, there are these
choices:

| Mechanism | How | Strength | Dart availability | Ease |
|---|---|---|---|---|
| **A. Join code + check code compared by voice or video** | Reuse "Enter code instead": the Owner reads the 8-character code over a phone or video call. The devices meet through option 1, 2 or 4. Both people read the 6-digit check code aloud before anything is exchanged. | Good, **after the hardening below**. An attacker must also control the voice channel. | Already built (PR #226) | Easiest |
| **B. QR code shown on a video call** | The joiner scans the Owner's QR code from their screen during a video call. | As strong as the in-person QR code, if the video feed is live and recognised | Already built | Easy, but awkward on a phone-to-phone call |
| **C. Signed invite link with a one-time key** | The Owner's app creates a one-time X25519 key and secret, and sends a link (for example `smara://join?...`) through Signal or WhatsApp. Opening it starts the join, and a check code is still confirmed by voice. | Relies on the messenger for confidentiality, and on the check code for authenticity | `app_links` 7.2.1 handles deep links on all 6 platforms ([app_links](#s-app-links)) | Easy for users |
| **D. A real PAKE (SPAKE2 / CPace), wormhole-style** | A short code yields a strong shared key. An active attacker gets one guess per run ([RFC 9382](#s-rfc9382)). Magic Wormhole's 16-bit default code gives "a 1-in-65536 chance of success" per attempt ([Magic Wormhole](#s-wormhole)). The mailbox server sees only encrypted messages ([wormhole server protocol](#s-wormhole-server)). | Strongest for short codes | **Gap.** The only Dart package found is `spake2plus` 1.0.2 (RFC 9383, OpenSSL through FFI, **Linux and macOS only**, 15 downloads) ([spake2plus](#s-spake2plus)). CPace is still a draft (`draft-irtf-cfrg-cpace-21`, sent to the RFC Editor) ([CPace](#s-cpace)). OPAQUE is client–server, not peer-to-peer ([RFC 9807](#s-rfc9807)). | Medium build |
| **E. Compare fingerprints after the fact** | Like Signal's linked devices (scan a QR code from the primary phone) ([Signal linked devices](#s-signal-linked)). Show a "safety number" for each linked device in Linked devices, which people can compare at any time. | A safety net, not a bootstrap | Easy, with `cryptography` | Easy |

### 5.1 Hardening join-by-code before it leaves the LAN

These points come from reading PR #226 (`join_code_session.dart`,
`join_code_crypto.dart`). It's a reasoned review, not an audit, and should
be confirmed by whoever owns that change.

1. **The code proof can be guessed offline.** The joiner sends
   `HMAC-SHA256(code, inviterNonce ‖ joinerNonce)` inside a TLS session
   that is unpinned on purpose, because it runs before any pins exist.
   - Anyone who terminates that TLS session sees the proof and both
     nonces. That could be an active attacker on the LAN, or, once
     remote, a relay or mailbox operator.
   - They can then test every code offline. The code space is 31⁸ ≈
     8.5 × 10¹¹ (about 2^39.6), which a GPU can plausibly search within
     the 2-minute code lifetime. This is my estimate, not a measurement.
   - **Fix:** replace the HMAC proof with a PAKE (D), or with an
     ephemeral X25519 exchange whose transcript feeds the check code. Then
     nothing that can be guessed offline ever crosses the wire.
2. **The check code can be ground.** It is
   `HMAC(code, inviterPublicKey ‖ joinerPublicKey ‖ nonces)`, reduced to 6
   digits. An attacker who knows the code can try about 10⁶ substitute
   keys until both screens show the same digits.
   - **Fix:** use a commit-then-reveal step, as in Bluetooth numeric
     comparison or ZRTP. Each side commits to its key and nonce before
     seeing the other's, so the attacker can't grind.
3. **The certificates are outside the check code.** It covers the Signing
   Identity public keys but not the device certificate fingerprints, which
   travel in the `hello` and `payload` frames.
   - **Fix:** include both certificate fingerprints and both inbox public
     keys in the transcript that the check code covers.

On today's LAN these are hard to exploit: the attacker must be on the same
Wi-Fi, active, and fast. Over any internet path, the relay operator sits
exactly in that position, so **fix these before any remote join ships.**

---

## 6. Recommendation

**Combination: option 2 (sealed packets) for Claims and occasional
catch-up, plus option 1 (overlay VPN) as an optional live-sync path for
power users, plus join mechanism A or C with the hardening in 5.1.
Plan option 4 (blind mailbox) as phase 2 only if users want it automatic.**

Why this order:

1. **Option 2 answers "remote claim" directly.** A Claimant on a trip
   taps "Send claim", picks WhatsApp or email, and the Approver opens the
   file. It's asynchronous, it needs no accounts and no server, and it
   keeps the "no server, no relay" principle intact. Only the "same
   Wi-Fi" wording changes. Envelopes encrypted per recipient also make the
   Claimant scoping cryptographic, not just a filter.
2. **Option 1 costs almost nothing to support.** "Connect by address"
   already exists. Accepting hostnames and documenting Tailscale gives
   technical households and small offices live sync anywhere, with
   Smara's pinned TLS still protecting the data inside the VPN.
3. **Option 4 is the "it just works" endgame,** but it's a permanent
   operational and privacy commitment. Take that decision in an ADR,
   after options 1 and 2 show real demand. It reuses the same envelope
   from option 2, so no work is wasted.
4. **For remote joining,** ship A (join code read out over a call, then
   the check code confirmed by voice) once 5.1 is fixed. Add C (invite
   link) for convenience. Treat D (a real PAKE) as the long-term upgrade
   once a maintained Dart or FFI implementation exists. Add E (safety
   numbers) in Linked devices whatever is chosen.

**Next steps if this is accepted:**

- an ADR that amends the architecture principle (sync is "device to
  device, end-to-end encrypted, over any channel");
- an OpenSpec change, `remote-sync-sealed-packets`, covering the inbox
  keys, the envelope, "Send update" / "Send claim", file import, the 5.1
  hardening, and the privacy policy and user guide updates;
- a small follow-up for "Connect by hostname" and a Tailscale guide.

---

## 7. Open questions

1. **Principle:** is the owner willing to change "same Wi-Fi only" in the
   architecture doc and privacy policy? Option 2 changes only the wording;
   option 4 changes the substance.
2. **Who is the remote case for?** Is it mainly one person's own devices
   (where options 1 and 3 suffice) or a company with Claimants (where
   option 2 or 4 is needed)?
3. **Forward secrecy:** is rotating inbox keys on every LAN sync and
   every membership change enough, or is MLS-grade post-compromise
   security wanted? (I'd suggest not, for now.)
4. **Receipts in packets:** receipt photos (about 1 MB each, PDFs up to
   5 MB) make packets large. Email attachment limits may push large
   claims onto chat apps or AirDrop.
5. **Removed devices:** a removed device must not keep receiving packets.
   Rotating inbox keys on removal handles that. Erase-on-contact still
   needs a contact, which a mailbox (option 4) would provide.
6. **iOS:** is connecting over a VPN interface really exempt from the
   Local Network prompt (TN3179 implies so), and how does a work VPN
   interact with Tailscale on iOS? Both need a test on a real device.
7. **Linux:** `share_plus` can't share files on Linux, so Linux needs a
   "Save packet to file" flow.

---

## Sources

Primary sources, read 2026-10-04.

- <a id="s-ts-ports"></a>Tailscale, "What firewall ports should I open?": https://tailscale.com/kb/1082/firewall-ports
- <a id="s-ts-derp"></a>Tailscale, "DERP servers": https://tailscale.com/kb/1232/derp-servers
- <a id="s-ts-lock"></a>Tailscale, "Tailnet Lock": https://tailscale.com/kb/1226/tailnet-lock
- <a id="s-ts-magicdns"></a>Tailscale, "MagicDNS": https://tailscale.com/kb/1081/magicdns
- <a id="s-ts-install"></a>Tailscale, "Install Tailscale": https://tailscale.com/kb/1347/installation
- <a id="s-ts-pricing"></a>Tailscale pricing: https://tailscale.com/pricing
- <a id="s-ts-mdns"></a>tailscale/tailscale issue #1013, "Support mDNS for name and service resolution" (open): https://github.com/tailscale/tailscale/issues/1013
- <a id="s-headscale"></a>juanfont/headscale README: https://github.com/juanfont/headscale
- <a id="s-zt-pricing"></a>ZeroTier pricing: https://www.zerotier.com/pricing/
- <a id="s-tn3179"></a>Apple, TN3179 "Understanding local network privacy": https://developer.apple.com/documentation/technotes/tn3179-understanding-local-network-privacy
- <a id="s-gdrive"></a>Google, "Store application-specific data" (appDataFolder): https://developers.google.com/workspace/drive/api/guides/appdata
- <a id="s-dropbox"></a>Dropbox developer guide (App folder): https://docs.dropboxapi.com/dropbox-api/docs/developer-resources/developer-guide
- <a id="s-icloud"></a>Apple, "iCloud data security overview": https://support.apple.com/en-us/102651
- <a id="s-cloudkit"></a>Apple, CloudKit "Encrypting User Data": https://developer.apple.com/documentation/cloudkit/encrypting-user-data
- <a id="s-wormhole"></a>Magic Wormhole documentation, welcome page: https://magic-wormhole.readthedocs.io/en/latest/welcome.html
- <a id="s-wormhole-server"></a>Magic Wormhole, server protocol: https://magic-wormhole.readthedocs.io/en/latest/server-protocol.html
- <a id="s-rfc9382"></a>RFC 9382, SPAKE2: https://www.rfc-editor.org/rfc/rfc9382.html
- <a id="s-rfc9807"></a>RFC 9807, OPAQUE: https://www.rfc-editor.org/rfc/rfc9807.html
- <a id="s-cpace"></a>draft-irtf-cfrg-cpace (datatracker): https://datatracker.ietf.org/doc/draft-irtf-cfrg-cpace/
- <a id="s-rfc9180"></a>RFC 9180, HPKE: https://datatracker.ietf.org/doc/html/rfc9180
- <a id="s-rfc9420"></a>RFC 9420, MLS: https://datatracker.ietf.org/doc/html/rfc9420
- <a id="s-rfc8827"></a>RFC 8827, WebRTC Security Architecture: https://www.rfc-editor.org/rfc/rfc8827.html
- <a id="s-rfc8656"></a>RFC 8656, TURN: https://www.rfc-editor.org/rfc/rfc8656.html
- <a id="s-webrtc-turn"></a>webrtc.org, "TURN server": https://webrtc.org/getting-started/turn-server
- <a id="s-signal-linked"></a>Signal Support, "Linked Devices": https://support.signal.org/hc/en-us/articles/360007320551-Linked-Devices
- <a id="s-sealed-sender"></a>Signal blog, "Technology preview: Sealed sender for Signal": https://signal.org/blog/sealed-sender/
- <a id="s-iroh-relays"></a>iroh docs, "Relays": https://docs.iroh.computer/concepts/relays
- <a id="s-iroh-ffi-blog"></a>iroh blog, "Update On FFI Bindings" (2025-02-12): https://www.iroh.computer/blog/ffi-updates
- <a id="s-iroh-ffi"></a>n0-computer/iroh-ffi: https://github.com/n0-computer/iroh-ffi
- <a id="s-automerge"></a>Automerge, "Networking": https://automerge.org/docs/reference/repositories/networking/
- <a id="s-powersync"></a>PowerSync, "Data Encryption": https://docs.powersync.com/client-sdks/advanced/data-encryption
- <a id="s-ditto"></a>Ditto, "What is Ditto?": https://docs.ditto.live/home/about-ditto
- <a id="s-do"></a>Cloudflare, Durable Objects: https://developers.cloudflare.com/durable-objects/
- <a id="s-workers-pricing"></a>Cloudflare Workers pricing: https://developers.cloudflare.com/workers/platform/pricing/
- <a id="s-r2-pricing"></a>Cloudflare R2 pricing: https://developers.cloudflare.com/r2/pricing/
- <a id="s-cryptography"></a>pub.dev, `cryptography` 2.9.0: https://pub.dev/packages/cryptography
- <a id="s-sodium"></a>pub.dev, `sodium` 4.1.1: https://pub.dev/packages/sodium
- <a id="s-share-plus"></a>pub.dev, `share_plus` 13.3.1: https://pub.dev/packages/share_plus
- <a id="s-app-links"></a>pub.dev, `app_links` 7.2.1: https://pub.dev/packages/app_links
- <a id="s-googleapis"></a>pub.dev, `googleapis` 17.0.0: https://pub.dev/packages/googleapis
- <a id="s-gsignin"></a>pub.dev, `google_sign_in` 7.2.0: https://pub.dev/packages/google_sign_in
- <a id="s-icloud-storage"></a>pub.dev, `icloud_storage` 2.2.0: https://pub.dev/packages/icloud_storage
- <a id="s-flutter-webrtc"></a>pub.dev, `flutter_webrtc` 1.6.2: https://pub.dev/packages/flutter_webrtc
- <a id="s-spake2plus"></a>pub.dev, `spake2plus` 1.0.2: https://pub.dev/packages/spake2plus
- pub.dev, `bonsoir` 7.1.5 (used by PR #226): https://pub.dev/packages/bonsoir
