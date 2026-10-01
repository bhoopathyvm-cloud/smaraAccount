## Purpose

Define how linked devices exchange records and shared settings over the same Wi-Fi without a server, how received records are verified, and how competing changes are resolved.

## ADDED Requirements

### Requirement: Same Wi-Fi Only, No Server
Linked devices SHALL exchange data only directly with each other over the local network. The system SHALL NOT send books data, settings or keys to any server, cloud service or relay. All traffic between linked devices SHALL be encrypted and accepted only from devices whose public keys were exchanged when they were linked.

#### Scenario: No internet traffic during sync
- **WHEN** two linked devices sync
- **THEN** no books data leaves the local network

#### Scenario: An unknown device is ignored
- **WHEN** a device that is not linked tries to connect
- **THEN** the connection is refused and nothing is exchanged

### Requirement: When Sync Happens
Linked devices SHALL sync automatically whenever both have the app open on the same Wi-Fi, and SHALL offer a "Sync now" action. On Android the system MAY also sync briefly in the background where the operating system allows. The app SHALL describe this honestly: "Your devices catch up when both have Smara open on the same Wi-Fi."

#### Scenario: Entries appear on the other device
- **WHEN** a member records an entry on a phone while a linked laptop has the app open on the same Wi-Fi
- **THEN** the entry appears on the laptop without any further action

#### Scenario: A device catches up later
- **WHEN** a phone records entries while away and later opens the app on the shared Wi-Fi with a linked device open
- **THEN** both devices exchange every record the other is missing

### Requirement: Records Are Added, Never Changed
Each linked device SHALL sign and chain its own records. Syncing SHALL only add records made by other linked devices. A received record SHALL be accepted only if its hash, chain link and signature verify against the public key of the device that made it. A record that fails verification SHALL NOT be accepted into the books; it SHALL be shown as "Not accepted: couldn't be verified (from <device>)", and every Owner SHALL be alerted.

#### Scenario: A verified record is added
- **WHEN** a linked device receives a correctly signed and chained record from another linked device
- **THEN** the record is added to its books and counted in balances

#### Scenario: A tampered record is refused
- **WHEN** a received record's signature or chain link does not verify
- **THEN** it is not added to the books, it is listed as "Not accepted", and Owners are alerted

### Requirement: The First Fix Wins
When the same posted entry has been fixed on two devices before they synced, the fix recorded first SHALL stand. The device that made the later fix SHALL record a new entry that cancels it, and both people SHALL see a notice naming the entry, both fixes and which one was kept. No record SHALL be edited or deleted.

#### Scenario: Two fixes of one purchase
- **WHEN** a purchase of 50 is fixed to 45 on one phone and to 40 on another, and the phones then sync
- **THEN** the fix recorded first stands, the other is cancelled by a new record, and both phones show "This purchase was fixed on two devices. Kept 45 (fixed first). Check it."

### Requirement: The Most Recent Change Wins for Shared Master Data
For changes to shared master data (categories, accounts, account groups, payees, rules, recurring templates and limits), the most recent change to each field SHALL win, and every device SHALL converge on the same result regardless of the order in which changes arrive.

#### Scenario: Rename and archive on two devices
- **WHEN** one device renames "Food" to "Groceries" and another device later archives "Food" before they sync
- **THEN** after syncing, every device shows the category named "Groceries" and archived

### Requirement: Shared and Per-Device Settings
Books settings SHALL be shared between linked devices: main currency, categories and their translations, limits, recurring templates, payees, rules, the default category language, reference rates, quote provider and default exchange. Device settings SHALL stay on each device and SHALL NOT be shared: app language, display preferences, research tool, App Lock and the backup reminder.

#### Scenario: Language stays on each device
- **WHEN** one linked device is set to German and another to English
- **THEN** after syncing, each device keeps its own language

#### Scenario: Main currency is shared
- **WHEN** an Owner changes the main currency
- **THEN** every linked device uses the new main currency after syncing
