# Architecture

This page summarizes the technical shape of the project for visitors.
The repository itself is the living source of truth — this page links
out to the full documentation rather than duplicating it, so the two
never quietly drift apart.

## Stack

- **Flutter / Dart**, one codebase across macOS, iOS, Android, and
  Windows.
- **Drift**, a typed, reactive layer over SQLite, for the local
  database — one file per device, opened only by this app.
- **Provider** for state management; ViewModels extend `ChangeNotifier`.
- **go_router** for declarative routing.
- No backend. No server, no cloud storage, no telemetry, no analytics.

## Layering: MVVM + Repository

The app is organized in three layers, each with a single job:

- **Views** render UI and forward user actions. They hold no business
  logic and never call a Repository directly.
- **ViewModels** hold UI state, expose it as streams/listenables, and
  call into Repositories to read or change data.
- **Repositories** are the single source of truth for a domain area —
  the only layer that talks to the database.

Data flows one direction: Views listen to ViewModels, ViewModels call
Repositories, Repositories talk to Drift. This keeps business logic out
of widgets and out of the database layer, and makes each piece testable
on its own.

## Security and privacy stance

All ledger data stays on the device, in a local SQLite database. There's
no account, no cloud sync, and nothing sent off-device by default. The
one optional exception is a reference exchange-rate lookup, off by
default, which — when a user turns it on — sends only a currency pair to
a chosen provider for a comparison figure, never any ledger data.

The device's signing identity lives in the OS-level secure keystore, not
in the SQLite file itself, and every posted journal entry is signed and
hash-chained so that tampering with a past entry breaks verification
from that point forward, detected the next time the app starts.

## Full documentation

For the complete, current picture — project structure, data flow
diagrams, the full technology-choice rationale, and the engineering
discipline (testing rules, dependency policy, Definition of Done) — see:

- [`smara-architecture.md`](https://github.com/bhoopathyvm-cloud/smaraAccount/blob/main/Specs/architecture/smara-architecture.md)
- [`smara-tech-guidelines.md`](https://github.com/bhoopathyvm-cloud/smaraAccount/blob/main/Specs/architecture/smara-tech-guidelines.md)
