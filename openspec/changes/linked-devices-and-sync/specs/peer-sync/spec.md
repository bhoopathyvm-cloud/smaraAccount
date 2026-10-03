## Purpose

Let Linked devices catch up over the same Wi-Fi by exchanging signed
records device to device: discovery, encrypted transfer, Sync now, conflict
rules, and honest rejection of anything that fails verification — with no
server, cloud, or relay.

## ADDED Requirements

### Requirement: Same-Wi-Fi Discovery Only
The system SHALL discover peer Smara apps only on the local network after local-network permission is granted. Discovery SHALL NOT use the internet, a cloud directory, or a relay. Discovered peers SHALL be limited to devices that advertise the Smara local service for the same books set the user is syncing.

#### Scenario: Peer found on the same Wi-Fi
- **WHEN** two linked devices have the app open on the same Wi-Fi with local-network permission granted
- **THEN** each can discover the other as a Smara peer for those books

#### Scenario: No internet discovery path
- **WHEN** the devices are on different networks with only internet connectivity between them
- **THEN** they do not discover each other and do not sync

### Requirement: Encrypted Transfer After Key Exchange
After devices have exchanged device certificates (via QR join or an approved join request), sync traffic SHALL be encrypted device to device using those pinned certificates. Sync payloads SHALL carry signed journal-entry batches and metadata operations. Private keys SHALL NEVER be included in a sync payload.

#### Scenario: Sync uses pinned device certificates
- **WHEN** two linked devices sync after a successful join
- **THEN** the transfer is encrypted with the certificates exchanged at join time
- **AND** the payload contains signed entries and metadata ops, not private keys

#### Scenario: Unknown certificate is refused
- **WHEN** a device presents a certificate that was not exchanged for these books
- **THEN** the sync session is refused and no entries are accepted

### Requirement: Sync When Both Open Plus Sync Now
The system SHALL sync whenever both linked apps are open on the same Wi-Fi, and SHALL provide a "Sync now" action. Screen copy SHALL tell the user: "Your devices catch up when both have Smara open on the same Wi-Fi."

#### Scenario: Automatic catch-up while both open
- **WHEN** two linked devices have Smara open on the same Wi-Fi
- **THEN** they exchange missing signed entries and metadata ops without requiring a third-party service

#### Scenario: Sync now
- **WHEN** the user taps "Sync now" while a peer is reachable on the same Wi-Fi
- **THEN** a sync session runs immediately

#### Scenario: No background catch-up when the app is not open
- **WHEN** a linked device is backgrounded or killed and no peer session is already in progress
- **THEN** the system does not schedule OS background work (WorkManager or equivalent) to discover or sync with peers

### Requirement: Sync Adds Records and Never Edits Them
Syncing SHALL add the other devices' journal entries and apply metadata operations. Posted journal entries SHALL NEVER be edited or deleted in place to reconcile devices.

#### Scenario: Entry from peer appears locally
- **WHEN** device A recorded a Spent that device B does not yet have, and they sync
- **THEN** device B stores A's signed entry as a new row and shows it in the register
- **AND** A's original row is unchanged on A

### Requirement: Unverified Records Are Never Accepted
A journal entry that fails hash, signature, or chain verification SHALL NEVER be accepted into the books. It SHALL be shown as "Not accepted: couldn't be verified (from \<device\>)", and every Owner SHALL be alerted on the next sync.

#### Scenario: Tampered batch is refused
- **WHEN** a peer offers an entry whose signature or chain link does not verify against the public identities in the books
- **THEN** the entry is not stored as an accepted journal entry
- **AND** the UI shows "Not accepted: couldn't be verified (from \<device\>)"
- **AND** Owner devices see an alert after sync

### Requirement: Competing Fixes — First Fix Wins
When the same purchase is fixed on two devices, the Fix whose correcting journal entry was recorded first (by its recorded-at / chain order as defined in design) SHALL win. The losing Fix SHALL be cancelled by a new journal entry, and both devices SHALL see a notice asking the people to check.

#### Scenario: Earlier Fix kept, later Fix cancelled
- **WHEN** device A and device B each Fix the same entry offline, A's Fix was recorded first, and they sync
- **THEN** A's Fix remains in effect
- **AND** B's Fix is cancelled by a new signed record
- **AND** both devices show a notice to check the result after sync

### Requirement: Competing Category or Account Changes — Latest Field Wins
When two devices change the same category or account metadata field, the most recent change for that field SHALL win. Unrelated fields SHALL NOT overwrite each other.

#### Scenario: Later name wins, earlier archive kept if newer on archive field
- **WHEN** device A renames a category and device B archives it, with different timestamps per field, and they sync
- **THEN** each field independently keeps the more recent value
- **AND** no posted journal entry is rewritten

### Requirement: Sync Notices Without Push
Notices arising from sync (membership changes, rejected unverified records, competing-Fix outcomes, erase status) SHALL appear on Home and in Device history at the next sync. The system SHALL NOT send push notifications through a server.

#### Scenario: Notice visible after catch-up
- **WHEN** a sync produces a user-visible notice
- **THEN** it appears on Home and in Device history on devices that completed that sync
- **AND** no push notification is required for the notice to exist in the app
