# Security Policy

SmaraAccounting is a local-first app: all ledger data stays on the
device, in a local SQLite database. There is no server and no user
account, so there is nothing to breach on our end. There is no
telemetry and no analytics.

The device's signing identity (recovery phrase / keystore) is held in
the OS-level secure keystore (Keychain, Keystore, Credential Manager,
depending on platform), not in the SQLite database itself.

The one optional network call the app makes is a reference
exchange-rate lookup (off by default, enabled per-device in Settings);
it sends only a currency pair to the chosen provider, never ledger
data. See `Specs/architecture/smara-architecture.md` for the full
network stance.

## Supported Versions

This project does not yet have a stable release line with a formal
support/EOL policy. Security fixes land on the current `main` branch.

## Reporting a Vulnerability

Please open a GitHub issue describing the problem. If the issue
involves sensitive details you'd rather not post publicly, say so in
the issue and we'll coordinate a private channel.
