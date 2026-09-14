## 1. App description, keywords, category, support URL

- [x] 1.1 Draft a short description (Play Console's 80-char short description limit) and verify it fits without truncation — drafted at 74 chars, see `store-listing-draft.md`
- [x] 1.2 Draft a full description (App Store Connect's 4000-char limit, Play Console's 4000-char full description), adapted from `pages/open-source/smara-account/index.md`'s "what it is / the problem / the solution" framing, and verify both fit their store's limit — drafted at 2,573 chars (one shared version for both stores), see `store-listing-draft.md`
- [x] 1.3 Choose keywords for App Store Connect's 100-character keyword field and verify the count fits — drafted at 90 chars, see `store-listing-draft.md`
- [x] 1.4 Confirm category: `public.app-category.finance` (already set in `macos/Runner/Info.plist`) for App Store Connect; the equivalent Play Console category (Finance) — both confirmed as Finance
- [x] 1.5 Confirm the support URL to submit to both stores (e.g. the project website's contact/about page) and verify it resolves with a 200 status — `https://smara-ai.ch/open-source/smara-account/`, verified via `curl` (HTTP 200)
- [x] 1.6 New, added after the fact: App Store Connect's Subtitle field (30 char limit, shown directly under the app name) — user's own wording, "Your tamper-evident ledger" (26 chars), see `store-listing-draft.md`

Still open before this section is truly done: the app name, description
wording, and the Play short/full-description split all need the user's
review — see "Open items" at the bottom of `store-listing-draft.md`.
This is a first draft to react to, not final copy.

## 2. Screenshots

- [x] 2.1 List every iOS device size class App Store Connect currently requires screenshots for, and every Android device size class Play Console currently requires — researched (2026): only the **largest** size per device family is now mandatory, Apple auto-scales the rest. iPhone 6.9" (1290x2796 or 1320x2868) is required; iPad Pro 13" (2064x2752) is also required since this app is universal (`TARGETED_DEVICE_FAMILY = "1,2"` in `ios/Runner.xcodeproj`). Play Console requires **at least 2 phone screenshots** (mandatory, ~1080x1920-class); a 10" tablet screenshot (1200x1920) is optional but recommended since the app supports tablets.

**Correction (2026-09-14):** this research was wrong for this app record. When the user actually tried "Add for Review," App Store Connect demanded a **6.5-inch** iPhone screenshot (1242x2688 — iPhone 11 Pro Max / XS Max class), not 6.9". Auto-scaling apparently didn't apply the way this section assumed. Captured a real native 6.5" set (`screenshots/iphone-6.5in/`) rather than distorting the 6.9" set to fit a different aspect ratio. The 13" iPad requirement matched what was already researched and captured — that error was about the screenshots not being attached in Connect yet, not about the wrong size.
- [x] 2.2 Launch the app on iOS Simulator for each required size class and capture screenshots of the key screens (home/overview, a transaction entry, an account/ledger view, backup or settings) — done: captured on iPhone 17 Pro Max and iPad Pro 13-inch (M5) simulators via a temporary integration_test file reusing this suite's own acceptance-test navigation helpers (kept as `screenshots/capture-screenshots.dart.reference` for reproducibility, not wired into the build). Verified pixel dimensions with Pillow: iPhone shots are exactly 1320x2868, iPad shots exactly 2064x2752. Also found and fixed a real, permanent debug-ribbon problem along the way (see `lib/main.dart`'s new opt-in `HIDE_DEBUG_BANNER` dart-define) rather than shipping screenshots with a "DEBUG" banner across the corner.
- [x] 2.3 Spot-check at least one Simulator screenshot against the real iPhone (font rendering, safe-area insets) and verify no visible mismatch before treating the Simulator set as final — done: captured the same four screens on the user's real iPhone 15 Pro (1179x2556 — a 6.1" device, not the 6.9" submission size, so this is a fidelity check only, not a replacement asset). Compared Home and Settings directly against the Simulator captures: fonts, spacing, colors, and safe-area insets all match with no visible mismatch. Kept as `screenshots/real-iphone-spot-check/`, separate from the actual submission folders. Took 3 attempts - the first two died silently mid-build with no error text for reasons unrelated to code (not actually a screen-lock issue despite matching that documented failure signature; resolved itself on retry once the invocation matched the exact backgrounding pattern that worked for the Android runs)
- [x] 2.4 Capture Android screenshots (emulator or the real Android tablet already used for acceptance testing) for Play Console's required size classes — done: created a Pixel 9 phone AVD (`smara_store_phone`, no phone-shaped emulator existed before — the only pre-existing AVD, `smara_kiosk_pixel`, is actually a `pixel_tablet` profile) for the mandatory phone shots (1080x2424, verified with Pillow), and used the real Samsung SM X230 tablet already connected for the optional 10" tablet shot (1200x1920, matches Play's documented size exactly). Three real Android-only capture gotchas found and documented in `capture-screenshots.dart.reference`: `takeScreenshot()` needs `convertFlutterSurfaceToImage()` called first, the app is genuinely sandboxed (unlike iOS Simulator) so screenshots must be written inside `getApplicationDocumentsDirectory()` and pulled via `adb ... run-as <applicationId> cat app_flutter/...`, and `flutter test` uninstalls the app immediately on exit so a delay was added to leave a pull window.
- [x] 2.5 Organize all captured screenshots into per-store, per-size-class folders and verify every required slot has an image before moving to submission — done: `screenshots/iphone-6.9in/`, `screenshots/iphone-6.5in/`, `screenshots/ipad-13in/`, `screenshots/android-phone/`, `screenshots/android-tablet-10in/`, four images each. The 6.5" folder was added later (see the correction under 2.1) once App Store Connect's real requirement surfaced — captured on a new `iPhone 11 Pro Max` (6.5" class) simulator, verified at the exact required 1242x2688
- [x] 2.6 Capture a Mac App Store screenshot from the sandboxed Release archive — done (2026-09-14): reset the app's local database, completed onboarding with disposable USD 1,000 Salary data, and captured `screenshots/mac/01_home.jpg`. Cropped and sized to Apple's accepted 2880x1800 Mac slot; visually checked that no personal account data or recovery phrase appears.
- [x] 2.7 New, found while starting Play Console groundwork (2026-09-14): Play Console requires a 1024x500 feature graphic — a mandatory store-listing asset with no App Store Connect equivalent, not previously tracked anywhere in this change. Generated `play-store-feature-graphic.png` from the approved brand assets (the navy `#133B7B` / ivory `#FCF3E2` colors sampled directly from `assets/branding/app_icon.png`, the icon itself, and the already-approved subtitle wording "Your tamper-evident ledger"), not new artwork

Known rough edge to revisit before these are final: the Accounts screenshot
shows several account groups as empty ("No accounts") since the onboarding
seed data only creates one Cash & Bank account — a screenshot with 2-3
populated account types (e.g. adding a credit card or investment account
first) would look more representative. Shipped as-is for this pass rather
than risk further navigation debugging; flagged here instead of hidden.

## 3. Google Play content rating and Data Safety

- [x] 3.1 Complete Google Play's content rating questionnaire based on the app's actual functionality (personal finance ledger, no user-generated social content, no ads, no gambling mechanics) and verify the resulting rating is generated without needing to guess an answer — drafted: every category answered "none/no" with a verifiable reason (no IAP package in `pubspec.yaml`, no social/sharing feature, no location permission). See `content-rating-and-data-safety-draft.md`.
- [x] 3.2 Go through `pages/open-source/smara-account/privacy-policy.md` line by line and list every data type/purpose it actually describes — done, same file: a full Play Data Safety category table, each row citing the specific policy section it traces to (or a direct code/manifest check where the policy itself doesn't cover it, e.g. confirming no analytics SDK)
- [x] 3.3 Fill in Google Play's Data Safety form using that list — verify every field traces back to a specific line in the privacy policy, and nothing is declared that the policy doesn't also describe — drafted: "no data collected" across every Play category, with one nuance flagged explicitly rather than silently decided (the two optional lookups do send a currency-pair/ticker code off-device, which doesn't fall under any of Play's personal-data categories, but is a judgment call worth a final human check against Play's current category definitions before submitting)

**Real bug found and fixed while doing this cross-check, not part of this
change's own scope**: `android.permission.INTERNET` was only present via
Flutter's debug/profile manifest overlays, never in the manifest that
ships in Release — meaning both optional network features would have
silently failed in the actual Play Store build. Fixed and verified
separately in `android-release-internet-permission` (PR #168, its own
branch/change per this repo's convention, since it's a real app-code
change and this change's own scope is explicitly docs/content-only). The
Data Safety draft above assumes that fix is merged.

## 4. App Store Connect App Privacy

- [x] 4.1 Fill in App Store Connect's App Privacy ("nutrition label") section using the same line-by-line list from task 3.2 — verify every field traces back to the privacy policy the same way — drafted: "No, we do not collect data" as the overall answer, which is not just derived from the same evidence as the Play draft but already backed by a standing code artifact — `ios/Runner/PrivacyInfo.xcprivacy` (an already-enforced `ios-privacy-compliance` requirement) declares `NSPrivacyTracking = false` and `NSPrivacyCollectedDataTypes = []` in every archive already verified this session. See `app-privacy-draft.md`.
- [x] 4.2 Cross-compare the two stores' completed privacy declarations against each other and verify they describe the same data practices (a discrepancy between them would mean one is wrong, since they describe the same app and the same policy) — done, same file: both stores land on "no data collected," from the same source facts, with the same currency-pair/ticker nuance flagged on both sides rather than resolved differently per store

## 5. Handoff

- [ ] 5.1 Update `app-store-launch-readiness`'s section 5 to point at this change instead of carrying its own unchecked copies of these tasks, once this change's tasks are complete
