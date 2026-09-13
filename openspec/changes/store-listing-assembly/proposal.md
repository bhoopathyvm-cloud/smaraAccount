## Why

`app-store-launch-readiness` tracks account enrollment, signing, and the
release build, but its "Store listing assembly" section is five unchecked
items with no detail behind them: no app description exists anywhere in
the repo, no screenshots exist anywhere in the repo, and neither store's
privacy/content-rating forms have been started. That work needs its own
tracked change — it's real, multi-step, cross-checked-against-the-privacy-
policy work, not a one-line task — so it doesn't stay permanently buried
as five bullets nobody looks at closely.

## What Changes

- Draft an app description, keyword list, category, and support URL for
  both App Store Connect and Google Play Console, adapted from the
  existing project website copy (`pages/open-source/smara-account/`)
  rather than written from scratch.
- Capture real screenshots at each store's required device/size classes,
  starting from the iOS Simulator.
- Complete Google Play's content rating questionnaire.
- Complete Google Play's Data Safety form and App Store Connect's App
  Privacy ("nutrition label") section, each cross-checked line-by-line
  against `pages/open-source/smara-account/privacy-policy.md` so the
  store declarations can't drift from what the actual privacy policy
  promises.

## Capabilities

### New Capabilities
- `store-listing-assembly`: both stores have a complete, accurate listing
  (description, keywords, category, support URL, screenshots, content
  rating, and privacy declarations cross-checked against the real privacy
  policy) ready to attach to a submission.

### Modified Capabilities
- (none — no product behavior changes; this is store-listing content and
  metadata only)

## Impact

- No app code changes. Affects only store-facing content: App Store
  Connect's and Google Play Console's listing pages, and whatever local
  drafts/screenshots this change produces before they're pasted into
  those consoles.
- Cross-references `pages/open-source/smara-account/privacy-policy.md`
  (source of truth for the privacy declarations) and
  `app-store-launch-readiness` section 5 (the umbrella tracker this
  change takes over from).
