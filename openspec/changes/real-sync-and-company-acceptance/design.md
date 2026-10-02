## Context

See proposal.md, "Why". What exists today:

- **Sync protocol** (`lib/domain/peer_sync/`): payloads, pinning checks, merge, last-write-wins helpers and a discovery model (`PeerAdvertisement`, `_smara._tcp`). The only transport is `InProcessSyncTransport`, and `syncNowAction` is never supplied, so devices never talk.
- **Linked-devices design:** Decisions 1–4 of `linked-devices-and-sync/design.md` still hold (Bonjour discovery, TLS with certificates pinned at join, verification per identity, one database per books set). This design adds the real adapters and the join-by-code path; it does not change those decisions.
- **Claims:** the claims, roles and scoped sync come from `shared-accounts-and-expense-claims`, which another agent is implementing. This change adds only personal limits on top.
- **Device runs:** on this Mac (M2 Pro, 10 cores, 16 GB), launching two physical iOS devices at once through Xcode failed. Simulators are launched without Xcode's debugger automation.

## Goals / Non-Goals

**Goals:**
- Devices on one network sync for real, with no internet.
- Every sync rule moved from `linked-devices-and-sync` 12.1–12.8 has a two-instance harness test and a part in the company run.
- A single command proves the company flow end to end and leaves enough artifacts to debug a failure without rerunning.

**Non-Goals:**
- Sync across networks or via any server.
- Automating the camera or real Wi-Fi; the real-phone check (`linked-devices-and-sync` 11.3) covers these.
- A CI job for the company run.

## Decisions

1. **The TLS transport lives in `lib/data/peer_sync/`, behind `SyncTransport`.**
   - **Mechanism:** `dart:io` `SecureServerSocket` and `SecureSocket`, using each device's self-signed device certificate. Trust comes only from pinning: the peer certificate's SHA-256 fingerprint must be in the pinned set (`CertificatePinning`), and the system CA store is never consulted.
   - **Framing:** length-prefixed JSON messages, as specified for `SyncConnection`.
   - **Alternative rejected:** a platform-channel TLS stack for each OS. It would mean three native implementations for what `dart:io` already does on iOS, Android, macOS and Linux.

2. **Discovery uses a Bonjour/NSD plugin plus a typed-address fallback.**
   - **Bonjour/NSD:** a plugin (e.g. `bonsoir`) advertises and browses `_smara._tcp` with the existing TXT fields (books-set hash, display name, device id, protocol version) and the listening port.
   - **Fallback:** when discovery finds nothing, Linked devices offers "Connect by address" (host and port), which task 12.2 already requires.
   - **Testing:** a `PeerDiscovery` interface keeps the in-process fake for tests.
   - **Alternative rejected:** our own UDP multicast beacon. Platform Bonjour/NSD is what iOS local-network permission and App Store review expect.

3. **Join by code uses the code to meet; the check code is the security.**
   - **Code:** the inviter creates a random 8-character code over a 31-symbol alphabet with no look-alikes, plus a session nonce. It advertises a join offer (`_smara-join._tcp`) whose TXT holds only an offer id, never the code or a hash of it.
   - **Proving the code:** the joiner connects to each nearby offer over TLS (unpinned, join-only) and proves knowledge of the code with an HMAC over both nonces. The inviter allows 5 wrong attempts per code, then shows a new code.
   - **Check code:** both sides compute `HMAC-SHA256(code, inviterPublicKey ‖ joinerPublicKey ‖ nonces)`, reduced to 6 digits, and show it. Only after confirmation on both screens do they exchange certificates, the Signing Identity public key, the role offer and the books. That's the same join payload as the QR path, so everything after it is shared code.
   - **Why the check code and not a password-authenticated key exchange:** comparing a short code by eye is how Bluetooth pairing defeats an attacker sitting in the middle of the connection. It reuses the check code from task 12.3, and it needs no new crypto dependency.
   - **QR path:** QR remains the default (`qr_flutter` to show it, `mobile_scanner` to scan it); "Enter code instead" sits under the scanner.

4. **"Sync now" and sync on foreground share one sync service in the data layer.**
   - **Tracking:** the service keeps one session per discovered linked peer, on the TLS transport.
   - **Triggers:** it runs on app foreground, on "Sync now", and when a new peer appears. It is supplied to the UI through the same DI wiring as the other repositories.
   - **Concurrency:** sessions for different peers can run at the same time. Writes into the database go through the existing merge path in one transaction per batch.

5. **Metadata operations and a persistent hybrid logical clock.**
   - **Operations:** every master-data write (categories, accounts, groups, payees, rules, templates, limits, books settings, personal claim limits) emits a `MetadataOperation` in the same transaction as the write.
   - **Clock and storage:** the operation is stamped with a hybrid logical clock: wall time plus a counter plus the device id, stored in the books database. Winners for each field persist in a `metadata_lww_state` table, so a restart keeps the result.
   - **Alternative rejected:** wall-clock timestamps alone. Simulators and phones drift, and the competing-rename case in the company run would become flaky.

6. **Removal and erase are enforced in the merge path.**
   - **Refusing entries:** each removal record carries the removal time. When an entry is signed by a removed device's identity and its timestamp is later than the removal, merge refuses it and raises a notice.
   - **Erasing:** a device that learns, from any linked peer, that it has been removed with a pending erase deletes its copy of the books set. It does this through the existing deletion of a books set, keeping only the minimal state it needs. It then reports the erase time back to the Owner on the next contact, and the Owner's device shows "Erased on <date>".

7. **Personal limits are signed claim-settings records, scoped to the person.**
   - **Records:** a `personalClaimLimit` record (person, category, amount in the company currency, unit, or cleared) is a claim-settings record, synced like the others. Its sync scope is the Owner, the Approvers, and that one Claimant.
   - **Lookup:** the hint uses the personal limit, falling back to the company limit and then to none, as one function shared by the Claimant and Approver screens.

8. **A Dart conductor on the host, with a role script on each instance.**
   - **Conductor:** `tool/company_sync/conductor.dart` reads `scenario.dart`, a list of steps, each with an owning role and the steps it depends on. It runs a small HTTP server.
   - **Instances:** each instance runs `integration_test/company_sync/company_sync_test.dart` with `--dart-define=COMPANY_SYNC_ROLE=<role>` and `COMPANY_SYNC_CONDUCTOR=<url>`.
   - **Step protocol:** before a step, the instance asks the conductor for permission (long-poll). After it, it posts "done" or "failed" with a visible-text dump.
   - **Handoffs:** the conductor relays values between roles: the join code shown on the Owner and the check codes read from both screens.
   - **Report:** the conductor writes `report.json` and a readable timeline. It fails the run on the first failure or timeout, and stops every instance.
   - **Alternative rejected:** each instance polling its own books until the expected record arrives. Failures would only show up as timeouts, and there'd be no single report.

9. **Instances are built once per platform and launched without Xcode automation.**
   - **Builds:** the script builds the integration test app once per platform (macOS, iOS simulator, Android). It then starts each instance from its prebuilt app (`--use-application-binary`, or `simctl install` and `adb install` followed by `flutter attach`), never rebuilding per device.
   - **Build folders:** iOS simulators get one app build installed into each simulator. Separate build folders are needed only if the Flutter tool insists, using a scratch copy under `build/company_sync/`.
   - **Startup order:** devices start one after another, then run in parallel. The script checks that free memory is at least 10 GB for 5 employees and 5 GB for 2, before booting.

10. **Android emulators run on `-vmnet-shared`.**
    - **Network:** the script starts `smara_store_phone` and `smara_kiosk_pixel` with `-vmnet-shared` (one `sudo` prompt per run), so the emulators, the Mac and the iOS simulators are on one host-only network where Bonjour works. The emulators are cold-booted from a snapshot and their app data is cleared.
    - **Reaching the conductor:** each instance gets the conductor's address on the vmnet bridge interface; iOS simulators and macOS use `127.0.0.1`.
    - **Alternative rejected:** `-vmnet-bridged en0`. It depends on the router, and bridging over Wi-Fi often fails.

11. **Test-only behavior is compiled out of release builds.**
    - **Fixed rates:** under `bool.fromEnvironment('COMPANY_SYNC_TEST')`, the exchange-rate provider returns fixed rates from the scenario (GBP→EUR 1.17, JPY→EUR 0.0062).
    - **Conductor client:** it exists only in `integration_test/`.
    - **Guard:** a unit test asserts that the release configuration has the define off. The "Enter code instead" feature is a product feature, so the test drives it through the GUI.
    - **Receipt fixtures:** `test_fixtures/receipts/` (2 JPEGs and 1 PDF) is pushed with `xcrun simctl addmedia` and `adb push` into `Download/`.

## Risks / Trade-offs

- **[16 GB RAM is tight for 6 mobile instances plus the macOS app]** → Devices start one after another, there's a free-memory check before booting, the `--employees 2` profile exists, and simulators and emulators stay headless or minimised where possible.
- **[vmnet needs `sudo`]** → The script asks once, explains why, and falls back to `--employees 3` (iOS only) when it is declined, with a clear note that Android was skipped.
- **[Bonjour on the iOS simulator uses the host's mDNS responder]** → Each instance advertises its own device id and port, and discovery filters on the device id, never the hostname.
- **[Local-network permission prompts may appear on first launch]** → Setup pre-grants where the platform allows it, and otherwise the role script taps "Allow" as a step (Android), or the iOS simulator's lack of enforcement is relied on and documented.
- **[A flaky sync shows up as a timeout]** → Every step has its own timeout, and the conductor dumps the waiting instance's last sync log and visible texts.
- **[Two specs claiming the same work]** → Tasks 12.1–12.8 in `linked-devices-and-sync` are annotated as moved here and checked only when this change satisfies them.

## Migration Plan

- **Database:** additive migrations only (`metadata_lww_state`, HLC state, removal timestamps, personal limits), with no backfill.
- **Rollout:** the new transport is on by default once discovery permission is granted. Rolling back means not shipping the transport wiring, since the in-process transport still covers tests.
- **Moved tasks:** `linked-devices-and-sync` tasks 12.1–12.8 get "moved to `real-sync-and-company-acceptance`" notes. Neither change is archived until every task is checked, per CLAUDE.md.

## Open Questions

- **Discovery plugin:** `bonsoir` vs `nsd`. Pick the one that passes the macOS ↔ iOS simulator ↔ vmnet Android spike in task 2.1. This doesn't change the specs or tasks.
