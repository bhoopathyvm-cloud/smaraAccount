## ADDED Requirements

### Requirement: Local mDNS Discovery Works on Linux
On the Linux desktop target, Linked devices discovery SHALL use local mDNS/Bonjour equivalent advertising and browsing for the Smara service type on the LAN, so two Linux builds (or Linux and another platform) on the same network can find each other for peer sync without a server.

#### Scenario: Two Linux peers discover each other
- **WHEN** two linked Linux desktop instances have the app open on the same LAN with discovery enabled
- **THEN** each can discover the other as a Smara peer
- **AND** no internet directory is consulted

#### Scenario: Nightly Linux can exercise in-memory dual-device without real mDNS
- **WHEN** CI runs the two-in-memory-device peer-sync harness on Linux
- **THEN** linking and sync assertions pass without requiring a physical second host
