## Purpose

Lets a person link a device to a set of books by typing a short code instead of scanning a QR code, for devices without a usable camera, with the same protection against joining the wrong device.

## ADDED Requirements

### Requirement: Inviting Device Offers a Join Code Beside the QR Code
When an allowed user chooses "Add a device", the inviting device SHALL show a short join code next to the QR code. The code SHALL be 8 characters from an alphabet without look-alike characters, shown in two groups (for example `K7QF-3M9P`). It SHALL expire 2 minutes after it is shown, SHALL be usable for one join only, and a new code SHALL be shown when it expires or is used.

#### Scenario: Code shown with the QR code
- **WHEN** the Owner chooses "Add a device" on the Mac
- **THEN** the screen shows the QR code and a code in the form `XXXX-XXXX`, with the time left before it expires

#### Scenario: An expired code is refused
- **WHEN** a joining device enters a code more than 2 minutes after it was shown
- **THEN** the join is refused with "This code has expired — ask for a new one", and nothing is exchanged

#### Scenario: A used code is refused
- **WHEN** a second device enters a code that another device already used to join
- **THEN** the join is refused, and the first device's join is unaffected

### Requirement: Joining Device Can Enter the Code Instead of Scanning
The join screen on the joining device SHALL offer "Enter code instead". It SHALL accept the code with or without the dash and in either letter case, and SHALL find the inviting device on the same network. It SHALL NOT need the internet.

#### Scenario: Typing the code finds the inviter
- **WHEN** an employee's phone on the same network chooses "Enter code instead" and types `k7qf3m9p`
- **THEN** the phone finds the inviting device and moves on to the check code

#### Scenario: No inviter on this network
- **WHEN** the code is valid but no device is offering it on this network
- **THEN** the phone shows "No device with this code on this Wi-Fi" and offers to try again

### Requirement: Both Screens Confirm the Same Check Code Before Anything Is Exchanged
After a code is entered, both devices SHALL show the same 6-digit check code, derived from both devices' public keys and the session. Books, keys or certificates SHALL be exchanged only after a person confirms on both devices that the codes match. If either side says they do not match, the join SHALL be cancelled, the code SHALL be used up, and nothing SHALL be stored.

#### Scenario: Matching check codes complete the join
- **WHEN** both screens show `482 913` and the person confirms on both
- **THEN** the devices exchange certificates and the books arrive on the joining device

#### Scenario: Different check codes stop the join
- **WHEN** the person chooses "They don't match" on either device
- **THEN** the join is cancelled on both devices, no certificate is pinned, and the code can no longer be used

#### Scenario: The private key never travels
- **WHEN** a device joins by code
- **THEN** no private key of either device is sent, as with joining by QR
