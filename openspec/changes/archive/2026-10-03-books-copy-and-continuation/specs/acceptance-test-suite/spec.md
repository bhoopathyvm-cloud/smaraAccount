## ADDED Requirements

### Requirement: Real-Build Acceptance Flow for Saving and Restoring a Books Copy
The system SHALL provide an acceptance test that drives a real, launched build of the app — by reusing the app's actual root widget from `main.dart`, not a hand-rebuilt widget tree — through its GUI to: complete onboarding, record at least one transaction, save a Books Copy through the real Settings UI, simulate a fresh device by resetting the app's real on-disk database and real OS keychain, and restore through the real "Restore from a copy" UI, ending in Continuation. The test SHALL assert, after restore, that the recorded entries and their running balances are present and unchanged.

#### Scenario: Entries recorded on the first device reappear after restore on a simulated second device
- **WHEN** the acceptance test records a transaction through the GUI, saves a Books Copy, resets local app storage and keychain to simulate a new device, and restores the copy through the GUI
- **THEN** the restored app's register shows the same entry with the same amount and running balance as before the reset
- **AND** a new transaction can be recorded immediately under the device's new identity

#### Scenario: Restore fails obviously if the wrong passphrase is used
- **WHEN** the acceptance test attempts to restore the saved copy with an incorrect passphrase after the same storage/keychain reset
- **THEN** the real restore UI shows an error and no entries are restored

#### Scenario: Books that keep their database but lose their key continue
- **WHEN** the acceptance test resets only the OS keychain, keeping the database, and relaunches the app
- **THEN** the real UI offers "Continue my books on this phone", and after continuing, the register shows the same entries and a new transaction can be recorded

#### Scenario: The acceptance harness cannot silently diverge from the real app
- **WHEN** the acceptance test builds the app under test
- **THEN** it does so by launching the same root widget `main.dart` launches, so a change to how the app's own widget tree is assembled is automatically exercised by this tier without the test needing a matching update

## REMOVED Requirements

### Requirement: Real-Build Acceptance Flow for Recording and Restoring Entries
**Reason**: The flow restored through the recovery phrase, which is removed.
**Migration**: Replaced by `Real-Build Acceptance Flow for Saving and Restoring a Books Copy`, which saves a copy, resets the device, restores the copy and continues the books.
