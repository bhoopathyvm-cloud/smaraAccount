## Purpose

Make the Linked devices screen understandable to people who are not
bookkeepers: what each button is for, who each entry is, and which device is
the one in your hand.

## ADDED Requirements

### Requirement: Sections with explanations
The Linked devices screen SHALL group its content into three sections,
**My devices**, **People** and **Join or sync**, and each section SHALL have
a heading and a one-line explanation.
- **My devices** lists the devices that were not added as a person.
- **People** lists the devices added through Add a person, shown by the
  person's name.

#### Scenario: Company with two employees
- **WHEN** the Owner's Mac has two employees added through Add a person
- **THEN** My devices lists the Mac, People lists both employees by name,
  and each section shows its explanation

#### Scenario: Less common ways to connect are tucked away
- **WHEN** the screen is shown
- **THEN** Sync now and Scan a QR to join are visible in Join or sync, and
  entering a code or connecting by address appear only after expanding
  "More ways to connect"

### Requirement: This device is marked
The entry for the device showing the screen SHALL be marked "(this device)".

#### Scenario: Marker on own device only
- **WHEN** two linked devices are listed
- **THEN** only the local device's entry carries "(this device)"

### Requirement: Roles in plain words
Each role SHALL be shown in plain words:
- Owner: "Owner – full books"
- Member: "Bookkeeper"
- Approver: "Approver – reviews and pays claims"
- Claimant-only: "Employee – sends expense claims"

The Add a person role picker SHALL show a one-sentence explanation under each
choice.

#### Scenario: Employee label
- **WHEN** a person was added as a Claimant
- **THEN** their entry reads "Employee – sends expense claims"

### Requirement: Devices have names
A device SHALL ask for its name, prefilled with its type, before it first
offers or joins through Linked devices when no name is stored. The name
SHALL be used:
- in the join request;
- in Wi-Fi discovery;
- in this device's membership entry.

The local device SHALL be renameable from its entry. A rename SHALL update
the local membership entry and SHALL emit a `linked_device` `displayName`
metadata operation, so peers show the new name after their next sync.

#### Scenario: First add asks for a name
- **WHEN** a device with no stored name taps Add my device
- **THEN** it asks "Name this device" prefilled with e.g. "My Mac", stores
  the answer, and then shows the QR

#### Scenario: Rename reaches peers
- **WHEN** the Mac renames itself to "Office Mac" and the phone syncs
- **THEN** the phone lists "Office Mac"

### Requirement: Books can be renamed on this device
Every entry in "Books on this device" SHALL offer **Rename**, including the
active books and books that have no name yet. A rename SHALL:
- be stored in that books set;
- stay on this device and never sync;
- reject a blank name.

The new-books and rename dialogs SHALL keep their text field usable until
the dialog has fully closed.

#### Scenario: Unnamed books get a real name
- **WHEN** the list shows "Books 1" and the user renames it to "Office"
- **THEN** the list shows "Office", and "Books 1" is gone
