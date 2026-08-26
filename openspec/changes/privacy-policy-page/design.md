## Context

Found during App Store/Play Store distribution planning (2026-08-27). Neither store lets an app go live without a privacy-policy URL, and this project has never needed one before (it's never been distributed through either store). The app's actual data-handling story is genuinely simple compared to most finance apps — no server, no account, no third-party analytics or ad SDKs — so this is a documentation task, not a design-decisions-about-data-handling task; the policy describes existing behavior, it doesn't change any.

## Goals / Non-Goals

**Goals:**
- One accurate, plain-language policy page, in the same voice as the rest of the website and `docs/user-guide.md` (household vocabulary, no unexplained jargon).
- Reachable both from the public website (for store-listing links) and from in-app Settings (so a user doesn't have to leave the app to find it before they've even installed anything from a store).
- Stays consistent with `ios-privacy-compliance`'s declarations — same facts, described for two different audiences (a legal/App-Review audience there, an end-user audience here).

**Non-Goals:**
- A cookie-consent banner or similar web-tracking disclosure — the website itself sets no cookies and runs no analytics (confirm this stays true; don't add any as part of this change).
- Region-specific legal text (GDPR/CCPA-specific clauses) — the app's actual behavior (nothing collected, nothing shared, no account) already satisfies the *substance* most such regimes ask for; add jurisdiction-specific boilerplate only if a future distribution target genuinely requires it, not preemptively.
- Localizing the policy page itself into the app's 40+ in-app languages — the website is currently English-only (see `pages/`); scope stays consistent with that.

## Decisions

### 1. One page under the existing Smara Account project section, not a site-wide policy

`pages/open-source/smara-account/privacy-policy.md`, alongside `architecture.md`, `how-it-was-built.md`, `whats-built.md` — the policy is specific to the app's data handling, not the personal site's (which has no app to have a data-handling story about beyond the site itself serving static pages).

### 2. In-app link uses the same testable `launchUrlFn`-injection pattern already used for the investment-research external link

`HoldingsViewModel` already wraps `url_launcher`'s `launchUrl` behind an injectable `Future<bool> Function(Uri url) launchUrlFn` constructor parameter (defaulting to the real `launchUrl` call), specifically so tests can substitute a fake instead of actually opening a browser. `SettingsViewModel` gains the same shape for opening the privacy-policy URL, rather than a new one-off pattern.

### 3. Placed under Settings' existing "About" section

`settings_view.dart` already has an About section (`l10n.settingsAbout`) with "Why we don't edit" explanatory copy. The Privacy Policy link belongs there — a place a user already goes to understand what the app does and doesn't do — rather than a new top-level section.

## Risks / Trade-offs

- **[Risk]** The policy describes a data flow that later drifts out of sync with actual behavior (e.g. a future change adds a new network call and nobody updates this page) → **Mitigation:** cross-reference explicitly from `ios-privacy-compliance`'s manifest audit, and treat "does this still match the privacy policy" as a standing question for any future change that adds network access or third-party data sharing — worth a line in a relevant convention doc if this recurs.
- **[Trade-off]** None significant — this is additive documentation.

## Migration Plan

1. Write `pages/open-source/smara-account/privacy-policy.md`.
2. Link it from `pages/open-source/smara-account/index.md` and `whats-built.md`.
3. Add a `launchUrlFn`-style injectable opener to `SettingsViewModel`; add the Settings row under the About section; add the new l10n string(s) (source `.arb` plus regenerate — do not hand-edit generated locale files).
4. Rollback = revert; no data migration.

## Open Questions

- Whether the privacy-policy URL used in-app should be the GitHub Pages URL directly or a stable custom-domain path (`pages/CNAME` already configures a custom domain) — default to the custom domain, matching how the rest of the site is already configured.
