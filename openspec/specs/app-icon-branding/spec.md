# app-icon-branding

## Purpose

Every platform build ships a real app icon reflecting Smara Account's own
identity, generated consistently from a single master image, rather than
the default `flutter create` template icon or hand-maintained per-platform
exports.

## Requirements

### Requirement: Every platform ships a real app icon, not the default template
iOS, macOS, Android, Windows, and Linux SHALL each ship an app icon reflecting Smara Account's own identity — the approved navy-and-ivory folded S with a calculator — generated from a single master image, not the default `flutter create` template icon and not the project's previous ledger-themed artwork.

#### Scenario: No platform shows the default Flutter icon
- **WHEN** the app is built for iOS, macOS, Android, Windows, or Linux
- **THEN** its home-screen/Dock/launcher/taskbar icon is the approved Smara Account icon, not the default blue Flutter mark and not the previous ledger artwork

### Requirement: Icon variants are generated, not hand-maintained per platform
Every per-platform, per-resolution icon variant SHALL be produced by running a single generator (`python3 tool/branding/generate_app_icon.py`) against one master image, rather than maintained as separately hand-exported files per platform. The master image SHALL be 1024 by 1024 pixels and the preview 20 by 20.

#### Scenario: Regenerating icons is a one-command operation
- **WHEN** the master icon image changes and the maintainer runs `python3 tool/branding/generate_app_icon.py`
- **THEN** the configured Apple, Android, and Windows launcher images update at their platform-specific sizes, including Android adaptive icons, without manually re-exporting each platform's files by hand
- **AND** the generator does not restore the previous ledger artwork

### Requirement: Linux desktop icon is available
The Linux runner SHALL embed the approved icon for GTK window use, and the build bundle SHALL include a desktop entry and matching application-ID icon for desktop integration by installers.

#### Scenario: Linux desktop icon is available
- **WHEN** the Linux runner is built
- **THEN** the approved icon is embedded in the executable for GTK window use
- **AND** the bundle includes a desktop entry and matching application-ID icon for desktop integration by installers
