# SmaraAccounting — System Architecture

> Structure inspired by an earlier project's architecture doc. None of that
> project's technology stack (Java/Spring Boot, Vue, PostgreSQL, Liquibase,
> a local LLM) applies here — this document describes a different system
> from scratch: a Flutter client-only accounting app with no backend at all.

## Overview

SmaraAccounting (shipped as **SMARA Account**) is a local-first household
ledger: a signed, double-entry ledger under the hood, surfaced to the user as
a plain record of what they spent and received (see `CONTEXT.md` and
`docs/household-term-map.md`). It is built with Flutter so a single codebase
runs on macOS, iOS, Android, Linux, and Windows (Linux is validated in CI by
the weekly acceptance suite; Windows is a scaffolded Flutter target without
CI validation). All data lives in a local SQLite database on the device.
There is **no server, no cloud storage, and no network dependency** for the
application to function.

Multi-device synchronization is planned as a **separate, later capability**:
LAN-only, peer-to-peer, triggered manually or by automatic on-LAN device
discovery, with no relay and no internet-hosted component. It is explicitly
**out of scope** for the current phase and is not reflected in the diagrams
below — see `openspec/changes/` for when that capability is scoped. Moving
books to a new device today is done with a one-file, passphrase-protected
**Books Copy** (`books-copy` / books-copy-and-continuation), not sync. The
private signing key never leaves the device; Continuation continues books
under a new this-device key when the matching private key is missing.

---

## Architecture Diagram (current phase — single device, no networking)

```text
┌───────────────────────────────────────────────────────────┐
│                     Flutter Application                   │
│          (macOS / iOS / Android / Linux / Windows)         │
│                                                             │
│   UI Layer (Views)                                         │
│        │  listens to                                       │
│        ▼                                                    │
│   ViewModels (ChangeNotifier, via Provider)                 │
│        │  own drafts/sessions, call                         │
│        ▼                                                    │
│   Domain modules (lib/domain: drafts, engines, policies —   │
│     pure Dart, no Drift)            │                        │
│        ▼                            ▼                        │
│   Repositories (domain-facing, single source of truth;      │
│     composed of deep posting/chain/verifier modules)        │
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
| UI framework            | Flutter                                       | One codebase for macOS, iOS, Android, Linux, Windows |
| Language                | Dart                                          | Native to Flutter |
| Architecture pattern     | MVVM + Repository (UI / Domain / Data layers) | Matches the `flutter-apply-architecture-best-practices` skill — official Flutter-recommended layering |
| State management / DI   | Provider, ViewModels extend `ChangeNotifier`  | Lightweight, Flutter-team maintained, minimal ceremony for a v1 of this size |
| Local database          | Drift (typed, reactive layer over `sqlite3`)  | Reactive streams suit a live-updating register/summary view; generated, typed migrations; one dependency covers every target platform without a separate desktop shim |
| Secure key storage      | `flutter_secure_storage`                      | Signing key and app-lock PIN hash live in the OS keychain/keystore (Keychain, Android Keystore, libsecret on Linux), never in the SQLite file |
| Signing / crypto        | `cryptography` (Ed25519, PBKDF2, AES-GCM)     | Entry signing and hash chaining; PIN hashing; passphrase-encrypted Books Copy files |
| Localization            | `flutter_localizations` + `intl` (gen-l10n)   | 43 locales (`lib/l10n/app_<tag>.arb`, English is the template); money formatting follows each currency's own convention, not the UI locale |
| App lock                | `local_auth`                                  | Optional biometric convenience on top of the PIN |
| Network (opt-in lookups)| `http`                                        | Reference exchange rates and market quotes only — see Security & Privacy Stance |
| Routing                 | `go_router` (declarative)                     | Matches the `flutter-setup-declarative-routing` skill; adopted from the start so deep-linking/back-stack behavior doesn't need retrofitting later |
| Backend                 | None                                          | Explicit product principle — no server, no cloud storage, no telemetry, no analytics |
| Sync (future, deferred) | LAN-only peer-to-peer, no relay, no server    | Scoped as its own later OpenSpec change; not designed or implemented yet |
| Data-at-rest encryption | Not for the live database                     | The live SQLite file is not encrypted (device/OS security protects it); exported Books Copies are passphrase-encrypted. Revisit only if a spec requires it |

### Testing tools (mapped to downloaded skills)

| Test tier            | Tool                                         | Skill |
|-----------------------|-----------------------------------------------|-------|
| Unit (domain/repository) | `package:test` / `flutter_test`            | `dart-add-unit-test` |
| Widget                | `flutter_test` `WidgetTester`                  | `flutter-add-widget-test` |
| Integration (full flow) | `integration_test` package                  | `flutter-add-integration-test` |
| Acceptance (real launched app) | `integration_test/acceptance/` via `tool/run_acceptance_tests.sh` | — (see tech guidelines) |
| Mocking dependencies   | `mockito` + `build_runner`                     | `dart-generate-test-mocks` |
| Coverage               | `package:coverage` → LCOV                      | `dart-collect-coverage` |
| Static analysis        | `dart analyze` + `dart fix --apply`            | `dart-run-static-analysis` |

Localization uses `flutter_localizations` + `intl` gen-l10n (the
`flutter-setup-localization` skill). `lib/l10n/app_en.arb` is the only
human-authored source; the other 42 locale packs follow
`lib/l10n/TRANSLATION_WORKFLOW.md` and `TRANSLATION_GLOSSARY.md`.

---

## Project Structure

```text
lib/
├── data/
│   ├── database/        # Drift database class, tables, generated migrations
│   ├── repositories/    # One repository per domain concept (identity,
│   │                    #   ledger, accounts, categories, payees, recurring
│   │                    #   templates, investments, settings, backup,
│   │                    #   Books Copy, statement import) plus
│   │                    #   the deep modules they compose: LedgerPosting,
│   │                    #   LedgerChainStore, LedgerChainVerifier,
│   │                    #   AccountChartReader, InvestmentTradePosting,
│   │                    #   KeyLossMigrationEngine
│   ├── exchange_rate_service.dart     # Opt-in reference-rate lookup
│   ├── instrument_quote_service.dart  # Market quotes + identifier search
│   └── instrument_quote_refresh.dart  # Background quote refresh/resolution
├── domain/              # Pure Dart — never touches Drift
│   ├── models/          # Domain models and closed-set enums
│   ├── crypto/          # Signing identity, Ed25519, canonical hashing,
│   │                    #   secure storage (this-device-only)
│   ├── backup/          # Books Copy file (legacy backup/bundle readers)
│   ├── account/ correction/ record_transaction/ recurring/ transfer/
│   │                    # Mutable per-flow drafts owned by a ViewModel
│   ├── register/ summary/ home/ ledger_export/
│   │                    # Projection/engine modules shared by UI + export
│   ├── investment/      # Holdings replay, trade-order drafts, ISIN
│   │                    #   validation, exchange registry, currency inference
│   ├── statement_import/ ofx/ csv/
│   │                    # Parsers, import session/preview, category rules
│   ├── lock/            # App-lock policy/session, PIN service, biometrics
│   ├── navigation/      # Startup/resume routing policy
│   └── money/ time/ transaction/   # Currency minor units, IsoDate, etc.
├── l10n/                # ARB locale packs (43) + generated localizations
├── ui/
│   ├── core/            # Shared widgets (MoneyAmountField, EntityPickerField,
│   │                    #   StatusBanner, confirmDestructiveAction,
│   │                    #   showManagedDialog, ...), theme, typography,
│   │                    #   AppShell (bottom bar / navigation rail)
│   ├── app_router.dart  # go_router routes + redirects
│   └── features/        # each feature follows view_models/ + views/
│       ├── setup_choice/        # New setup vs Import from backup
│       ├── onboarding/          # language, currency, first account
│       ├── first_week_setup/
│       ├── restore/  migration/ # key restore, true key-loss migration
│       ├── lock/
│       ├── home/  register/  summary/
│       ├── record_transaction/  correction_wizard/
│       ├── transfer/  settle_pending_transfer/
│       ├── account_management/  category_management/
│       ├── payee_management/  recurring_template_management/
│       ├── holdings/
│       ├── statement_import/
│       └── settings/            # incl. Books Copy save/restore, Device
│                                #   history, copy reminder
└── main.dart            # Provider/ProxyProvider DI graph

test/              # mirrors lib/ — unit + widget tests
integration_test/  # integration tests; acceptance/ holds the real-app tier
```

This follows the `flutter-apply-architecture-best-practices` skill:
Views stay lean, ViewModels hold UI state and orchestrate, domain modules
hold view-agnostic logic (drafts, projections, policies), and Repositories
are the only thing that talks to Drift. Module shape, seam placement, and
DI wiring conventions for this layering are in
`docs/agents/architecture-deepening.md`; the repository dependency graph
must stay acyclic (`docs/adr/0002-repository-family-acyclic-dependency-graph.md`).

---

## Data Flow — Record a Transaction

```text
1. User fills in account, Spent/Received, amount, category, date,
   description (optionally a split or a foreign currency)
   View → ViewModel, which edits a RecordTransactionDraft
   (lib/domain/record_transaction) — canSubmit etc. are computed there

2. ViewModel calls LedgerRepository.recordTransaction(...), which
   delegates to LedgerPosting:
     a. Validates the command (active account/category via
        AccountChartReader; postings sum to zero)
     b. Derives the postings (account leg + one leg per category)
     c. Canonicalizes, hashes, and signs the entry with the current
        Signing Identity, chaining it onto the trusted tip
        (LedgerChainStore)
     d. Writes journal_entries + postings + chain state in a single
        Drift transaction; recorded-at is stamped automatically
        (never user-supplied)

3. Drift's reactive query streams emit the new state
   Register rows (lib/domain/register projection) and balances
   (active-balance rules, which exclude quarantined and
   migration-superseded entries) update automatically — no manual
   refresh call from the ViewModel
```

A correction (household word: "Fix") follows the same path: the
Correction wizard's `CorrectionDraft` produces a reversal entry that
references the original via `reversesEntryId` plus a new corrected entry;
the original row is never updated or deleted (see
`openspec/specs/correction-wizard/spec.md` and
`openspec/specs/core-ledger-single-account/spec.md`).

---

## Security & Privacy Stance

```text
DATA RESIDENCY:
  All ledger data stays on the device. No cloud storage, no telemetry,
  no analytics.

NETWORK:
  The app functions fully offline. The only outbound requests are
  predefined, user-visible lookups that never carry ledger data
  (account ids, amounts, quantities, costs, descriptions, payees):

  - Reference exchange rates — OFF by default (Settings > Fetch
    reference exchange rates). Sends only a currency pair to the
    chosen provider (Frankfurter or ExchangeRate-API) to show a
    comparison figure next to a cross-currency transfer's
    destination-amount field. Never fills in or validates the amount.
  - Investment market quotes — ON by default (Settings > Fetch market
    prices for investments). Background refresh sends only an
    instrument's ticker/market symbol or ISIN to the chosen provider
    (Stooq or Yahoo Finance) to compute a labeled market estimate.
    Quotes are never posted to the journal.
  - Instrument identifier search — when a new instrument is saved
    online, one search (Yahoo Finance) keyed on the ISIN or ticker
    only, so the user can confirm the listing; offline saves defer
    resolution to the next background refresh.

  Opening the favourite research tool (identifiers-only prompt, ADR
  0003), the instrument look-up prompt, or the Privacy Policy hands a
  URL to the system browser; the app itself calls no AI API.

  Future LAN sync (separate change) will be local-network-only, with
  no relay and no internet-hosted component — carried over as a hard
  constraint from earlier exploration, not re-litigated per change.

AUTHENTICATION:
  Optional app lock is available on-device. When enabled, opening the
  app or returning after the configured idle timeout requires the user's
  app PIN, with device biometrics as an optional convenience fallback
  where supported. The PIN hash is stored in OS secure storage (ADR 0001) and
  verified off the UI isolate (PBKDF2). Separately, the app can hide
  its content in the OS app-switcher snapshot. This protects casual
  local access; it does not replace the signed-history integrity model
  or OS-level device security.

KEY MATERIAL & EXPORTS:
  The signing key lives only in OS secure storage and never leaves the
  device (no recovery phrase or keystore export). A passphrase-encrypted
  Books Copy carries books and books settings only, never key material.
  Restoring a copy replaces rather than merges; Continuation continues
  books under a new this-device key when the private key is missing.
```

The signed-history model follows common integrity and audit-log patterns:
hashes act as content fingerprints, digital signatures verify that those
fingerprints came from the user's signing identity, and chaining makes
the order of history verifiable. See the non-normative background links
in `openspec/specs/ledger-integrity-signing/spec.md`, especially NIST's
definitions of integrity, digital signatures, and hash functions, OWASP's
logging guidance, and Schneier/Kelsey's secure audit-log research.

---

## Database Strategy

A single local SQLite database (via Drift) holds all application data for
this phase — one file per device, opened only by this application. SQLite's
practical size limits are far beyond what a household ledger will ever
produce; this is not a scaling concern for the phases
currently scoped. Multi-device replication strategy (per-device databases,
what gets synchronized) is deferred to the LAN-sync change and intentionally
not designed here.
