## Why

Transfers already work end-to-end (`multi-account-ledger`'s "Transfer Between Financial Accounts", extended for cross-currency by `foreign-currency-settlement`), but the only entry point is a small icon in the Accounts tab's app bar — there is no way to start a transfer from the account you're already looking at in the Register, and the from-account isn't pre-selected. Separately, a real-world transfer often carries a cost the ledger has no way to capture today: a bank/intermediary commission (sometimes a stated fee, sometimes baked invisibly into a worse exchange rate than the market rate), and the user currently has no reference point for what the market rate even is when deciding whether a cross-currency transfer's implied rate is reasonable.

## What Changes

- Add a "Transfer" action next to the Register's existing "+" add-transaction button. Tapping it opens the Transfer screen with the currently-viewed account pre-selected as the source; the user only picks the destination account and amount.
- Let the user optionally record a transfer commission/fee at the same time as the transfer, posted as its own ordinary expense entry against the source account and a chosen expense category (e.g. "Bank Fees") — reusing the existing transaction-recording path rather than inventing a new ledger primitive. The transfer entry and the fee entry are separate, independently reversible journal entries, matching how many bank statements itemize it and requiring no change to the existing two-posting entry/register/reversal model.
- For cross-currency transfers, show an optional, best-effort reference exchange rate (fetched from a free, keyless external rate API when online) next to the destination-amount field, purely as an informational comparison — it never auto-fills the destination amount and never blocks the transfer if unavailable or offline. When both amounts are entered, the UI may also show the implied rate for comparison with that reference.
- Add a new Settings section (the app's first) where the user can turn the reference-rate lookup off entirely — **disabled by default**, since this is the app's first-ever network call — and, when enabled, choose which provider it uses from a fixed, predefined list. Adding a new provider to that list is a product/code change; there is no user-facing custom-provider option (no free-text URL or API key field).
- Register-scoped Transfer is only offered for **active** financial accounts (archived accounts stay on existing / forthcoming closeout rules, not this ordinary transfer path).
- **BREAKING (none):** no existing behavior changes; this only adds a new entry point and optional additions to the existing transfer flow, plus a new (opt-in) Settings surface.

## Capabilities

### New Capabilities
- `reference-exchange-rate-lookup`: best-effort, offline-safe fetching of an indicative market exchange rate for a currency pair, for display only (never for posting) — user-controlled via a Settings enable/disable toggle (default off) and a predefined-provider selector.

### Modified Capabilities
- `multi-account-ledger`: "Transfer Between Financial Accounts" gains an optional accompanying commission/fee entry (separate journal entry; no database FK) and clarifies that transfers are reachable from the account-scoped Register, pre-selecting that account as the source, in addition to the existing standalone Transfer screen.

## Impact

- `lib/ui/features/register/views/register_view.dart` / `register_view_model.dart`: expose a second action alongside the add-transaction FAB via an `onTransfer` callback (router-owned navigation, same pattern as `AccountManagementView.onTransfer`); disable/hide when the selected account is archived.
- `lib/ui/app_router.dart`: `/transfer` route accepts an optional `fromAccountId` query parameter, mirroring `/record-transaction?accountId=...`; `_buildRegister` wires `onTransfer` with that id.
- `lib/ui/features/transfer/view_models/transfer_view_model.dart` / `views/transfer_view.dart`: accept an initial from-account; orchestrate optional fee via `recordTransaction` after `recordTransfer` (validate fee first; handle partial failure); add optional reference-rate (and implied-rate) display for cross-currency pairs.
- New: a small `ExchangeRateService` (or similarly named) wrapping a free/keyless HTTP rate lookup against whichever of the predefined providers is selected — this is the app's first network dependency; it must never be required for the app's core (fully local-first) operation, and must make no request at all when the user has disabled it.
- New dependency: an HTTP client package (e.g. `http`), used only by this optional lookup.
- New: a `/settings` screen (the app's first), reachable from a new gear icon on `HomeView`'s app bar via an `onOpenSettings` callback wired in `app_router.dart` (optional `VoidCallback?`, matching `onSettlePendingTransfer`'s existing precedent on the same widget - not `onAccountTap`, which is `required` - so existing `HomeView` test call sites that omit it don't break), hosting the enable/disable toggle and the predefined-provider dropdown.
- New dependency: `shared_preferences` (or similar), used only to persist the two plain, non-secret settings above — `flutter_secure_storage` stays reserved for actual secret material.
- No `LedgerRepository`, schema, or register/reversal logic changes — the fee is posted via the existing `recordTransaction` (money-out, expense category) path used everywhere else. Fee orchestration and rate display live in the Transfer UI/ViewModel layer.
