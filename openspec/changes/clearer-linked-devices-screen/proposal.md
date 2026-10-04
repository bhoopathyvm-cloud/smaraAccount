## Why

Testing a small company on real devices (a Mac as Owner and Approver, two
iPhones as employees) showed that people can't tell what the Linked devices
screen is for. It is one flat list of seven buttons with no explanation. Your
own devices and other people appear in one list. Every device is called "This
device", and the roles use bookkeeping words ("Claimant") that nobody
recognises.

## What Changes

- The Linked devices screen is split into three labelled sections, each with a
  one-line explanation:
  - **My devices**: your own phones and computers, which share the full books.
  - **People**: others who use these books, such as employees who send
    expense claims.
  - **Join or sync**: Sync now, scan a QR to join, and the less common ways
    to connect, which sit behind "More ways to connect".
- The device you are holding is marked "(this device)".
- Roles are shown in plain words, and the role picker explains each choice:
  - Claimant becomes "Employee – sends expense claims".
  - Approver becomes "Approver – reviews and pays claims".
  - Owner becomes "Owner – full books".
  - Member becomes "Bookkeeper".
- Each device gets a name. The first time a device adds or joins, it asks for
  one, prefilled with the device type ("My iPhone", "My Mac", ...). Your own
  device can be renamed later, and the new name reaches linked devices with
  the next sync.

## Capabilities

### New Capabilities
- `linked-devices-screen`: how the Linked devices screen is organised and
  worded, and how devices are named.

### Modified Capabilities

## Impact

- `lib/ui/features/settings/views/linked_devices_section.dart` and its view
  model.
- `SettingsRepository.localDeviceDisplayName`, which is now actually set.
- A `linked_device` `displayName` metadata op when a device is renamed. Peers
  already apply this field.
- New ARB strings in all 48 locales.
- Widget tests, plus the acceptance and company-sync finders that tap these
  buttons.
