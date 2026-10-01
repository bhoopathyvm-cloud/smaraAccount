# Architecture

This page summarizes the technical shape of the project for visitors.
The repository itself is the living source of truth — this page links
out to the full documentation rather than duplicating it, so the two
never quietly drift apart.

## Stack

- **Flutter / Dart**, one codebase across iOS, Android, macOS, and
  Linux (Linux validated in CI; a Windows target is scaffolded).
- **Localization** in 43 languages via Flutter's gen-l10n; money is
  always formatted by the currency's own convention.
- **Drift**, a typed, reactive layer over SQLite, for the local
  database — one file per device, opened only by this app.
- **Provider** for state management; ViewModels extend `ChangeNotifier`.
- **go_router** for declarative routing.
- No backend. No server, no cloud storage, no telemetry, no analytics.

## Layering: MVVM + Repository

The app is organized in layers, each with a single job:

- **Views** render UI and forward user actions. They hold no business
  logic and never call a Repository directly.
- **ViewModels** hold UI state, expose it as streams/listenables, and
  call into Repositories to read or change data.
- **Domain modules** (plain Dart) hold view-independent logic — in-progress
  form drafts, register/summary/home projections, navigation and lock
  policies — so it can be tested without any UI or database.
- **Repositories** are the single source of truth for a domain area —
  the only layer that talks to the database. Heavy paths such as
  signing-and-posting and chain verification are deep modules behind
  them, and the repositories' dependency graph is kept strictly acyclic.

Data flows one direction: Views listen to ViewModels, ViewModels use
domain modules and call Repositories, Repositories talk to Drift. This
keeps business logic out of widgets and out of the database layer, and
makes each piece testable on its own.

## Security And Privacy Stance

All ledger data stays on the device, in a local SQLite database. There's
no account and no cloud sync, and ledger data is never sent off-device.
The app's only network requests are predefined lookups that carry no
ledger data: an opt-in reference exchange-rate lookup (a currency pair),
investment market prices (on by default, can be turned off; a ticker or
ISIN only), and a one-time listing search when an instrument is added
(its ISIN or ticker only). See the [privacy policy](privacy-policy.md).

The device's signing identity lives in the OS-level secure keystore, not
in the SQLite file itself — the user can optionally back it up (recovery
Books Copy (books only, never the private key) — and
every posted journal entry is signed and hash-chained so that tampering
with a past entry breaks verification from that point forward, detected
the next time the app starts.

For users, this means the app treats unverifiable history as suspect
instead of silently including it in balances. It is useful during backup
restore, CSV export, accountant handoff, and any situation where the user
needs to know whether old records still match what was originally posted.
It is not a substitute for device security or backups, and it does not
prove that a transaction was true when entered; it detects later hidden
changes to the stored record.

The implementation is based on common integrity patterns: cryptographic
hashes act as content fingerprints, digital signatures bind those
fingerprints to the user's signing identity, and the hash chain makes
history order-sensitive. See [NIST on integrity](https://csrc.nist.gov/glossary/term/integrity),
[digital signatures](https://csrc.nist.gov/glossary/term/digital_signature),
and [hash functions](https://csrc.nist.gov/glossary/term/hash_function),
plus [Schneier/Kelsey on secure audit logs](https://www.schneier.com/academic/archives/1999/05/secure_audit_logs_to.html)
and [AWS QLDB's verifiable journal overview](https://aws.amazon.com/blogs/aws/now-available-amazon-quantum-ledger-database-qldb/)
for industry context.

## Full Documentation

For the complete, current picture — project structure, data flow
diagrams, the full technology-choice rationale, and the engineering
discipline (testing rules, dependency policy, Definition of Done) — see:

- [`smara-architecture.md`](https://github.com/bhoopathyvm-cloud/smaraAccount/blob/main/Specs/architecture/smara-architecture.md)
- [`smara-tech-guidelines.md`](https://github.com/bhoopathyvm-cloud/smaraAccount/blob/main/Specs/architecture/smara-tech-guidelines.md)
