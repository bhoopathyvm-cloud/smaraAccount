## Why

A person with a phone and a laptop, partners sharing household books, or a
small office keeping one set of books today still have to copy a file by
hand and hope nobody records on the old device afterwards. Project A
(`books-copy-and-continuation`, ADR 0004) made each device keep its own
key and continue verified history, which is the right foundation — but
entries made on one device still never appear on the others. This change
is project B of the three agreed in the 2026-10 grilling session: linked
devices that catch up over the same Wi-Fi, with no server and no cloud.
Project C (shared accounts and expense claims) needs several sets of
books on one device, which this change also introduces.

## What Changes

- **Linked devices.** Settings gains a "Linked devices" section and an
  "Add a device" flow. Two or more devices work on the **same books**;
  each keeps its own Signing Identity and its own signed chain. Syncing
  *adds* the other devices' records — records are never edited.
- **Same-Wi-Fi only.** Discovery and transfer happen on the local
  network, device to device, encrypted after key exchange. No server, no
  cloud, no relay (matches `Specs/architecture/smara-architecture.md` and
  ADR 0004: private keys never leave their device; only public keys and
  signed records travel).
- **When it syncs.** Whenever both apps are open on the same Wi-Fi, plus
  a "Sync now" button. Android may sync briefly in the background where
  the system allows. Screen copy: "Your devices catch up when both have
  Smara open on the same Wi-Fi."
- **Join.**
  - Normal: "Add a device" with a QR code, in person, on the same Wi-Fi.
    Keys are exchanged and the books are sent directly.
  - Alternative: restore a Books Copy, then send a join request that an
    already-linked device approves with one tap.
- **Roles.** **Owner** adds and removes devices or people, decides who
  may add others, erases removed devices, and can make others Owners.
  **Member** records and fixes entries and manages categories. A Member
  can claim sole ownership after 7 days when the last Owner is gone,
  unless an Owner objects; the app suggests adding a second Owner.
- **Unverified records** are never accepted. They are shown as "Not
  accepted: couldn't be verified (from \<device\>)" and the Owner is
  alerted on the next sync.
- **Conflict rules.**
  - The same purchase fixed on two devices: the fix recorded first wins;
    the second is cancelled by a new record, and both people see a notice
    asking them to check.
  - Competing category or account changes: the most recent change wins,
    per field.
- **Shared categories across languages.** Shared books carry a default
  language for category names plus optional translations. A device shows
  its language's translation, or the default name. A "translate with AI"
  link hands only that word to the person's chosen research tool, as
  today. Duplicates merge (same name and type in any language, or a
  suggested merge when a translation matches). A joining device skips
  starter categories and uses the categories already in the books.
- **Shared vs per-device settings**, matching Books Copy:
  - **Shared (books):** main currency, categories and translations,
    limits, recurring templates, payees, rules, default category
    language, and other books settings.
  - **Per device:** app language, App Lock, display preferences, research
    tool, backup reminder.
- **Notices** appear in the app at the next sync (Home and Device
  history) — there is no push. Everyone is told when a device or person
  is added or removed.
- **Remove and erase.** A removed device gets nothing new from that
  moment; its earlier records stay. "Erase" is honest: it happens the
  next time that device is on the same Wi-Fi ("Erase pending", then
  "Erased on \<date\>"). For a truly lost phone, the UI points to Apple's
  or Google's Find my device / Erase.
- **Local-network permission** is asked only when someone first opens
  "Linked devices", with this sentence first: "To share your books, Smara
  needs to find your other devices on this Wi-Fi. Nothing goes to the
  internet."
- **Several sets of books per device**, with a books switcher (for
  example "My household" and "Acme Ltd – travel"). Each set is fully
  separate — its own key, linked devices and Books Copies. This is a
  prerequisite for project C.
- **Positioning.** Households and small businesses are equal audiences.
  The glossary opening and the architecture doc are updated as part of
  this change (applied when the change lands).

## Capabilities

### New Capabilities
- `linked-devices`: linking and membership — "Linked devices" / "Add a
  device", QR join and Books-Copy-then-join-request, Owner and Member
  roles, sole-Owner claim after 7 days, remove and erase (including
  pending/honest status), membership notices, and the local-network
  permission copy.
- `peer-sync`: same-Wi-Fi discovery and encrypted transfer, when sync
  runs ("Sync now" and both-open), signed entry batches plus metadata
  ops, rejection of unverified records with Owner alert, conflict rules
  for competing Fixes and for competing category/account field changes,
  and sync notices on Home / Device history.
- `shared-categories`: shared category catalog with a default language
  and per-language translations, AI-translate handoff like the research
  tool, automatic and suggested merges, manual "Merge categories", and
  skipping starter categories on a joining device.
- `books-switcher`: several fully separate books sets on one device, the
  switcher UI, and the on-disk mapping (one database file per set, active
  books id).

### Modified Capabilities
- `ledger-integrity-signing`: multi-device books keep several Signing
  Identities active at once (not `continuedAt`); each device signs only
  its own new entries; public keys of linked devices travel with the
  books.
- `ledger-chain-verifier`: verification walks every linked device's
  chain against each entry's `signedByIdentityId` public key already in
  the books.
- `acceptance-test-suite`: a two-in-memory-device harness for CI peer
  sync and linking; real two-device runs stay manual and flagged.
- `household-product-positioning`: product promise widens from
  single-device household books to books that may be shared across linked
  devices (households and small businesses), still with no server holding
  books or keys.
- `privacy-policy-page`: describes local-network discovery and
  device-to-device sync, and what never leaves the LAN.
- `ios-privacy-compliance`: local-network / Bonjour usage and any new
  required-reason or Info.plist declarations match the privacy policy.
- `macos-app-store-sandbox`: local-network / Bonjour entitlements needed
  for peer sync under the sandbox.
- `user-guide`: documents Linked devices, Add a device, Sync now, roles,
  notices, erase, shared categories, and the books switcher.
- `linux-desktop-platform`: mDNS/Bonjour discovery works on the Linux
  desktop target used by nightly acceptance.

## Impact

- **Code added (high level):**
  - peer discovery and TLS transfer modules under `lib/domain/` /
    `lib/data/` (no server client);
  - linked-device membership, roles, notices and erase-pending state in
    the books database;
  - sync merge engine (entry batches, metadata ops, conflict rules);
  - shared category translations and merge;
  - books-switcher storage (one SQLite file per books set under the app
    support directory; active books id in SharedPreferences);
  - UI: Linked devices, Add a device (QR), Sync now, notices, books
    switcher.
- **Code changed:**
  - `IdentityRepository` / signing-identity schema (multiple active
    linked identities);
  - `LedgerChainVerifier` (multi-chain walk);
  - `CategoryRepository` and category management UI (translations,
    merge, skip starter on join);
  - `SettingsRepository` (shared vs per-device split already begun in
    project A);
  - `AppNavigationPolicy` / Settings / Home for notices and switcher;
  - platform permission strings (iOS/macOS/Android/Linux).
- **Localization:** new household copy in `lib/l10n/app_en.arb` (and the
  translation workflow for the other packs) for Linked devices, Sync now,
  notices, erase pending, roles, category merge/translate, and the books
  switcher.
- **Tests:** unit and widget tests; acceptance harness with two
  in-memory devices for CI; real two-device acceptance flagged manual.
- **Docs:** `CONTEXT.md` glossary (Linked Device, Peer Sync, Owner,
  Member, Books Set / switcher, Shared Category), `Specs/architecture/*`,
  privacy policy / what's-built pages, user guide.
- **Dependencies:** local-network discovery (mDNS/Bonjour) and TLS
  socket libraries suitable for Flutter mobile and desktop; no new
  backend service.
- **Prerequisite:** builds on `books-copy-and-continuation` (Books Copy,
  Continuation, ADR 0004, shared-vs-device settings split). Project C
  depends on the books switcher from this change.
