# App Store Connect App Privacy draft (tasks 4.1–4.2)

Apple's App Privacy ("nutrition label") section uses a different
taxonomy than Google Play's Data Safety form, but the same underlying
facts from `pages/open-source/smara-account/privacy-policy.md` and the
same verified code/manifest checks from
`content-rating-and-data-safety-draft.md` apply — see that file for the
"no analytics/crash/ads SDK, no location permission" verification, not
repeated here.

Critically, this app **already has a standing, code-level commitment**
to the answer below: `ios/Runner/PrivacyInfo.xcprivacy` (required by
`ios-privacy-compliance`, an already-archived, already-enforced
requirement) declares:

```xml
<key>NSPrivacyTracking</key>
<false/>
<key>NSPrivacyCollectedDataTypes</key>
<array/>
```

That's Apple's own build-time privacy manifest saying "no tracking, zero
collected data types," present in every archive already verified this
session (`app-store-launch-readiness` task 3.4). The App Store Connect
questionnaire answers below have to match this exactly — Apple treats a
mismatch between the manifest and the Connect declaration as a real
compliance problem, not just an inconsistency between two documents.

## 1. Data collection: overall answer

**"No, we do not collect data from this app."**

This is the single most important field in the whole questionnaire —
answering it "No" skips the entire per-category questionnaire below
that answering "Yes" would otherwise require. It's justified by the same
evidence as the Play Data Safety table: no sign-in/account, no
analytics/crash/ads SDK, and everything the app touches (ledger
database, signing key, settings) stays in local storage or OS secure
storage per privacy-policy.md's "What stays on your device" section.

## 2. The one nuance, same as Play's form

The two optional network lookups (reference exchange rate, investment
market quote — privacy-policy.md "Optional network lookups") do send a
currency-pair or ticker/ISIN code to a third-party public data provider.
Apple's own category list (Contact Info, Health & Fitness, Financial
Info, Location, Sensitive Info, Contacts, User Content, Browsing
History, Search History, Identifiers, Purchases, Usage Data,
Diagnostics, Other Data) has no category a bare currency code or ticker
symbol fits into — it isn't the user's own "Financial Info" in Apple's
specific sense (that category is about payment/credit info), and it
isn't linked to the user's identity. Flagging this explicitly, same as
the Play draft — it's the same underlying judgment call for both stores,
not two separate risks.

## 3. Export compliance (same screen, App Store Connect submission flow)

`ITSAppUsesNonExemptEncryption` is already `false` in `ios/Runner/
Info.plist`, matching privacy-policy.md's "Cryptography (export
compliance)" section (crypto used only for local signing/verification
and PIN hashing, not to scramble network traffic or as a standalone
crypto product) and the already-enforced `ios-privacy-compliance`
requirement that this stays consistent with the public policy. Nothing
new needed here — just confirming it's already correct before
submission, since App Store Connect will ask this again at upload time.

## 4. Cross-store comparison (task 4.2)

| | Google Play Data Safety | App Store Connect App Privacy |
|---|---|---|
| Overall answer | No data collected | No, we do not collect data |
| Basis | Same privacy-policy.md + same code/manifest checks | Same privacy-policy.md + same code/manifest checks, additionally backed by the existing `PrivacyInfo.xcprivacy` build artifact |
| Flagged nuance | Currency-pair/ticker lookup doesn't fit Play's categories | Same lookup doesn't fit Apple's categories either |
| Tracking | N/A (Play doesn't have a separate "tracking" toggle the way Apple does) | `NSPrivacyTracking = false`, already declared and enforced |

Both stores tell the same story because they're built from the same
source facts, not drafted independently — exactly what
`store-listing-assembly`'s design.md set out to guarantee.

## Open items before this is submission-ready

- [ ] Confirm the currency-pair/ticker judgment call (same one flagged for Play) against Apple's current category definitions in App Store Connect directly before submitting
- [ ] Walk through the actual App Store Connect App Privacy UI using this draft — it's a multi-step interactive form, not a single field
