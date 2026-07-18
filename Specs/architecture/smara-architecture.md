# SmaraAccounting — System Architecture

> Structure inspired by an earlier project's architecture doc. None of that
> project's technology stack (Java/Spring Boot, Vue, PostgreSQL, Liquibase,
> a local LLM) applies here — this document describes a different system
> from scratch: a Flutter client-only accounting app with no backend at all.

## Overview

SmaraAccounting is a local-first, double-entry accounting application for
sole traders and small businesses, built with Flutter so a single codebase
runs on macOS, iOS, Android, and Windows. All data lives in a local SQLite
database on the device. There is **no server, no cloud storage, and no
network dependency** for the application to function.

Multi-device synchronization is planned as a **separate, later capability**:
LAN-only, peer-to-peer, triggered manually or by automatic on-LAN device
discovery, with no relay and no internet-hosted component. It is explicitly
**out of scope** for the current phase and is not reflected in the diagrams
below — see `openspec/changes/` for when that capability is scoped.

---

## Architecture Diagram (current phase — single device, no networking)

```text
┌───────────────────────────────────────────────────────────┐
│                     Flutter Application                   │
│                    (macOS / iOS / Android / Windows)       │
│                                                             │
│   UI Layer (Views)                                         │
│        │  listens to                                       │
│        ▼                                                    │
│   ViewModels (ChangeNotifier, via Provider)                 │
│        │  calls                                             │
│        ▼                                                    │
│   Repositories (domain-facing, single source of truth)      │
│        │  reads/writes                                      │
│        ▼                                                    │
│   Drift (typed, reactive layer over sqlite3)                 │
│        │                                                     │
│        ▼                                                    │
│   Local SQLite database file (on-device only)                │
└───────────────────────────────────────────────────────────┘
```

No process other than this application ever opens the database file
directly (see `smara-tech-guidelines.md` for the rule against shared/synced
folders holding a live SQLite file — relevant again once sync is scoped).

---

## Technology Stack

| Layer                  | Technology                                   | Reason |
|-------------------------|-----------------------------------------------|--------|
| UI framework            | Flutter                                       | One codebase for macOS, iOS, Android, Windows |
| Language                | Dart                                          | Native to Flutter |
| Architecture pattern     | MVVM + Repository (UI / Domain / Data layers) | Matches the `flutter-apply-architecture-best-practices` skill — official Flutter-recommended layering |
| State management / DI   | Provider, ViewModels extend `ChangeNotifier`  | Lightweight, Flutter-team maintained, minimal ceremony for a v1 of this size |
| Local database          | Drift (typed, reactive layer over `sqlite3`)  | Reactive streams suit a live-updating register/summary view; generated, typed migrations; one dependency covers all four target platforms without a separate desktop shim |
| Routing                 | `go_router` (declarative)                     | Matches the `flutter-setup-declarative-routing` skill; adopted from the start so deep-linking/back-stack behavior doesn't need retrofitting later |
| Backend                 | None                                          | Explicit product principle — no server, no cloud storage, no telemetry, no analytics |
| Sync (future, deferred) | LAN-only peer-to-peer, no relay, no server    | Scoped as its own later OpenSpec change; not designed or implemented yet |
| Data-at-rest encryption | Not yet decided                               | No requirement has called for it yet; revisit if/when a spec requires it rather than adding it speculatively |

### Testing tools (mapped to downloaded skills)

| Test tier            | Tool                                         | Skill |
|-----------------------|-----------------------------------------------|-------|
| Unit (domain/repository) | `package:test` / `flutter_test`            | `dart-add-unit-test` |
| Widget                | `flutter_test` `WidgetTester`                  | `flutter-add-widget-test` |
| Integration (full flow) | `integration_test` package                  | `flutter-add-integration-test` |
| Mocking dependencies   | `mockito` + `build_runner`                     | `dart-generate-test-mocks` |
| Coverage               | `package:coverage` → LCOV                      | `dart-collect-coverage` |
| Static analysis        | `dart analyze` + `dart fix --apply`            | `dart-run-static-analysis` |

Localization (`flutter_localizations` + `intl`, the `flutter-setup-localization`
skill) is not used in v1 — deferred until a second language is an actual
requirement, not built speculatively.

---

## Project Structure

```text
lib/
├── data/
│   ├── models/          # Drift table row models / DTOs
│   ├── repositories/    # Repository implementations (single source of truth)
│   └── database/        # Drift database class, tables, generated migrations
├── domain/
│   └── models/          # Clean domain models (Account, Category, JournalEntry, Posting)
├── ui/
│   ├── core/            # Shared widgets, theme (3-color palette), typography
│   └── features/
│       ├── register/
│       │   ├── view_models/
│       │   └── views/
│       ├── record_transaction/
│       │   ├── view_models/
│       │   └── views/
│       └── summary/
│           ├── view_models/
│           └── views/
└── main.dart

test/            # mirrors lib/ — unit + widget tests
integration_test/
```

This follows the `flutter-apply-architecture-best-practices` skill directly:
Views stay lean, ViewModels hold UI state and call Repositories, Repositories
are the only thing that talks to Drift.

---

## Data Flow — Record a Transaction

```text
1. User fills in amount, direction (in/out), category, transaction date
   View → ViewModel.recordTransaction(...)

2. ViewModel calls the ledger Repository
   Repository:
     a. Validates the domain command (balances to zero once expanded to
        debit/credit)
     b. Derives the two postings (financial account + selected category)
     c. Writes journal_entries + postings in a single Drift transaction
     d. Stamps recorded-at automatically (never user-supplied)

3. Drift's reactive query streams emit the new state
   Register view and running balance update automatically — no manual
   refresh call from the ViewModel
```

Reversal follows the same path through a distinct Repository method that
swaps debit/credit of the referenced entry and posts it as a new entry (see
`openspec/changes/core-ledger-single-account/specs/` for the exact
requirement).

---

## Security & Privacy Stance

```text
DATA RESIDENCY:
  All data stays on the device. No cloud calls of any kind.
  No external APIs. No telemetry. No analytics.

NETWORK:
  None in the current phase.
  Future LAN sync (separate change) will be local-network-only, with
  no relay and no internet-hosted component — carried over as a hard
  constraint from earlier exploration, not re-litigated per change.

AUTHENTICATION:
  None in the current phase (single user, single device). Any device
  passcode/biometric app-lock is a future, separately-scoped decision,
  not assumed here.
```

---

## Database Strategy

A single local SQLite database (via Drift) holds all application data for
this phase — one file per device, opened only by this application. SQLite's
practical size limits are far beyond what a sole trader or small business
ledger will ever produce; this is not a scaling concern for the phases
currently scoped. Multi-device replication strategy (per-device databases,
what gets synchronized) is deferred to the LAN-sync change and intentionally
not designed here.
