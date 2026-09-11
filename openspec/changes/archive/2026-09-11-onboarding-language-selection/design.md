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
  language once chosen, that requires an explicit choice.
- A currency default on the very next screen that's a sensible starting
  point for the chosen language, never a restriction.
- A recovery phrase in the chosen language wherever a real BIP39 standard
  wordlist exists for it, with an honest, disclosed English fallback where
  none exists — never a silent gap.
- Zero new persistence beyond a static currency-default lookup table: reuse
  `preferredLocaleTag` / `LocaleController` for the language itself.
- No change to when or how the signing identity is generated.
- The policy stays unit-testable without the router.

**Non-Goals:**

- Changing the Settings language picker.
- A new "onboarding progress" persistence model or an "onboarding seen" flag.
- Translating user-entered text or currency formatting (still governed by
  `app-localization`'s existing, unchanged "Ledger Amounts Follow Currency"
  requirement).
- Inventing non-standard BIP39 wordlists for locales without an official
  one (see Decision 8) — the English fallback plus disclosure is the
  deliberate choice, not a gap to close later in this change.
- Detecting the user's language automatically beyond what
  `resolveSupportedLocale` already does from the device locale.
- A general "currency default follows current language" rule usable outside
  this first-launch screen (e.g. re-applying when Settings' language
  changes later, or when creating a second account group) — scoped to this
  screen only.

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

### 6. Selection is mandatory: Continue is disabled until a row is tapped

The original design let the user continue without interacting with the
screen at all, keeping whatever locale had already resolved. Revisited:
a first-time user should not be able to pass through the one screen that
makes everything else legible without ever confirming it. `Continue` is
disabled until `LocaleController.setPreference` has actually been called at
least once during this screen's lifetime — tapping the pre-highlighted row
counts, so a user whose device locale is already correct only needs one
tap, not a forced re-selection of something already right.

**Alternatives considered:** requiring a *different* selection than the
pre-highlighted one. Rejected — that would punish the common case (device
locale already correct) by forcing a pointless change-and-change-back.

### 7. Currency default follows the chosen language, via a small static lookup

`CurrencySelectionView` currently pre-fills `_controller.text` with
`_commonCurrencies.first` (`'USD'`), unconditionally. A new
`defaultCurrencyForLocale(String languageCode)` function (co-located with
the currency screen or under `lib/l10n/`) maps each of the 44 supported
language codes to one ISO 4217 currency, used only to seed that initial
text — every other behavior of the screen (the quick-pick chips, free-text
entry, validation) is unchanged, and the group-currency model
(`account-currency`) is untouched: this only changes what shows up
pre-filled before the user's first edit.

The mapping is intentionally coarse and disclosed as such — language is a
weak signal for currency, so this is a starting point, not a claim of
correctness:

| Language(s) | Currency | Note |
|---|---|---|
| `en` | USD | |
| `ta`, `te`, `ml`, `kn`, `hi`, `ur`, `pa`, `ne`, `sa`, `doi`, `ks`, `mai`, `mr`, `gu`, `kok`, `sd`, `bn`, `as`, `or`, `mni`, `brx`, `sat` | INR | All 22 of India's scheduled languages per this app's own Indian locale packs (`locales-indian-*`) default to India's currency, even where the language is also spoken elsewhere (e.g. Urdu, Sindhi, Nepali) — consistent with why this app added them together. |
| `de`, `fr`, `es`, `it`, `pt`, `hu`, `ro`, `nl` | EUR | Approximation for Hungary (HUF) and Romania (RON); accepted for simplicity, not exactness — both are edit-away chip taps. |
| `ja` | JPY | |
| `zh` | CNY | |
| `ko` | KRW | |
| `ar` | SAR | One representative Arabic-speaking economy; Arabic spans many currencies and this cannot be exact. |
| `ru` | RUB | |
| `id` | IDR | |
| `tr` | TRY | |
| `vi` | VND | |
| `th` | THB | |
| `ms` | MYR | |
| `uk` | UAH | |
| `pl` | PLN | |

**Alternatives considered:** a language→*country*→currency table keyed by
device region instead of language. Rejected for v1 — meaningfully more
data to maintain for a value that's one tap to change anyway; revisit if
user feedback says the coarse table is actively wrong often enough to
matter.

### 8. Recovery phrase follows language only where BIP39 has a real wordlist, with a disclosed exception everywhere else

`bip39_mnemonic` (already a dependency) bundles official wordlists for 10
languages: English plus French, Italian, Spanish, Portuguese, Czech,
Japanese, Korean, Chinese Simplified, Chinese Traditional. Of those, only
**7 are also supported UI locales in this app**: French, Italian, Spanish,
Portuguese, Japanese, Korean, and Chinese Simplified (Czech and Traditional
Chinese aren't supported UI locales here). For those 7, `recovery_phrase.dart`
selects `Language.<x>` instead of the hardcoded `Language.english`.

For the other 36 non-English supported locales — including, notably, all
22 of India's scheduled languages this app supports — no official BIP39
wordlist exists. The recovery phrase for those locales stays English, and
the user sees an explicit, plain-language notice **before** the phrase is
first generated (during the pre-identity flow, after language selection),
stating that their recovery phrase will be in English because the security
standard behind it doesn't yet have a wordlist for their language. This is
disclosure, not a silent gap.

**Why not build custom, non-standard wordlists for the other 36
languages?** BIP39 wordlists are a fixed, versioned standard specifically
so a recovery phrase from any BIP39-compliant generation can be verified
against any other. A wordlist we invented ourselves would not be a "BIP39
phrase" in any meaningful interoperable sense, would need the exact same
cryptographic scrutiny as the official ones (word-boundary/checksum
properties are non-trivial to get right), and would only serve this app's
own recovery flow — for a feature whose entire job is protecting a user's
only way to recover their money if the device is lost. That risk isn't
justified by this change.

**Alternatives considered:**
- *Full custom wordlists for all 44 locales.* Rejected per above — the
  security risk of inventing and validating 36 new wordlists ourselves
  outweighs the benefit for a feature the recovery phrase's own English
  fallback already covers safely.
- *No disclosure, just silently fall back to English.* Rejected — a user
  who chose, say, Tamil for the whole app and then hits an unexplained
  English recovery-phrase screen would reasonably read that as a bug, not
  a deliberate, documented limitation.

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
- **[Risk]** The coarse language→currency table (Decision 7) is wrong for a
  meaningful share of users of pan-regional languages (Arabic, Spanish,
  Portuguese). → **Mitigation:** disclosed as approximate in the design
  itself; it is a pre-filled default on an already-editable field, one chip
  tap or a few keystrokes away from correct — never a restriction.
- **[Risk]** Recovery-phrase wordlist selection touches
  `lib/domain/crypto/recovery_phrase.dart`, the app's most security-critical
  file. → **Mitigation:** the change is additive and narrow — a lookup from
  locale to an already-bundled, already-tested `Language` enum value, with
  English as the untouched default for every locale not in the 7-language
  table. No change to key derivation, checksum logic, or the English path
  itself. Existing recovery-phrase tests for the English path continue to
  cover it unchanged; new tests cover only the lookup and the 7 additional
  languages.
- **[Trade-off]** 36 of the 44 supported locales (including all 22 Indian
  scheduled languages this app supports) still get an English recovery
  phrase. Accepted per Decision 8 — full custom wordlists were rejected as a
  disproportionate security risk, and a disclosed, honest limitation is
  preferable to either silently shipping English or inventing non-standard
  wordlists.

## Migration Plan

1. Add `AppNavPaths.language` and the pre-identity branch to
   `AppNavigationPolicy`; add its unit test.
2. Add `LanguageSelectionView` under `lib/ui/features/onboarding/`, its
   GoRoute in `app_router.dart`, and the mandatory-selection (Continue
   disabled until a row is tapped) behavior from Decision 6.
3. Add `defaultCurrencyForLocale` and wire it into
   `CurrencySelectionView`'s initial `_controller.text` (Decision 7).
4. Add the locale→BIP39-`Language` lookup and wire it into
   `recovery_phrase.dart`; add the pre-generation English-disclosure
   notice for locales without an official wordlist (Decision 8).
5. Update onboarding widget/acceptance tests to step through the new screen,
   assert the language-aware currency default, and cover both the
   BIP39-supported and English-fallback-with-notice paths.
6. Add the screen (and the BIP39 notice, where shown) to `docs/user-guide.md`
   (the `user-guide` spec requires the guide to cover every reachable
   screen).
7. Rollback = remove the route, the view, the policy branch, the currency
   lookup (revert `CurrencySelectionView` to the `USD` default), and the
   recovery-phrase language lookup (revert to hardcoded
   `Language.english`); no data migration (no new persisted key).

## Open Questions

- Do we include an explicit **"Same as device"** row (writing
  `kSystemLocalePreference`), or only the 44 concrete languages? Resolved:
  **yes, include it, listed first** — under the now-mandatory-selection
  design (Decision 6), tapping "Same as device" is itself the required
  explicit choice, so it costs nothing and keeps the follow-the-device
  behaviour discoverable.
- Copy for the screen title/subtitle, the Continue button, and the
  BIP39 English-disclosure notice — needs an English ARB key set, then
  AI-drafted packs like any other locale addition.
- Exact wording and placement of the BIP39 disclosure notice (a dedicated
  screen between language selection and currency, vs. inline text on the
  eventual recovery-phrase screen itself) is left to implementation; either
  satisfies the spec's requirement that it appear before the phrase is
  generated.
