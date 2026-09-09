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

- Add a **mandatory language-selection screen as the first onboarding step**,
  shown once on first launch before the currency screen. It lists every
  supported locale by its own native name (endonym), pre-selecting the
  device-resolved locale as a starting point, but requires the user to
  explicitly choose a row (confirming the pre-selection counts) before
  Continue is enabled — there is no silent pass-through.
- The screen writes through the existing `LocaleController` /
  `preferredLocaleTag` preference — the same one Settings uses — so the choice
  persists and Settings shows it already set.
- The startup redirect policy routes a brand-new user (no signing identity
  yet) to the language screen first, then to currency; both are allowed
  pre-identity.
- **The currency screen's pre-filled default now follows the chosen
  language** (via a language→currency lookup, editable like any other
  currency on that screen) instead of always defaulting to USD. This applies
  only at this first-launch screen; it is not a general rule that re-runs
  currency defaults elsewhere when the language is changed later in Settings.
- **Recovery-phrase generation partially follows the chosen language**: for
  the 7 supported UI locales that have an official BIP39 wordlist (French,
  Italian, Spanish, Portuguese, Japanese, Korean, Simplified Chinese), the
  recovery phrase is generated and confirmed in that language. For every
  other non-English locale, the recovery phrase remains English, and the
  user sees an explicit notice — before the phrase is generated — that it
  will be in English because no standard wordlist exists yet for their
  language. This modifies `app-localization`'s previously unconditional
  "Recovery Phrase Language Unchanged" requirement.
- No new persisted preference key beyond a small currency-default lookup
  table, no change to how or when the signing identity is generated, and no
  change to Settings' existing language picker.

## Capabilities

### New Capabilities

- `onboarding-language-selection`: a first-launch screen, ahead of currency
  selection, that requires the user to pick the app language by its native
  name, applies it immediately to the rest of onboarding (reusing the
  persisted language preference rather than introducing a new one), and
  feeds that choice into the currency screen's default and the recovery
  phrase's wordlist selection.

### Modified Capabilities

- `app-navigation-policy`: the startup gate sequence gains a language step. A
  first-time user with no signing identity is routed to the language screen
  first, then to currency; both are valid pre-identity locations. The existing
  gate order after identity (acknowledgment, key match, chain verify, currency
  backfill, first-week setup, lock) is unchanged.
- `app-localization`: "Recovery Phrase Language Unchanged" is narrowed from
  an unconditional English-only rule to a language-following rule for the 7
  locales with an official BIP39 wordlist, with a disclosed English fallback
  (and an explicit user-facing notice) for every other locale.

## Impact

- `lib/domain/navigation/app_navigation_policy.dart` — new `language` path in
  `AppNavPaths`, added to the `onboarding` set, and made the pre-identity entry
  point alongside `currency`.
- `lib/ui/app_router.dart` — new `GoRoute` for the language screen.
- `lib/ui/features/onboarding/` — new `LanguageSelectionView` (+ small view
  model if needed) reusing `LocaleController`, `supported_locales.dart`, and
  `locale_endonyms.dart`.
- `lib/ui/features/onboarding/views/currency_selection_view.dart` — pre-fill
  `_controller.text` from a new language→currency default lookup instead of
  the hardcoded `_commonCurrencies.first` (USD).
- `lib/domain/crypto/recovery_phrase.dart` — select `Language` from a new
  locale→BIP39-language lookup (falling back to `Language.english`) instead
  of the hardcoded `Language.english`.
- A new English-notice screen/dialog shown once, before recovery-phrase
  generation, for any chosen locale without an official BIP39 wordlist.
- Reuses `app-localization`'s existing "Language Preference" mechanism
  (persistence, endonym labels, immediate apply) for the language choice
  itself — only the recovery-phrase requirement's own text changes.
- `integration_test/acceptance/onboarding_test.dart` and onboarding
  widget/unit tests — updated for the new first screen, the language-aware
  currency default, and the BIP39-notice path.
- `AppNavigationPolicy` unit tests — new pre-identity routing case.
