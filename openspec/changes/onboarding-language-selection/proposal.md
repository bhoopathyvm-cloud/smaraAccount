## Why

On first launch the app goes straight to the currency-selection screen in
whatever locale the device resolves to — English for anyone whose device
locale is not one of the 43 supported packs, and English for anyone whose
device language differs from the language they actually read. A non-English
speaker then has to complete the entire onboarding flow (currency, first
account, first entry, recovery-phrase acknowledgment) in a language they may
not follow, and the language picker only becomes reachable afterwards, buried
in Settings. Language is the one choice that makes every later step legible, so
it should come first.

## What Changes

- Add a **language-selection screen as the first onboarding step**, shown once
  on first launch before the currency screen. It lists every supported locale
  by its own native name (endonym), pre-selecting the device-resolved locale,
  and applies the choice immediately so the rest of onboarding is in that
  language.
- The screen writes through the existing `LocaleController` /
  `preferredLocaleTag` preference — the same one Settings uses — so the choice
  persists and Settings shows it already set.
- Choosing nothing and continuing keeps the current (device-resolved) locale;
  there is no forced decision.
- The startup redirect policy routes a brand-new user (no signing identity
  yet) to the language screen first, then to currency; both are allowed
  pre-identity.
- No new persisted preference key, no change to how or when the signing
  identity is generated, and no change to Settings' existing language picker.

## Capabilities

### New Capabilities

- `onboarding-language-selection`: a first-launch screen, ahead of currency
  selection, that lets the user pick the app language by its native name and
  applies it to the rest of onboarding, reusing the persisted language
  preference rather than introducing a new one.

### Modified Capabilities

- `app-navigation-policy`: the startup gate sequence gains a language step. A
  first-time user with no signing identity is routed to the language screen
  first, then to currency; both are valid pre-identity locations. The existing
  gate order after identity (acknowledgment, key match, chain verify, currency
  backfill, first-week setup, lock) is unchanged.

## Impact

- `lib/domain/navigation/app_navigation_policy.dart` — new `language` path in
  `AppNavPaths`, added to the `onboarding` set, and made the pre-identity entry
  point alongside `currency`.
- `lib/ui/app_router.dart` — new `GoRoute` for the language screen.
- `lib/ui/features/onboarding/` — new `LanguageSelectionView` (+ small view
  model if needed) reusing `LocaleController`, `supported_locales.dart`, and
  `locale_endonyms.dart`.
- Reuses `app-localization`'s existing "Language Preference" mechanism
  (persistence, endonym labels, immediate apply) — no change to that spec's
  requirements.
- `integration_test/acceptance/onboarding_test.dart` and onboarding
  widget/unit tests — updated for the new first screen.
- `AppNavigationPolicy` unit tests — new pre-identity routing case.
