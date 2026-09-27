# Security Policy

SmaraAccounting is a local-first app: all ledger data stays on the
device, in a local SQLite database. There is no server and no user
account, so there is nothing to breach on our end. There is no
telemetry and no analytics.

The device's signing key and the optional app-lock PIN hash are held in
the OS-level secure storage (Keychain on Apple platforms, Android
Keystore, libsecret on Linux, the platform equivalent on Windows) via
`flutter_secure_storage`, not in the SQLite database itself. Exporting
the key — as a recovery phrase, a passphrase-encrypted keystore file, or
inside a passphrase-encrypted device migration bundle (books + key) — is
always an explicit, optional user action from Settings.

The app makes only predefined, user-visible network lookups, none of
which carry ledger data (amounts, quantities, costs, account names,
descriptions, payees):

- **Reference exchange rates** — off by default; sends a currency pair.
- **Investment market quotes** — on by default, can be turned off in
  Settings; sends an instrument's ticker/market symbol or ISIN.
- **Instrument identifier search** — when a new instrument is saved
  online; sends the ISIN or ticker being resolved.

Research-tool and identifier look-up prompts are opened in the system
browser (identifiers only, see ADR 0003); the app calls no AI API. See
`Specs/architecture/smara-architecture.md` for the full network stance
and the [privacy policy](pages/open-source/smara-account/privacy-policy.md)
for the user-facing description.

## How we scan

| Layer | Tool | What it covers |
| --- | --- | --- |
| Dependencies | OSV Scanner (`.github/workflows/security.yml`) | `pubspec.lock`, `requirements.txt`, and other lockfiles |
| Secrets | gitleaks (same workflow) | Full git history for committed keys/phrases |
| Dart / Flutter | `flutter analyze` + tests (`.github/workflows/flutter-ci.yml`) | App code under `lib/` and `test/` |
| Actions YAML | CodeQL advanced setup (`.github/workflows/codeql.yml`) | First-party GitHub Actions workflows only |
| Real-app behavior | Acceptance suite, nightly on Linux × 43 locales (`.github/workflows/acceptance-suite-nightly.yml`) | End-to-end flows incl. signing, backup/restore, app lock — a release gate, not a PR gate |

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
