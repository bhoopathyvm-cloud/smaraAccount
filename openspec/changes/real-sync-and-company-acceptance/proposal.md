## Why

Linked Devices and Expense Claims are designed, but devices still cannot sync for real. Only an in-process test transport exists, discovery and QR join are missing, and "Sync now" does nothing in the app (`linked-devices-and-sync` tasks 12.1–12.8). Nothing proves that a small company can run travel expenses across a Mac and several phones. This change builds the real sync and adds a fully automated seven-device acceptance run of a realistic company. The design was settled in a grilling session on 2026-10-02.

## What Changes

- **Real sync between devices** (moved here from `linked-devices-and-sync` 12.1–12.8, whose requirements stay in that change's `peer-sync` and `linked-devices` specs):
  - **Transport:** TLS sockets with certificate pinning behind `SyncTransport`.
  - **Discovery:** Bonjour/NSD discovery of `_smara._tcp`, plus a direct-address fallback.
  - **QR join:** join screens with the QR code and the short check code.
  - **Sync now:** "Sync now" and sync on app foreground, wired to the real transport.
  - **Metadata:** metadata operations from every master-data write; persisted last-write-wins state ordered by a hybrid logical clock.
  - **Removal:** entries signed by a removed device are refused; erase happens on next contact.
- **"Enter code instead"** as an alternative to scanning the QR code:
  - The inviting device shows a short code (e.g. `K7QF-3M9P`), valid for 2 minutes and single-use.
  - The joining device types it and finds the inviter on the network.
  - Both screens then show the same 6-digit check code, which the person confirms before anything is exchanged.
- **Personal claim limits.** The Owner can set a limit per person and category ("Ravi: Hotel 120"):
  - For that person it replaces the company-wide hint for the category.
  - It is still only a hint and never changes an amount.
- **Seven-device company acceptance run**, fully automated on this Mac:
  - **Cast:**
    - the macOS app as Owner;
    - an iPad simulator as the accountant (Approver);
    - 3 iOS simulators (SE 3rd gen, 17, 17 Pro Max) and 2 Android emulators as travelling employees (Claimants).
  - **Employees:** `--employees 2..5`, default 5.
  - **Conductor:** a localhost conductor sequences the devices and collects one report.
  - **Network:** Android emulators join a shared vmnet network so Bonjour reaches them.
  - **Fixtures:** receipts are seeded into each device's photo library; exchange rates are fixed.
  - **Story:** "Acme Travel Co": approvals, a reduced approval, rejections, a resubmission, two advances, payments that bring every "Owed to" balance to 0.
  - **Hard cases:** a rush-hour submission, an offline employee, an employee who leaves and is erased, and a competing category rename.
- **Not in this version:**
  - a CI run (local only);
  - real Wi-Fi bridging for emulators;
  - an iOS 17 simulator runtime;
  - automated camera capture.

## Capabilities

### New Capabilities
- `join-code-entry`: joining a linked device by typing a short, expiring, single-use code, confirmed by a matching check code on both screens.
- `personal-claim-limits`: claim-limit hints per person and category, replacing the company-wide hint for that person.

### Modified Capabilities
- `acceptance-test-suite`: adds the seven-device company acceptance run, its conductor, device setup and pass criteria.

The real-sync work implements requirements already written in `linked-devices-and-sync` (`peer-sync`, `linked-devices`). Those capabilities and `expense-claims` are not yet in `openspec/specs/`, so they are not modified here. `personal-claim-limits` builds on `expense-claims` "Spending-Limit Hints" and is reconciled when both changes are archived (task 0.2).

## Impact

- **Depends on:**
  - `shared-accounts-and-expense-claims`, implemented by another agent: claims, roles and scoped sync;
  - `linked-devices-and-sync` for the existing protocol.
- **Can start before claims land:**
  - sync tasks 1–3;
  - Enter code (task 4);
  - the conductor and device setup (task 6).
- **Code:**
  - **Sync transport and discovery:** `lib/domain/peer_sync/`, new `lib/data/peer_sync/` adapters.
  - **Join screens:** `lib/ui/features/linked_devices/`.
  - **Personal limits:** claim limits in the claims data and UI.
- **Dependencies:**
  - **Discovery:** a Bonjour/NSD plugin (e.g. `bonsoir` or `nsd`).
  - **QR:** `qr_flutter` to show codes and `mobile_scanner` to scan them.
- **Platform:**
  - **iOS:** `NSLocalNetworkUsageDescription` and `NSBonjourServices` (`_smara._tcp`), plus the camera prompt.
  - **macOS sandbox:** network server and client entitlements.
  - **Android:** multicast lock.
- **Tooling:**
  - `tool/run_company_sync_test.sh`;
  - a Dart conductor under `tool/company_sync/`;
  - simulator and emulator setup, including one `sudo` prompt for vmnet.
- **Tests:** unit and two-instance harness tests for each sync piece, plus the seven-device acceptance scenario.
- **Localization:** new strings (Enter code, check code, personal limits) in all 43 languages.
- **Docs:**
  - `CONTEXT.md`: Join Code, Check Code, Personal Claim Limit;
  - user guide;
  - privacy policy (the local-network use is unchanged).
