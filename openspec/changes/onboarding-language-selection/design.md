## Context

Today the first screen a new user sees is `CurrencySelectionView`
(`/onboarding/currency`), reached because `AppNavigationPolicy.resolve`
returns `AppNavPaths.currency` whenever `currentIdentity()` is null. The app's
locale at that point is `LocaleController.resolve(deviceLocale)` — the device
locale if it is one of the 43 supported packs, otherwise English. There is no
persisted override yet, and the only way to set one is the Settings language
picker, which a first-time user reaches only after finishing onboarding.

The pieces needed for an onboarding picker already exist:

- `LocaleController` (`lib/l10n/locale_controller.dart`) — `setPreference(tag)`
  calls `notifyListeners()` (so `MaterialApp.router`, which `context.watch`es
  it, rebuilds and re-localizes immediately) then persists
  `preferredLocaleTag`.
- `kSupportedLocaleTags` (`lib/l10n/supported_locales.dart`) and the endonym
  map (`lib/l10n/locale_endonyms.dart`) — the same data the Settings picker
  uses.
- `AppNavigationPolicy` — a pure module with a single pre-identity branch to
  extend.

## Goals / Non-Goals

**Goals:**

- A first-launch language screen ahead of currency, in the user's own
  language once chosen.
- Zero new persistence: reuse `preferredLocaleTag` / `LocaleController`.
- No change to when or how the signing identity is generated.
- The policy stays unit-testable without the router.

**Non-Goals:**

- Changing the Settings language picker.
- A new "onboarding progress" persistence model or an "onboarding seen" flag.
- Translating user-entered text, currency formatting, or the BIP39 wordlist
  (already covered and explicitly excluded by `app-localization`).
- Detecting the user's language automatically beyond what
  `resolveSupportedLocale` already does from the device locale.

## Decisions

### 1. A dedicated route `/onboarding/language`, ahead of `/onboarding/currency`

**Alternatives considered:**

- *A locale strip on the currency screen.* Rejected: it buries the choice
  under a currency decision the user can't yet read, and the currency screen
  already commits the signing identity — mixing a reversible UI preference
  with an irreversible commit is confusing.
- *A system dialog before the router mounts.* Rejected: it would live outside
  `MaterialApp`, can't use `AppLocalizations`, and duplicates the picker UI.

**Decision:** a normal GoRoute inside `MaterialApp.router`, styled like the
other onboarding screens, with a scrollable endonym list and a single
**Continue** action.

### 2. Gate it in `AppNavigationPolicy`, not with an ad-hoc `initialLocation`

`AppNavigationPolicy.resolve` gains: when `identity == null`, return
`AppNavPaths.language` unless `matchedLocation` is already `language` or
`currency`. `currency` stays allowed pre-identity so the user can move
language → currency; the currency screen's own `commitIdentity` remains the
thing that ends the pre-identity phase. `AppNavPaths.language` is added to the
`onboarding` set so the "still on an onboarding route after everything is
done → go home" cleanup keeps working.

**Alternatives considered:** special-casing `initialLocation` in the router.
Rejected — it splits the gate logic the `app-navigation-policy` capability
exists to keep in one place, and isn't unit-testable without `WidgetTester`.

### 3. No "language step completed" flag; re-entry is acceptable

Because nothing persists "the user saw the language screen", a pre-identity
relaunch routes back to `/onboarding/language`. That is fine: it is the very
first screen, one tap to move on, and the previously chosen language is
already applied and pre-selected. Adding a flag would be the only new
persistence in the change and buys almost nothing.

### 4. Reuse `LocaleController.setPreference` verbatim

Selecting a row calls `localeController.setPreference(tag)` (or
`kSystemLocalePreference` if we offer a "same as device" row — see Open
Questions). The immediate rebuild is already wired through
`context.watch<LocaleController>()` in `main.dart`. **Continue** just
`context.go(AppNavPaths.currency)`. No view model is required; a thin
`StatelessWidget`/`StatefulWidget` that reads the controller is enough, matching
how `SettingsView` does it.

### 5. Pre-selection mirrors the effective locale

The list highlights `localeController.overrideLocale ?? resolveSupportedLocale(
deviceLocale)`. If we include a "same as device" row, that row is highlighted
when `overrideLocale` is null.

## Risks / Trade-offs

- **[Risk]** RTL locales (Arabic, Urdu) flip layout direction mid-flow when
  chosen. → **Mitigation:** `MaterialApp` derives `Directionality` from the
  locale automatically; verify the onboarding screens (already localized) look
  right RTL as part of testing.
- **[Risk]** The long endonym list (43 entries) is slow or unscrollable on
  small screens. → **Mitigation:** a plain `ListView`; the Settings picker
  already renders the same set.
- **[Risk]** Acceptance/widget tests that assume the currency screen is first
  break. → **Mitigation:** update `onboarding_test.dart` and the onboarding
  widget tests to advance past the language screen; add a policy unit test for
  the new pre-identity branch. This is expected churn, not a regression.
- **[Trade-off]** Pre-identity relaunch re-shows the language screen. Accepted
  per Decision 3.

## Migration Plan

1. Add `AppNavPaths.language` and the pre-identity branch to
   `AppNavigationPolicy`; add its unit test.
2. Add `LanguageSelectionView` under `lib/ui/features/onboarding/` and its
   GoRoute in `app_router.dart`.
3. Update onboarding widget/acceptance tests to step through the new screen.
4. Add the screen to `docs/user-guide.md` (the `user-guide` spec requires the
   guide to cover every reachable screen).
5. Rollback = remove the route, the view, and the policy branch; no data
   migration (no new persisted key).

## Open Questions

- Do we include an explicit **"Same as device"** row (writing
  `kSystemLocalePreference`), or only the 43 concrete languages? "Same as
  device" matches Settings and keeps the follow-the-device behaviour
  discoverable, but on first launch the concrete language is usually what the
  user wants to confirm. Leaning toward including it, listed first.
- Copy for the screen title/subtitle and the Continue button — needs an
  English ARB key set, then AI-drafted packs like any other locale addition.
