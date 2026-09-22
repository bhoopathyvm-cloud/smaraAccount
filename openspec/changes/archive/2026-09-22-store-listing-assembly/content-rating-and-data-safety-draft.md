# Content rating and Data Safety draft (tasks 3.1–3.3)

Covers Google Play's content rating questionnaire and Data Safety form.
Every "not collected" line below is backed by something verifiable, not
assumed — either a specific line in
`pages/open-source/smara-account/privacy-policy.md`, or a direct check of
the app's actual dependencies/manifest, per design.md Decision 3 ("filled
in by direct line-by-line diff... not from memory").

Verified directly in the code before writing anything below:
`pubspec.yaml` has no analytics/crash/ads SDK (`firebase`, `crashlytics`,
`sentry`, `admob` etc. — none present), and `android/app/src/main/
AndroidManifest.xml` declares only `USE_BIOMETRIC` and (after
`android-release-internet-permission`) `INTERNET` — no location,
contacts, storage, or ID-related permissions.

## 1. Content rating questionnaire (IARC)

Google Play's questionnaire is answered per-category. This app is a
personal/small-business accounting ledger with no social, real-money, or
mature content, so every category is a clean "no":

| Category | Answer | Why |
|---|---|---|
| Violence | None | No game content of any kind |
| Sexual content / nudity | None | N/A |
| Profanity / crude humor | None | N/A |
| Controlled substances (drugs, alcohol, tobacco) | None | N/A |
| Gambling — simulated | No | The app tracks real financial transactions the user enters; it has no chance-based mechanics |
| Gambling — real-money | No | No wagering, no payouts; it's a record-keeping tool, not a trading or betting platform |
| User-generated content shared with others | No | Single-user, on-device only — no accounts, no sharing, no other users to share with (privacy-policy.md "There is no Smara Account server or account") |
| Social features / chat with other users | No | Same — no multi-user or social feature exists |
| Shares user location | No | No location permission requested, no location feature |
| Digital purchases | No | No in-app purchase or billing package in `pubspec.yaml`; the app is free with no monetization mechanism |

Expected outcome: the lowest available rating tier (e.g. "Everyone" /
PEGI 3), consistent with a personal-finance utility app.

## 2. Data Safety form

Google Play's form asks, per data category, whether it is **collected**
(defined by Google as *transmitted off the device*) and/or **shared**
with third parties. Data that only ever lives in the app's local
database/secure storage and is never transmitted does not count as
"collected" under this definition — see `privacy-policy.md`'s "What
stays on your device" section for what that covers here (signing key,
ledger database, settings).

| Data category | Collected? | Shared? | Notes / privacy-policy citation |
|---|---|---|---|
| Location (approximate or precise) | No | No | No location permission requested anywhere; not mentioned in the app at all |
| Personal info (name, email, address, ID numbers, etc.) | No | No | No sign-in, no account, nothing transmitted off-device ("There is no Smara Account server or account") |
| Financial info (card/bank numbers, purchase history, credit score) | No | No | Ledger data (accounts, transactions, balances) is stored only in the local database file ("Ledger database... not uploaded") |
| Health and fitness | No | No | Not applicable — no such data exists in the app |
| Messages | No | No | N/A |
| Photos and videos | No | No | N/A |
| Audio files | No | No | N/A |
| Files and docs | No | No | Backup/CSV export write to a location the *user* chooses via the system file picker — the app itself never receives or transmits that file elsewhere ("Files you save live wherever you put them") |
| Calendar | No | No | N/A |
| Contacts | No | No | N/A |
| App activity (interactions, search history, installed apps) | No | No | No analytics SDK of any kind (verified in `pubspec.yaml`) |
| Web browsing | No | No | The AI-research feature opens the device's own browser with an editable prompt; the app doesn't see or log browsing activity ("Smara Account does not send that prompt to a Smara server") |
| App info and performance (crash logs, diagnostics) | No | No | No crash/diagnostics SDK (verified in `pubspec.yaml`) |
| Device or other IDs | No | No | No ID-related permission requested; no ads SDK (which is the usual source of advertising-ID collection) |

**One nuance worth a deliberate human decision, not a default "no":** the
two optional network lookups (reference exchange rate, investment market
quote) do transmit a currency-pair code or a ticker/ISIN off the device
to a third-party public data provider (Frankfurter/ExchangeRate-API,
Stooq/Yahoo Finance — see `privacy-policy.md`'s "Optional network
lookups" section). That data isn't tied to an identifiable person and
doesn't fall under any of Play's listed personal-data categories above
(a stock ticker isn't "Financial info" in Play's specific sense — that
category means the user's own card/bank/purchase data), so the honest
answer is still "no personal data types collected" — but flagging this
explicitly rather than silently deciding it, since it's a judgment call
about Play's category boundaries, not a fact I can verify mechanically
the way the rest of this table is.

**Security practices section** (separate part of the same form):
- Data encrypted in transit: yes for the two optional lookups (both providers are HTTPS)
- Data encrypted at rest: the signing key and app-lock PIN hash use OS-level secure storage (Keychain/Keystore); the ledger database itself is a plain local file, not separately encrypted at rest (backups *are* encrypted — "Save backup writes an encrypted, passphrase-protected copy")
- User can request data deletion: not applicable in Play's usual sense (no server-side account to delete) — uninstalling the app removes all local data

## 3. Other mandatory Play Console declarations

Not covered above, but required on the same "App content" checklist
before a release can go out. Added 2026-09-14 while starting Play
Console groundwork — these weren't tracked anywhere in this change
before.

| Declaration | Answer | Why |
|---|---|---|
| Ads | No ads | No ad SDK in `pubspec.yaml`, no ad placements anywhere in the app |
| News apps | Not a news app | N/A |
| COVID-19 contact tracing / status apps | Not applicable | N/A |
| Government apps | Not a government app | N/A |
| Target audience — age groups | 18 and over only | Deliberately excludes every "under 18" bracket: selecting any child age group pulls in Google's Families/child-safety policies and extra review, which don't fit a general-audience finance app. Also answer "No" to "Is your app designed to appeal to children primarily" |
| Data safety re-declaration reminder | — | Play requires re-confirming this form on every release with a data-practice change; the answers in section 2 above are the current source of truth |

**Financial features declaration** — Play has a separate, finance-category-specific questionnaire (asks about lending, crypto exchange, payment processing, etc.) that didn't exist in earlier research and needs answering directly in Console rather than assumed here: this app does none of those things (no lending, no crypto trading, no payment processing — it is a local record-keeping tool with two optional read-only market-data lookups), so every sub-question should land on "No," but the exact current wording should be read in Console before answering rather than pattern-matched from this table.

## Open items before this is submission-ready

- [ ] Confirm the ticker/currency-pair judgment call above with a final read of Play's current category definitions in the actual Console UI before submitting (definitions can be updated by Google over time)
- [ ] Complete the content rating questionnaire in Play Console directly using the table above — it's an interactive multi-step form, not a single field
- [ ] Read the actual current wording of Play's "Financial features" questionnaire in Console before answering (section 3) — this app's answers should all be "No," but the exact question set wasn't independently verified here
