## ADDED Requirements

### Requirement: Every platform ships a real app icon, not the default template
iOS, macOS, and Android SHALL each ship an app icon reflecting SMARA Account's own identity, generated from a single master image, not the default `flutter create` template icon.

#### Scenario: No platform shows the default Flutter icon
- **WHEN** the app is built for iOS, macOS, or Android
- **THEN** its home-screen/Dock/launcher icon is the SMARA Account icon, not the default blue Flutter mark

### Requirement: Icon variants are generated, not hand-maintained per platform
Every per-platform, per-resolution icon variant SHALL be produced by running a generator (`flutter_launcher_icons`) against one master image, rather than maintained as separately hand-exported files per platform.

#### Scenario: Regenerating icons is a one-command operation
- **WHEN** the master icon image changes
- **THEN** re-running the icon generator updates every platform's icon set consistently, without manually re-exporting each platform's files by hand
