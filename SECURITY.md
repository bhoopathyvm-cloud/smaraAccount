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

## How we scan

| Layer | Tool | What it covers |
| --- | --- | --- |
| Dependencies | OSV Scanner (`.github/workflows/security.yml`) | `pubspec.lock`, `requirements.txt`, and other lockfiles |
| Secrets | gitleaks (same workflow) | Full git history for committed keys/phrases |
| Dart / Flutter | `flutter analyze` + tests (`.github/workflows/flutter-ci.yml`) | App code under `lib/` and `test/` |
| Actions YAML | CodeQL advanced setup (`.github/workflows/codeql.yml`) | First-party GitHub Actions workflows only |

CodeQL does **not** support Dart. Default CodeQL setup auto-detects
C++/Swift/Kotlin/C from Flutter's generated `android/`, `ios/`,
`linux/`, `macos/`, and `windows/` folders and then warns because those
are platform stubs, not application code. This repo therefore uses an
**advanced** CodeQL config scoped to Actions workflows
(`.github/codeql/codeql-config.yml`).

If the Security tab still shows "CodeQL is reporting warnings" after
that workflow is on `main`, disable CodeQL **default** setup so only
advanced setup runs:

Settings → Code security → Code scanning → CodeQL → Disable default
setup.

## Supported Versions

This project does not yet have a stable release line with a formal
support/EOL policy. Security fixes land on the current `main` branch.

## Reporting a Vulnerability

Please open a GitHub issue describing the problem. If the issue
involves sensitive details you'd rather not post publicly, say so in
the issue and we'll coordinate a private channel.
