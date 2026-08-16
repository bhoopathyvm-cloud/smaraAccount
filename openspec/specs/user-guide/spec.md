# user-guide

## Purpose

An accurate, complete end-user guide to using the app's features, kept
scoped to what has actually shipped. (Purpose derived from the
`project-documentation` change; refine as the capability evolves.)

## Requirements

### Requirement: User Guide Covers Every Shipped Feature
The repository SHALL contain a user guide at `docs/user-guide.md` that documents, in end-user terms, every screen and flow currently reachable in the app: onboarding and the device signing identity (recovery phrase, optional keystore export, confirmation), setting the base currency, restoring the ledger via a saved recovery phrase or keystore file, the home screen, recording a transaction, managing categories, managing accounts and account groups (including multi-currency accounts), transferring between accounts (same-currency and cross-currency, upfront fees, deducted-fee mode, pending/settlement), importing bank statements (OFX and CSV, column mapping, saved import profiles), the register and running balance, the summary screen, and settings (reference exchange rate lookup and provider selection). The guide SHALL NOT describe planned or proposed functionality that has not shipped.

#### Scenario: Every current route has corresponding guide content
- **WHEN** a screen or flow is reachable via `lib/ui/app_router.dart` in the current codebase
- **THEN** the user guide contains a section describing how and why a user would use it

#### Scenario: Unshipped functionality is not documented as real
- **WHEN** the user guide is written
- **THEN** it does not describe any feature that exists only as an OpenSpec proposal not yet implemented

### Requirement: User Guide Explains the Signing-Key Tradeoff
The user guide SHALL clearly explain, before or alongside the onboarding instructions, that the device signing key cannot be recovered if lost, what a lost key means in practice (all entries must be re-created from scratch), and the two ways to preserve access to an existing identity (the recovery phrase and the optional keystore export) — consistent with the tradeoff already stated in `README.md`.

#### Scenario: Guide states the consequence of a lost key before the user needs it
- **WHEN** a user reads the onboarding section of the user guide
- **THEN** it explains, before describing how to complete onboarding, that losing the recovery phrase and keystore means permanent loss of the signing identity

#### Scenario: Guide explains both backup mechanisms
- **WHEN** a user reads the onboarding section of the user guide
- **THEN** it describes both the recovery phrase and the optional keystore export, and when each is used to restore access
