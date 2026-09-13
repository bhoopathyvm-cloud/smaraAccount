# Store listing draft — description, keywords, category, support URL

Covers tasks 1.1-1.5. Adapted from `pages/open-source/smara-account/`
(mainly `index.md`'s "what it is / the problem / the solution" framing and
`whats-built.md`'s feature list) rather than written independently, per
design.md Decision 1 — this stays the app's one consistent public
description, not a store-specific rewrite.

App name used throughout: **Smara Accounting** (matches
`CFBundleDisplayName` on iOS/macOS and `android:label`, not the repo's
internal `smara_accounting` package name).

## Short description (Google Play — 80 char limit)

> Local-first, tamper-evident accounting. No cloud, no subscription, no ads.

74 characters.

## Promotional text (App Store Connect — 170 char limit, editable without a new review)

> A local-first, tamper-evident ledger for your books. No cloud, no subscription, no ads.

87 characters.

## Full description (App Store Connect & Google Play — both 4000 char limit)

Same text for both stores.

> Smara Accounting is a local-first, tamper-evident double-entry ledger
> for your personal or small-business books, with no server, no cloud
> account, and no subscription.
>
> **WHY SMARA ACCOUNTING**
>
> Most accounting apps ask you to trust two things at once: a cloud
> provider with your financial history, and a system where "immutable"
> transaction history usually just means nobody built the edit button
> yet. Even apps that stay local rarely make it hard to quietly rewrite a
> past entry, since a database row is a database row, and anyone who can
> open the file can change it.
>
> Smara Accounting keeps everything on your own device. Every entry is
> cryptographically signed and chained to the one before it, so altering
> a past entry breaks the chain, and the app detects that the next time
> it opens. Corrections are always new entries recorded next to the
> original, never edits in place, so your history stays genuinely
> append-only.
>
> **WHAT YOU CAN DO**
>
> - Record income, expenses, and transfers, including split-category and
>   recurring entries
> - Track multiple accounts and account groups across different
>   currencies, with no forced conversion
> - Capture credit-card spending with dedicated shortcuts
> - Hold investment accounts with buy/sell/dividend tracking and one-tap
>   research prompts
> - Import bank statements from OFX and CSV files with saved category
>   rules
> - Search and filter a running register, with a guided flow for
>   correcting mistakes
> - Back up and restore an encrypted, passphrase-protected copy of your
>   full ledger
> - Export account history to CSV, with each row showing its
>   verification status
> - Lock the app with a PIN or Face ID / Touch ID
> - Use the app in dozens of languages, with money always formatted by
>   its own currency's convention
>
> **WHAT IT DOESN'T DO**
>
> Smara Accounting cannot stop you from entering a mistaken or false
> transaction while legitimately using the app, and it does not replace
> backups or device security. What it does is detect hidden changes to
> recorded history after the fact, a property of the system rather than
> a marketing claim.
>
> **PRIVACY**
>
> No account, no ads, no analytics or crash-reporting SDK, and no
> selling of data. Two lookups are available and off by default: a
> reference exchange rate for cross-currency transfers, and investment
> market quotes, both sending only the minimum needed (a currency pair
> or a ticker), never your balances. Full privacy policy:
> smara-ai.ch/open-source/smara-account/privacy-policy
>
> **OPEN SOURCE**
>
> Smara Accounting is open source. Read the code, file an issue, or
> contribute at github.com/bhoopathyvm-cloud/smaraAccount

2,573 characters — well under the 4000 limit on both stores.

## Keywords (App Store Connect — 100 char limit, comma-separated)

> accounting,ledger,budget,expense tracker,multi-currency,investments,offline,privacy,secure

90 characters. Google Play doesn't have an equivalent dedicated keyword
field — its search indexing draws from the title/description instead.

## Category

- **App Store Connect:** Finance (matches `LSApplicationCategoryType =
  public.app-category.finance` already set in `macos/Runner/Info.plist`)
- **Google Play Console:** Finance

## Support URL

`https://smara-ai.ch/open-source/smara-account/` — verified reachable
(`curl` returns HTTP 200). This is the project's own page rather than
linking straight to GitHub issues, since it's a proper support page that
itself links to the repository and issue tracker; both stores accept it
as a support URL.

## Open items before this is submission-ready

- [x] Confirm the app name "Smara Accounting" is what should actually
  appear in the store listings — confirmed. Considered "Smara Ledger"
  (thematically neat — "Smara" means remembrance, a ledger's job is
  remembering accurately — but collides with the Ledger crypto hardware
  wallet brand for a general audience) and "Smara Finance Book Keeping"
  (too long, truncates on home screens, redundant wording). "Accounting"
  needs no specialized knowledge and matches what people actually search
  for. See design.md Decision 4.
- [ ] Native speaker / second-pass proofread of the full description
- [ ] Decide whether Google Play's separate "Short description" and
  "Full description" should actually differ in tone, or reuse the same
  text as drafted here
