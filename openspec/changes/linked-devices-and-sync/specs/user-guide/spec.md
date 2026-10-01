## ADDED Requirements

### Requirement: User Guide Documents Linked Devices and Sync
The user guide SHALL document Linked devices and Add a device (QR on the same Wi-Fi, and join after restoring a Books Copy), Sync now and the catch-up copy, Owner and Member roles, sole-Owner claim after 7 days, remove and erase (including Erase pending), notices that appear at the next sync, unverified records that are not accepted, competing Fix and category/account conflict outcomes, shared category translations and merge, and the books switcher for several sets of books on one device. The guide SHALL state that nothing goes to the internet for discovery or sync.

#### Scenario: Linked devices section exists
- **WHEN** a user reads the Settings or Linked devices section of the user guide after this change ships
- **THEN** it explains how to add a device, when devices catch up, roles, notices, erase pending, and that sync stays on the same Wi-Fi

#### Scenario: Books switcher is documented
- **WHEN** a user reads the guide after several books sets ship
- **THEN** it explains switching between fully separate books sets on one device

#### Scenario: Shared categories are documented
- **WHEN** a user reads the categories section of the user guide
- **THEN** it explains default language, translations, translate with AI, and merge
