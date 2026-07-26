## Context

Transfers post through `LedgerRepository.recordTransfer` (same-currency: one balanced entry; cross-currency: a complete entry when the destination amount is known, otherwise a provisional entry settled later via `settlePendingTransfer`). The only UI entry point is `TransferView`, reachable solely from a small icon in `AccountManagementView`'s app bar (`onTransfer`), with no account pre-selected. `RegisterView` (the account-scoped ledger view, effectively "account details") has an add-transaction FAB but no transfer affordance at all.

Two real-world costs of a transfer aren't captured anywhere: a stated commission/fee, and the spread between the rate the bank actually gave and the market rate (an invisible cost). Note that `settlePendingTransfer` already has a `feeCategoryId` concept, but only for the shortfall when a *pending* cross-currency transfer settles for less than its provisional amount — that's a different, narrower case (post-hoc reconciliation of an unknown amount), not "I know today that this transfer costs a stated fee."

This app is explicitly local-first / offline-capable (`Specs/architecture/smara-architecture.md`) and today makes zero network calls. Any exchange-rate lookup is a first for the app and must not compromise that property.

## Goals / Non-Goals

**Goals:**
- A "Transfer" action reachable from the Register, pre-selecting the currently-viewed account as the source.
- Let the user optionally record a commission/fee at transfer time, without inventing a new ledger primitive or touching register/reversal/balance logic.
- Show an optional, best-effort reference exchange rate for cross-currency transfers, for comparison only.
- Preserve the app's fully-offline-capable core: the rate lookup is decoration, never a dependency of the transfer flow succeeding.
- Let the user turn the reference-rate lookup off entirely, and choose which provider it uses from a fixed, predefined set — both via a new Settings section.

**Non-Goals:**
- Changing `recordTransfer`, `settlePendingTransfer`, or the journal-entry/posting model.
- Auto-filling the destination amount from the fetched rate (the user's actual received amount is always what gets posted, never a computed guess).
- A general-purpose FX conversion feature, historical rate charts, or automatic multi-provider fallback (if the selected provider fails, the rate is simply omitted - the app does not silently try a different one).
- Retroactively linking the fee entry to the transfer entry at the database level (see Decision 3).
- A user-facing "add a custom provider" option (custom URL, API key entry, etc.) - the provider list is a fixed, code-defined set; adding a new one is a product/code change, not a setting (see Decision 5).
- A general-purpose Settings screen/framework - this change adds the minimum surface needed to host these two controls, not a broader preferences architecture.

## Decisions

### 1. Register-scoped Transfer entry point mirrors the existing Record-Transaction pattern

`RegisterView` gains a second action next to the add-transaction FAB. `Scaffold.floatingActionButton` is a single slot, so the apply step SHOULD place both actions in a small `Column` (or equivalent) of FABs — each with a distinct `heroTag` (see tasks; `StatefulShellRoute.indexedStack` keeps tabs mounted). An app-bar icon is an acceptable alternative if two FABs feel crowded; either way there are two explicit intents, not a chooser sheet.

`app_router.dart`'s `_buildRegister` already computes `selectedAccountId` for the add-transaction route; the new Transfer action reuses that same value and navigates to `/transfer?fromAccountId=<id>`, exactly mirroring how `/record-transaction?accountId=<id>` already works. Wire it as an `onTransfer` callback from the router into `RegisterView` (same pattern as `AccountManagementView.onTransfer`), rather than giving `RegisterView` a `GoRouter` dependency.

`TransferViewModel` gains an `initialFromAccountId` constructor parameter (parallel to `RecordTransactionViewModel.initialFinancialAccountId`). Match that VM's real pattern: apply the initial id on the **first** `watchFinancialAccounts` emission while `_fromAccountId` is still null (RTVM does `initialFinancialAccountId ?? accounts.first.id` inside the listener — it does not pre-assign in the constructor body). Improve on RTVM in one respect: only accept `initialFromAccountId` when that id is present in the active-accounts list; if it is missing (unknown/archived), fall back to the same default-selection behavior as an unscoped Transfer open (first active account / first distinct destination), and never keep a stale archived source id selected.

The Transfer affordance on the register SHALL be offered only when the currently viewed account is an **active** financial account. Archived accounts remain transfer-ineligible via `recordTransfer`'s existing `_requireActiveFinancialAccount` gate; `archived-account-restrictions` (in progress) further replaces ordinary transfers from archived accounts with a dedicated closeout flow — this change must not add a competing "ordinary transfer from archived register" path.

**Cross-change note:** `archived-account-restrictions`'s own design already plans a `bool get isSelectedAccountArchived` getter on `RegisterViewModel` (derived from `_accountsById[_selectedAccountId]?.archived`), for the same reason: disabling *its* add-transaction FAB for an archived account. This change needs the identical getter to disable the new Transfer action. Whichever of the two changes is applied first adds the getter; the second SHOULD reuse it rather than adding a second, differently-named one on the same class - check for it before assuming it doesn't exist.

**Alternative considered:** a single shared "add" action that asks transaction-vs-transfer first. Rejected — two explicit actions match the existing FAB-per-intent pattern (Record Transaction already has its own entry point; this just gives Transfer parity) and need no new intermediate UI.

### 2. Commission/fee is a separate `recordTransaction` call, not a new ledger primitive

A transfer with a fee posts as **two** independent journal entries via two existing repository calls:
1. `recordTransfer(...)` — unchanged. Here `amountMinor` is always the **source-leg** amount (what leaves the source account). For cross-currency known-rate transfers, `destinationAmountMinor` is what arrives at the destination; for same-currency transfers there is no separate destination amount field.
2. `recordTransaction(direction: moneyOut, financialAccountId: <source>, categoryId: <chosen expense category>, amountMinor: <fee>, ...)` — the existing money-out path used for every other expense (omit foreign-currency params).

This composes correctly for both real-world shapes of a transfer fee without any new logic:
- **Fee charged on top** (source loses transfer-amount + fee): enter the full source-leg transfer amount (and, if cross-currency known-rate, the full destination amount received), plus the fee as the separate expense — net effect on the source account is `-(sourceAmount + fee)`.
- **Fee deducted from what arrives** (common with cross-border wires): enter the source-leg amount that left and the destination amount that actually landed (cross-currency) / the landed amount as the sole transfer amount (same-currency), plus any explicit commission as the separate fee expense — do not try to invent a third “spread” posting; invisible FX cost is compared via the reference/implied rates only.

Both entries are ordinary two-posting entries, so `RegisterViewModel._recompute`, `_counterpartLabel`, balance aggregation, and reversal all work completely unchanged — reversing the transfer doesn't touch the fee and vice versa, which is correct (the fee was genuinely paid regardless of a later reversal of the transfer itself).

The fee is always denominated in the **source account's group currency** and always posts as a same-currency money-out on that source (never as a foreign-currency / provisional expense). A fee amount without an active expense category, or a non-positive fee amount, is rejected at the ViewModel (and would also fail `recordTransaction` validation) and must not leave a posted transfer paired with a silently skipped fee — see submit ordering in Decision 2a.

This works for same-currency transfers, known-rate cross-currency transfers, and unknown-rate provisional transfers alike: the fee is independent of whether the transfer leg is complete or pending. For cross-currency, the destination-amount field (when supplied) remains "what actually arrives"; the fee field is an additional explicit cost taken from the source, not a substitute for bank FX spread.

**Alternative considered:** a single three-posting entry (source / destination / fee category). Rejected, though not for the reason it might first appear: `_buildHomeOverview`'s balance aggregation and `reverseEntry` both already iterate generically over however many postings an entry has, so a 3-leg entry would aggregate and reverse correctly with zero changes there. The real blocker is narrower: `RegisterViewModel._recompute` picks the "other" (counterpart) posting via `postings.firstWhere((p) => p.accountId != accountId)`, which assumes exactly one non-self posting - with three legs, whichever of {destination, fee category} isn't first would be silently dropped from that account's register row label. Fixing just that one lookup is a smaller change than originally scoped here, but it's still an unforced change to a well-exercised, load-bearing display path for a purely cosmetic "one entry instead of two" win. Two entries is also how many bank statements actually itemize a wire fee, so it's not even a UX regression - this alternative is rejected on reuse/simplicity grounds, not because three systems need surgery.

**Alternative considered:** extend `settlePendingTransfer`'s existing `feeCategoryId` mechanism to cover this case too. Rejected — that mechanism is specifically about the shortfall on an already-pending cross-currency settlement (amount unknown until later); an upfront, known fee on any transfer (same-currency or cross-currency, provisional or complete) is a different moment and shouldn't overload that narrower concept.

### 2a. Submit ordering and partial failure

On submit when a fee amount is present (user opted in): validate fee amount (> 0) and fee category (active expense) **before** calling `recordTransfer`. Empty/absent fee amount means no fee path (unchanged single `recordTransfer`). Then `recordTransfer` first, then `recordTransaction` for the fee with the same `transactionDate`. If the transfer succeeds and the fee call fails, surface an explicit "transfer saved, fee failed" error (transfer must not look like it failed; do not attempt automatic reversal of the signed transfer). Orchestration lives in `TransferViewModel`, not a new repository API — `LedgerRepository` stays unchanged.

### 3. No database-level link between the fee entry and the transfer entry

The two entries are linked only by user experience (the Transfer screen posts both in one submit action, in immediate succession) and, optionally, a conventional description on the fee entry (e.g. "Fee for transfer to {destination}"). No new nullable FK column on `journal_entries` is introduced.

**Why not add a link column?** It would raise real questions with no clean answer: does reversing the transfer auto-reverse the fee? (No — the fee was actually paid.) Does reversing the fee invalidate the transfer? (No.) A soft link that doesn't drive any behavior isn't worth a schema change; a human reading the register already sees both rows next to each other by date.

### 4. Reference exchange rate: best-effort, offline-safe, display-only

Only shown when `TransferViewModel.isCrossCurrency` is true **and** the user has enabled the rate lookup in Settings (Decision 5) — the enabled check happens before anything else, so a disabled feature makes zero network attempts, not just a hidden UI row. A new small service (exact name/shape decided at apply time, e.g. `ExchangeRateService.fetchRate(from, to)`) calls the HTTP endpoint for whichever provider the user selected in Settings (see Decision 5 for the predefined set) with a short timeout, returns `null` on any failure (timeout, offline, unsupported pair, non-200), and the UI simply omits the reference-rate row when it's `null`. The fetch is triggered lazily (only when both accounts of a cross-currency pair are selected, and only when enabled), not on every keystroke, and never retried automatically. When the currency pair changes, cancel or ignore any in-flight response for the previous pair so a stale rate cannot display against the wrong accounts.

**Quote direction:** `fetchRate(from, to)` returns how many units of **destination** currency equal one unit of **source** currency (i.e. multiply source major units by the rate to estimate destination major units). The implied rate shown beside it MUST use the same convention (`destinationAmountMinor / sourceAmountMinor` after converting both to major units the same way `formatAmountMinor` does — divide by 100 for two-decimal currencies; do not divide raw minor units of mismatched exponents if a zero-decimal currency appears). UI labels should make the pair direction obvious (e.g. `1 USD ≈ 0.92 EUR`). Whatever the HTTP provider's raw JSON shape (base-EUR matrix, `from`/`to` query, etc.), the service normalizes to this dest-per-source number before returning — provider quirks stay inside `ExchangeRateService`.

**Privacy:** the HTTP request SHALL send only the two currency codes (and whatever minimal query the provider requires). It MUST NOT upload amounts, account names, descriptions, or any other ledger data.

`ExchangeRateService` is an optional constructor parameter on `TransferViewModel` (defaulting to a real instance), mirroring `LedgerRepository`'s existing `SigningKeyService? signingKeyService` optional-injection precedent — needed so tests can substitute a fake service instead of making real network calls.

When both a source amount and a destination amount are present, the UI MAY also show the **implied rate** (same dest-per-source convention, using major units). The implied rate is computed locally and MAY appear even when the Settings toggle is off or the fetch failed; when a reference rate is also available, show them together for comparison. Still display-only, never written into fields, never posted. This is the "cost tracking" signal for invisible FX spread; the optional fee field covers the stated commission. Computing a monetary "spread cost" in source currency is a non-goal for v1 (would invite false precision across free API mid-market rates).

**Alternative considered:** require the rate lookup for cross-currency transfers. Rejected — breaks the local-first/offline guarantee that holds for every other feature in this app today.

**Alternative considered:** auto-fill the destination amount from the fetched rate. Rejected — the user's actual received amount (which may differ from any reference rate due to the bank's own spread/fee) must remain the source of truth for what gets posted; the reference rate is a comparison, not an input.

### 5. Settings: enable/disable the rate lookup, and a predefined provider picker

This is the app's first user-facing settings surface — there is no existing Settings screen or non-secret preferences store today. This change adds the minimum needed: a new `/settings` route (a top-level route, mirroring how `/transfer` and `/record-transaction` are pushed outside the `StatefulShellRoute` branches) containing exactly two controls. Reachability: add a gear icon to `HomeView`'s app bar (it currently has no `actions`) via an `onOpenSettings` callback owned by `app_router.dart` (do not give `HomeView` a `GoRouter` dependency).

`HomeView`'s two existing callbacks differ in this exact respect: `onAccountTap` is `required`, `onSettlePendingTransfer` is optional (`ValueChanged<String>?`, no `required`) - specifically so call sites that don't care about that feature (three existing widget tests construct `HomeView` with only `viewModel` and `onAccountTap`) don't have to pass it. `onOpenSettings` SHALL follow the `onSettlePendingTransfer` precedent: optional (`VoidCallback?`), not `required`, so it doesn't force every existing `HomeView(...)` construction site to be updated. The gear icon itself can simply always render (Settings is always reachable in the real app, where `app_router.dart` always supplies the callback) - "optional on the widget" is about not breaking test call sites, not about the icon being conditionally shown.

1. **Enable/disable toggle** ("Fetch reference exchange rates"), **defaulting to off**. This app has never made a network call before this change; defaulting the one new network-touching feature to off keeps that opt-in rather than opt-out, consistent with the local-first stance in the Context section. When off, `TransferViewModel` SHALL NOT call `ExchangeRateService.fetchRate` at all — the check happens before the call, not after (no "fetch then discard the result" — that would still leak the currency pair over the network even with the row hidden).
2. **Provider dropdown**, populated from a fixed, code-defined list (e.g. an `ExchangeRateProvider` enum: `frankfurter` mapping to `api.frankfurter.app`, and `openErApi` mapping to `open.er-api.com` — the same two candidates from Decision 4, now both shipped and user-selectable rather than one being picked at apply time). Defaults to the first entry. The dropdown offers only these predefined options — there is no free-text URL field, no API-key field, and no "custom provider" entry. Supporting a new provider means adding a new enum case and its request/response mapping in `ExchangeRateService` (a code change, reviewed and shipped like any other feature), not something a user can configure themselves.

**Persistence:** both settings are plain, non-secret preferences (a bool and an enum tag), which is a different concern from the recovery-phrase/signing-key material `flutter_secure_storage` exists for. Add `shared_preferences` (a new, second new dependency alongside `http`) for these two values specifically, rather than overloading secure storage with non-secrets or inventing a bespoke file format. `flutter_secure_storage` remains reserved for actual secrets. The provider is stored by name (a plain string); if a future release ever renames or removes a case a user had selected, reading back an unrecognized name SHALL fall back to the default provider rather than throwing - this is the same forward-compatibility discipline as any persisted enum tag, just worth stating since it's easy to omit.

**Alternative considered:** store these in `flutter_secure_storage` since it's already a dependency. Rejected — secure storage is for secrets (private keys, recovery material); a rate-lookup toggle and a provider tag aren't secrets, and reusing it would blur that boundary for no real benefit (no new keychain/keystore risk surface is avoided by doing so, since these values aren't sensitive either way).

**Alternative considered:** let the user type any provider URL. Rejected per the explicit product decision behind this change: new providers are a product/code feature, not a user option — an arbitrary-URL field would also reopen the privacy guarantee in Decision 4 (no way to audit what a user-supplied endpoint does with the request).

## Risks / Trade-offs

- [First-ever network dependency in a local-first app] → Mitigation: strictly additive, optional, silently degrades to "no reference rate shown"; no feature's success path depends on network access.
- [Free rate API coverage gaps or future deprecation] → Mitigation: two predefined providers ship at once so a user whose pair one provider lacks can switch to the other from Settings; provider dispatch is isolated behind one small service interface, so adding a third later touches one file, not the transfer flow.
- [User confusion about two rows for one transfer] → Mitigation: fee field is optional and clearly labeled as a separate cost at entry time; register rows land adjacent by date/time.
- [Users expecting the fetched rate to auto-fill the amount] → Mitigation: UI copy makes clear it's a reference only ("market rate, for comparison"), next to the existing "destination amount" field which stays manually entered.
- [Double-counting fees on provisional cross-currency transfers] → Mitigation: transfer-time fee (this change) and `settlePendingTransfer`'s shortfall fee are different moments; UI copy on settle should continue to describe shortfall as "amount not returned," not a bank commission. Document in transfer fee helper text that settlement shortfall is recorded later only if applicable — do not auto-create both for the same economic cost.
- [Partial failure after transfer posts] → Mitigation: validate fee fields before `recordTransfer`; on fee-post failure show "transfer saved, fee failed" and leave the transfer on the chain (signed entries are immutable; user can post the fee manually).
- [Overlap with archived-account-restrictions closeout] → Mitigation: register Transfer action only for active accounts; never use this ordinary transfer entry point for archived closeout.
- [Duplicate/conflicting `isSelectedAccountArchived` getter if both changes are applied without checking each other] → Mitigation: whichever of this change and `archived-account-restrictions` applies first adds the getter to `RegisterViewModel`; the second reuses it (see Decision 1's cross-change note).
- [Stale HTTP response after dispose / pair change] → Mitigation: ignore or cancel in-flight `fetchRate` when the pair changes or `TransferViewModel.dispose` runs; never call `notifyListeners` after dispose.
- [A disabled feature still leaking the currency pair over the network] → Mitigation: the enabled check gates the call itself, not just the displayed row - "fetch then hide" is explicitly wrong and must not happen.
- [Two new dependencies (`http`, `shared_preferences`) in a change that started as UI-only] → Mitigation: both are small, extremely common, well-maintained packages; `shared_preferences` is used only for these two non-secret values, not as a growing general store.

## Migration Plan

1. Add the Register-scoped Transfer entry point and `fromAccountId` query param (no schema/repository change; ships independently of the fee/rate work).
2. Add the optional fee fields to the Transfer screen, posting via the existing `recordTransaction` call after `recordTransfer` succeeds.
3. Add the Settings screen with the disabled-by-default toggle and the predefined provider dropdown (persisted via `shared_preferences`).
4. Add the reference-rate service (supporting both predefined providers) and its optional UI row, gated on the Settings toggle from step 3.
5. Each step is independently shippable and revertable; no data migration involved since no schema changes.

## Open Questions

- Whether the fee category picker should default to a specific seeded "Bank Fees" expense category or just reuse the general expense-category picker — default to the general picker for v1 (no new seeded category), revisit if users want one preselected.
- Whether a third predefined provider is worth adding at launch (beyond Frankfurter and open.er-api.com) — default to just these two for v1; the enum is designed to grow without redesign.
