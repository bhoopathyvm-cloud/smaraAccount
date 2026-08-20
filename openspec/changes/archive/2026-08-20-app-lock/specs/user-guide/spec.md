## MODIFIED Requirements

### Requirement: User Guide Covers Every Shipped Feature
The repository SHALL contain a user guide at `docs/user-guide.md` that documents, in end-user terms, every screen and flow currently reachable in the app: onboarding and the device signing identity (recovery phrase, optional keystore export, confirmation), setting the base currency, restoring the ledger via a saved recovery phrase or keystore file, the home screen, recording a transaction, managing categories, managing accounts and account groups (including multi-currency accounts), transferring between accounts (same-currency and cross-currency, upfront fees, deducted-fee mode, pending/settlement), importing bank statements (OFX and CSV, column mapping, saved import profiles, keyword-to-category import rules and group assignment on preview), the register and running balance, the summary screen, settings (reference exchange rate lookup and provider selection), and the optional app lock (PIN or device biometrics, idle timeout, and app-switcher snapshot hiding). The guide SHALL NOT describe planned or proposed functionality that has not shipped.

#### Scenario: App lock is documented
- **WHEN** a user reads the settings section of the user guide
- **THEN** it explains how to enable app lock, choose PIN or biometrics, set the idle timeout, and what snapshot hiding does (and on which platforms it's available)
