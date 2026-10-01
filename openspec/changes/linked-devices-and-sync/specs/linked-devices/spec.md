## Purpose

Let two or more devices work on the same books as Linked devices: join in
person over Wi-Fi or after restoring a Books Copy, with Owner and Member
roles, honest remove and erase, and plain-language notices — without a
server holding membership or keys.

## ADDED Requirements

### Requirement: Linked Devices Section and Labels
The system SHALL expose linked-device membership under Settings labeled "Linked devices", and SHALL label the action that brings another device into the books "Add a device". The section SHALL explain in plain language that devices catch up when both have Smara open on the same Wi-Fi.

#### Scenario: Settings shows Linked devices
- **WHEN** a user opens Settings on a device that has books
- **THEN** a "Linked devices" section is available
- **AND** it offers "Add a device" when the user's role allows adding

#### Scenario: Catch-up copy is shown
- **WHEN** the user opens Linked devices
- **THEN** the screen includes the sentence "Your devices catch up when both have Smara open on the same Wi-Fi."

### Requirement: Local-Network Permission Asked Once at Entry
The system SHALL request local-network (or equivalent) permission only when the user first opens "Linked devices", and SHALL show this sentence first: "To share your books, Smara needs to find your other devices on this Wi-Fi. Nothing goes to the internet."

#### Scenario: First open explains before the system prompt
- **WHEN** a user opens Linked devices for the first time on a platform that requires local-network permission
- **THEN** the in-app sentence appears before the system permission prompt
- **AND** nothing is sent to the internet as part of that request

#### Scenario: Later opens do not re-prompt needlessly
- **WHEN** the user has already granted or denied local-network permission and opens Linked devices again
- **THEN** the system does not show the first-time explanation again unless permission must be re-requested by the OS

### Requirement: Add a Device With QR on the Same Wi-Fi
"Add a device" SHALL exchange public keys and device certificates in person via a QR code while both devices are on the same Wi-Fi, then send the books directly device to device. The private key of either device SHALL NEVER be included in the QR payload or the transfer.

#### Scenario: Successful in-person join
- **WHEN** an allowed user on device A chooses "Add a device", shows a QR code, and device B scans it on the same Wi-Fi
- **THEN** the devices exchange public identities and certificates
- **AND** device B receives the books and can record under its own Signing Identity
- **AND** neither private key leaves its device

#### Scenario: Join refused off the local network
- **WHEN** the devices are not on the same local network
- **THEN** the join does not complete over the internet or any relay
- **AND** the user is told they must be on the same Wi-Fi

### Requirement: Join After Restoring a Books Copy
A device that restored a Books Copy SHALL be able to send a join request that an already-linked device approves with one tap, after which the requester becomes a Linked device of those books under its own Signing Identity.

#### Scenario: Join request approved with one tap
- **WHEN** device B restored a Books Copy of books that already have linked devices, sends a join request, and an Owner (or Member allowed to add) on device A approves it with one tap while both are on the same Wi-Fi
- **THEN** device B is linked, receives catch-up data, and keeps its own Signing Identity
- **AND** every linked device is notified at the next sync

#### Scenario: Join request can be refused
- **WHEN** the approving device refuses the join request
- **THEN** device B is not linked and receives no further books updates from that set

### Requirement: Owner and Member Roles
Each Linked device SHALL have a role of Owner or Member. An Owner SHALL add and remove devices or people, decide who may add others, erase removed devices, and make other devices Owners. A Member SHALL record and fix entries and manage categories, and SHALL NOT perform Owner-only membership actions unless an Owner has granted a specific add permission that the design records.

#### Scenario: Owner can add and promote
- **WHEN** an Owner opens Linked devices
- **THEN** they can add a device, remove a device, erase a removed device, and make another linked device an Owner

#### Scenario: Member cannot remove without Owner power
- **WHEN** a Member opens Linked devices
- **THEN** they can record and fix entries and manage categories as usual
- **AND** they cannot remove, erase, or promote devices unless the books' Owner policy explicitly allows them to add devices

### Requirement: Sole Owner Claim After Seven Days
When no Owner device remains reachable in the books' membership, a Member SHALL be able to claim ownership. Every linked device SHALL be told. The claim SHALL take effect after 7 days unless an Owner objects before then. The system SHALL suggest adding a second Owner once more than one device is linked.

#### Scenario: Claim becomes Owner after seven days
- **WHEN** a Member claims ownership because no Owner remains, and seven days pass with no Owner objection arriving on a sync
- **THEN** that Member's device becomes an Owner
- **AND** every linked device that syncs sees the notice

#### Scenario: Owner objection cancels the claim
- **WHEN** an Owner objects to a pending sole-Owner claim before it takes effect
- **THEN** the claim is cancelled and membership is unchanged

#### Scenario: Second Owner suggestion
- **WHEN** books have only one Owner and at least one other linked device
- **THEN** Linked devices suggests adding a second Owner

### Requirement: Remove Stops New Sync Without Rewriting History
Any device allowed by the Owner policy SHALL be able to remove another linked device. From that moment the removed device SHALL receive nothing new from those books. Entries the removed device already signed SHALL remain in the books (they were genuine when made).

#### Scenario: Removed device stops receiving updates
- **WHEN** device A removes device B and both later meet on Wi-Fi
- **THEN** device B does not receive new entries or membership changes for those books
- **AND** entries previously signed by device B stay in the books and still verify

### Requirement: Erase Is Honest and Pending Until Next Contact
Erasing a removed device SHALL happen the next time that device is on the same Wi-Fi and reachable. Until then the Owner SHALL see "Erase pending". After a successful erase the Owner SHALL see "Erased on \<date\>". For a device that will never return, the UI SHALL point the user to Apple's or Google's Find my device / Erase rather than pretending the app can wipe it remotely.

#### Scenario: Erase pending then completed
- **WHEN** an Owner chooses Erase for a removed device that is offline
- **THEN** Linked devices shows "Erase pending"
- **AND** when that device next contacts a linked peer on the same Wi-Fi, its local copy of those books is erased and the Owner sees "Erased on \<date\>" after the next sync

#### Scenario: Lost phone points to platform erase
- **WHEN** the user indicates the device is lost and will not return
- **THEN** the UI explains that Smara cannot erase it over the internet and points to the platform Find my device / Erase path

### Requirement: Membership Notices on Next Sync
Every linked device SHALL be told when a device or person is added or removed. Notices SHALL appear in the app at the next sync on Home and in Device history. The system SHALL NOT rely on push notifications or any server.

#### Scenario: Add notice appears after sync
- **WHEN** a new device is linked and another linked device later syncs
- **THEN** that device shows a notice on Home and in Device history that a device was added

#### Scenario: No push channel
- **WHEN** a membership change happens while another device is offline
- **THEN** that device learns of it only when it next syncs on the same Wi-Fi, not via a push service
