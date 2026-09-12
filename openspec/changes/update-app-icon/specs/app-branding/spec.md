## ADDED Requirements

### Requirement: Approved S-and-calculator app icon
The application SHALL use the user-approved navy-and-ivory folded S with a
calculator for iOS, macOS, Android, Windows, and Linux launcher icons.

#### Scenario: Platform icon assets are regenerated
- **WHEN** the maintainer runs `python3 tool/branding/generate_app_icon.py`
- **THEN** the configured Apple, Android, and Windows launcher images use the approved
  artwork at their platform-specific sizes, including Android adaptive icons
- **AND** the master image is 1024 by 1024 pixels and the preview is 20 by 20
- **AND** the generator does not restore the previous ledger artwork

#### Scenario: Linux desktop icon is available
- **WHEN** the Linux runner is built
- **THEN** the approved icon is embedded in the executable for GTK window use
- **AND** the bundle includes a desktop entry and matching application-ID icon
  for desktop integration by installers
