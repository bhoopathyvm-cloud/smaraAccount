## ADDED Requirements

### Requirement: Real-Build Coverage of PIN Unlock on Every Acceptance Target
The system SHALL provide an acceptance test that drives a real launched build to enable PIN lock, reach the Lock screen, enter the correct PIN through the real Lock UI, and assert the main shell is reachable again. That scenario SHALL pass unmodified on macOS, iOS (simulator or physical device), and Android emulator targets used by the acceptance tier.

#### Scenario: Unlock after lock on macOS
- **WHEN** the acceptance unlock scenario runs with `-d macos`
- **THEN** it passes end to end including successful PIN entry on the Lock screen

#### Scenario: Unlock after lock on iOS
- **WHEN** the same scenario runs against an iOS simulator or wipeable physical device
- **THEN** it passes without scenario code changes

#### Scenario: Unlock after lock on Android
- **WHEN** the same scenario runs against an Android emulator
- **THEN** it passes without scenario code changes
