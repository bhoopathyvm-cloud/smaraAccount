## Why

Smara Account keeps one set of books on one device. People want to keep
working on the same books from a second phone, a laptop, a partner's
phone or a colleague's computer, and see each other's entries without a
cloud account. The design was settled in a grilling session and recorded
in issue #204. It builds on `books-copy-and-continuation` (Books Copy,
Restore, Continuation, ADR 0004), which must land first.

## What Changes

- **Linked devices.** Two or more devices share the same books. Each
  device keeps its own Signing Identity and its own signed chain. The
  private key still never leaves the device (ADR 0004).
- **Same Wi-Fi only, device to device.** No server, no cloud, no relay.
  Devices catch up whenever both have the app open on the same Wi-Fi,
  plus a "Sync now" button. Android may also sync briefly in the
  background where the system allows. Traffic is encrypted between
  devices that have exchanged keys.
- **Adding a device.**
  - **Normal:** "Add a device" shows a QR code that the new device scans
    in person, on the same Wi-Fi. The books are sent directly.
  - **Alternative:** a device that restored a Books Copy sends a join
    request, which an already-linked device approves with one tap.
- **Roles.**
  - **Owner:** adds and removes devices and people, decides who may add
    others, erases removed devices, and can make others Owners.
  - **Member:** records and fixes entries, manages categories.
  - If the only Owner is gone, a Member can claim ownership. Every
    device is told, and the claim takes effect after 7 days unless an
    Owner objects. The app suggests adding a second Owner.
- **Notices.** Every member is told when a device or person is added or
  removed. Notices appear in the app at the next sync, on Home and in
  Device history.
- **Remove and erase.** A removed device gets nothing new from that
  moment, and its earlier records stay in the books. "Erase" is carried
  out the next time that device is on the same Wi-Fi. The Owner sees
  "Erase pending", then "Erased on <date>".
- **Conflicts.**
  - **Records** never conflict, because they are never edited.
  - **The same purchase fixed on two devices:** the fix recorded first
    wins. The other fix is cancelled automatically by a new record, and
    both people see a notice.
  - **Categories and accounts:** the most recent change wins, per field.
  - **Records that fail verification** are never accepted. They are
    shown as "Not accepted" and the Owner is alerted.
- **Shared and per-device settings.**
  - **Shared** (books): main currency, categories and their
    translations, limits, recurring templates, payees, rules, and the
    default category language.
  - **Per device:** app language, display preferences, research tool,
    App Lock and the backup reminder.
- **Categories across languages.**
  - Shared books have a default language for category names, plus
    optional translations per language. A device shows its language's
    translation, or the default name.
  - A "translate with AI" link hands only that word to the person's
    chosen AI tool in the browser.
  - Categories with identical names and the same type in any language
    merge automatically. When a translation matches another category,
    the app suggests a merge. A manual "Merge categories" action exists,
    and merged records keep their original links so signatures stay
    valid.
  - A joining device skips the starter categories and uses the ones it
    receives.
- **Several sets of books per device.** A books switcher shows, for
  example, "My household" and "Acme Ltd – travel". Each set is fully
  separate, with its own key, linked devices and copies. This is the
  foundation for `shared-accounts-and-expense-claims` (#205).
- **Positioning.** Households and small businesses become equal
  audiences. The no-server promise is unchanged.
- **Screen words:** "Linked devices", "Add a device", "Sync now".

## Capabilities

### New Capabilities
- `linked-devices`: adding, approving, removing and erasing devices; Owner and Member roles; ownership claim; notices; the local-network permission prompt.
- `local-network-sync`: when and how linked devices exchange records and settings over the same Wi-Fi; verification of received records; conflict rules; shared and per-device settings.
- `multiple-books`: several fully separate sets of books on one device, with a books switcher.
- `category-translations`: a default category language, per-language translations, the AI translation link, automatic and suggested merges, and manual merging.

### Modified Capabilities
- `household-product-positioning`: households and small businesses are equal audiences; sharing between devices is local-network-only.
- `ledger-integrity-signing`: each linked device has its own Signing Identity and chain within the same books; startup verification checks every device's chain.
- `core-ledger-single-account`: a joining device does not seed starter categories; categories can be merged.
- `app-localization`: category names follow the translation chosen for each language, falling back to the default language.

## Impact

- **Depends on** `books-copy-and-continuation` being implemented and archived first (Books Copy, Restore, Continuation, Device history).
- **Database:** device and role on Signing Identities; one chain per identity (the device chain sequence becomes unique per identity, not per database); category translations and merge links; a replication log for master-data changes; sync state per linked device. Each set of books gets its own database file.
- **Platform:** local network discovery and permission strings (iOS `NSLocalNetworkUsageDescription` and Bonjour services, Android nearby-Wi-Fi and multicast permissions, macOS sandbox network entitlements); camera access for QR scanning.
- **UI:** Settings → Linked devices, Add a device (QR show and scan), join requests, roles, remove and erase, Sync now, Home notices, books switcher, category translation and merge.
- **Localization:** new strings in all 43 languages.
- **Docs:** `CONTEXT.md` ("Household books on one device" changes), `Specs/architecture/*` (sync moves from deferred to designed), privacy policy, user guide and website.
- **Tests:** unit, widget, integration and acceptance suites, including two-device acceptance scenarios over a loopback transport, plus real two-device runs on iOS, Android and macOS.
