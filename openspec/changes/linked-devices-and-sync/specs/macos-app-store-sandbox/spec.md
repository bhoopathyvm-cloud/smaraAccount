## ADDED Requirements

### Requirement: Local-network peer sync works under sandbox
The sandboxed macOS App Store build SHALL include the minimum local-network / Bonjour client entitlements needed for Linked devices discovery and encrypted peer sync on the LAN, and SHALL retain the ability to complete Add a device and Sync now against another device on the same Wi-Fi.

#### Scenario: Discovery works while sandboxed
- **WHEN** a user opens Linked devices on a sandboxed macOS build with local-network permission granted and a peer is on the same Wi-Fi
- **THEN** the peer can be discovered and a sync session can complete
- **AND** no relay or internet service is required

## MODIFIED Requirements

### Requirement: macOS Release build runs under App Sandbox
The macOS Release build configuration SHALL have `com.apple.security.app-sandbox` enabled, with the minimum entitlement set its actual file, Keychain, and local-network / Bonjour access patterns require for Books Copy import/export and Linked devices peer sync.

#### Scenario: Sandbox is on for Release
- **WHEN** the macOS app is built in the Release configuration
- **THEN** `com.apple.security.app-sandbox` is `true` in its entitlements

#### Scenario: Local-network entitlement is present when Linked devices ships
- **WHEN** the Release entitlements are inspected after this change
- **THEN** they include the minimum Bonjour / local-network client entitlement required for peer discovery and sync
