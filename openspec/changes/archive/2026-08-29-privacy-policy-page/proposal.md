## Why

Both App Store Connect and Google Play Console require a live privacy-policy URL before an app can be submitted for review. Neither `pages/` (the project website) nor the app itself (Settings) has one today. SMARA Account's actual data story is unusually simple and favorable — no server, no account, everything stored on-device, and exactly two clearly-labeled *opt-in* network calls that each send the minimum possible data — so the policy should say exactly that in plain language, not reach for generic boilerplate that would misrepresent (by being vaguer than necessary about) what the app actually does.

## What Changes

- Add a new page, `pages/open-source/smara-account/privacy-policy.md`, covering: no server/no account/nothing leaves the device by default; what's stored locally and where (signing key in the platform Keychain/Keystore via `flutter_secure_storage`; ledger data in a local Drift/SQLite database); the two opt-in network calls and exactly what each sends (`reference-exchange-rate-lookup`: a currency pair, nothing else; investment quote fetch: a ticker or ISIN, never quantity or cost); how biometric unlock works (the app never receives or stores biometric data itself — `local_auth` returns only a pass/fail result from the OS's own biometric API); what a ledger backup file or CSV export contains (and does not contain — no signing-key material); and a contact point for privacy questions (GitHub issues, matching this project's existing contribution flow).
- Link the page from the app's Settings screen (a new "Privacy Policy" entry) so the in-app disclosure and the store-submission URL point at the same live page, not two documents that can drift apart.
- Link the page from the website's project index and `whats-built.md` for visibility outside the app itself.

## Capabilities

### New Capabilities
- `privacy-policy-page`: a single, accurate, plain-language privacy policy — published on the website and linked from in-app Settings — that App Store Connect and Google Play Console can both point at.

### Modified Capabilities
- (none — no data-handling behavior changes; this documents existing behavior)

## Impact

- New `pages/open-source/smara-account/privacy-policy.md`
- `pages/open-source/smara-account/index.md`, `pages/open-source/smara-account/whats-built.md` (add links)
- `lib/ui/features/settings/views/settings_view.dart`, `lib/ui/features/settings/view_models/settings_view_model.dart` (a new Settings entry linking out via `url_launcher`, following the existing "Favourite research tool" external-link pattern)
- New l10n string(s) for the Settings entry label, following this project's existing localization convention (every user-facing string goes through `AppLocalizations`, not a hard-coded literal)
- Depends on nothing else in this batch, but `ios-privacy-compliance` should stay consistent with whatever this page ends up saying — implement together or this one first
