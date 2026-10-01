## Purpose

Let two or more devices share the same books as Linked Devices: how a device is added, approved, given a role, removed and erased, and how every member is told about these changes, without any server.

## ADDED Requirements

### Requirement: Add a Device by QR Code
The system SHALL let a permitted member add a device from Settings → Linked devices → "Add a device". The existing device SHALL show a short-lived QR code. The new device SHALL scan it while both devices are on the same Wi-Fi. The two devices SHALL exchange their public signing keys and confirm the link on both screens before any books data is sent. The existing device SHALL then send the books directly to the new device over the local network.

#### Scenario: A phone joins by scanning the code
- **WHEN** an Owner taps "Add a device" on a laptop and a new phone on the same Wi-Fi scans the code and both screens confirm
- **THEN** the phone receives the books, creates its own Signing Identity, and appears in Linked devices on both devices

#### Scenario: An expired code is refused
- **WHEN** a code older than its validity period is scanned
- **THEN** the link is refused with a plain message and no data is sent

#### Scenario: Devices on different networks cannot link
- **WHEN** the scanning device cannot reach the showing device on the local network
- **THEN** linking fails with a message to join the same Wi-Fi, and no data is sent

### Requirement: Join by Restored Copy Requires Approval
A device that restored a Books Copy SHALL NOT exchange records with other devices until an already-linked device with permission to add devices approves its join request. The request SHALL be shown the first time both devices are on the same Wi-Fi, and approval SHALL take one tap.

#### Scenario: A restored device asks to join
- **WHEN** a device that restored a Books Copy meets a linked device on the same Wi-Fi
- **THEN** the linked device shows a join request naming the new device, and no records are exchanged until it is approved

#### Scenario: A rejected request shares nothing
- **WHEN** the join request is rejected
- **THEN** the requesting device stays unlinked and receives no new records

### Requirement: Owner and Member Roles
Every linked device SHALL have the role Owner or Member. Owners SHALL be able to add and remove devices, decide whether Members may add devices, erase removed devices, and make other members Owners. Members SHALL be able to record and fix entries and manage categories, accounts and other shared master data. The first device of a set of books SHALL be its Owner.

#### Scenario: A Member cannot add a device by default
- **WHEN** a Member opens Linked devices and Owners have not allowed Members to add devices
- **THEN** "Add a device" is not offered to that Member

#### Scenario: An Owner allows Members to add devices
- **WHEN** an Owner turns on "Members can add devices"
- **THEN** Members are offered "Add a device"

#### Scenario: An Owner makes another member an Owner
- **WHEN** an Owner changes a Member's role to Owner
- **THEN** that member can add and remove devices after the next sync

### Requirement: Every Member Is Told About Changes
When a device or person is added, removed, erased, or changes role, every linked device SHALL show a notice at its next sync, on Home and in Device history, naming the device, the change, who made it and when.

#### Scenario: Members see a new device
- **WHEN** an Owner adds "Anna's laptop" and another member's phone syncs later
- **THEN** that phone shows "Anna's laptop was added by Ravi on 5 Oct" on Home and in Device history

### Requirement: Remove and Erase a Device
An Owner SHALL be able to remove a linked device. From the moment of removal, no linked device SHALL accept records from it or send records to it. Records it made before removal SHALL remain in the books. An Owner MAY also ask for the removed device's books to be erased. The erase SHALL be carried out the next time the removed device is on the same Wi-Fi as a linked device. The Owner SHALL see "Erase pending" until then and "Erased on <date>" afterwards. The screen SHALL explain that a lost phone that never reconnects can only be erased with the phone maker's own find-and-erase service.

#### Scenario: A removed device's later records are refused
- **WHEN** a removed phone records an entry and later meets a linked device on the same Wi-Fi
- **THEN** the entry is not accepted by the linked device

#### Scenario: Earlier records stay
- **WHEN** a device is removed
- **THEN** every record it made before removal remains in the books and verified

#### Scenario: Erase happens on next contact
- **WHEN** an Owner chooses "Remove and erase" for a phone that is switched off
- **THEN** Linked devices shows "Erase pending", and the phone's books are erased the next time it is on the same Wi-Fi as a linked device, after which the Owner sees "Erased on <date>"

### Requirement: Claim Ownership When No Owner Remains
If no Owner device has been seen for the books, any Member SHALL be able to claim ownership. Every linked device SHALL be told at its next sync. The claim SHALL take effect 7 days after it was made, unless an Owner objects within that time. While only one Owner exists, the app SHALL suggest making a second Owner.

#### Scenario: A claim takes effect after 7 days
- **WHEN** a Member claims ownership and no Owner objects for 7 days
- **THEN** the Member becomes an Owner and every device records the change in Device history

#### Scenario: An Owner objects
- **WHEN** an Owner device syncs within 7 days and objects to the claim
- **THEN** the claim is cancelled and every device is told

### Requirement: Local Network Permission Is Asked Only When Needed
The system SHALL ask for local-network permission only when someone first opens Linked devices, never at app start. Before the system prompt, it SHALL explain in one plain sentence that finding devices on the same Wi-Fi is needed to share books and that nothing goes to the internet.

#### Scenario: A person who never shares is never asked
- **WHEN** a person uses the app without opening Linked devices
- **THEN** no local-network permission prompt is shown
