## 1. App description, keywords, category, support URL

- [ ] 1.1 Draft a short description (Play Console's 80-char short description limit) and verify it fits without truncation
- [ ] 1.2 Draft a full description (App Store Connect's 4000-char limit, Play Console's 4000-char full description), adapted from `pages/open-source/smara-account/index.md`'s "what it is / the problem / the solution" framing, and verify both fit their store's limit
- [ ] 1.3 Choose keywords for App Store Connect's 100-character keyword field and verify the count fits
- [ ] 1.4 Confirm category: `public.app-category.finance` (already set in `macos/Runner/Info.plist`) for App Store Connect; the equivalent Play Console category (Finance)
- [ ] 1.5 Confirm the support URL to submit to both stores (e.g. the project website's contact/about page) and verify it resolves with a 200 status

## 2. Screenshots

- [ ] 2.1 List every iOS device size class App Store Connect currently requires screenshots for, and every Android device size class Play Console currently requires
- [ ] 2.2 Launch the app on iOS Simulator for each required size class and capture screenshots of the key screens (home/overview, a transaction entry, an account/ledger view, backup or settings) — verify each captured image's pixel dimensions match that size class's requirement
- [ ] 2.3 Spot-check at least one Simulator screenshot against the real iPhone (font rendering, safe-area insets) and verify no visible mismatch before treating the Simulator set as final
- [ ] 2.4 Capture Android screenshots (emulator or the real Android tablet already used for acceptance testing) for Play Console's required size classes
- [ ] 2.5 Organize all captured screenshots into per-store, per-size-class folders and verify every required slot has an image before moving to submission

## 3. Google Play content rating and Data Safety

- [ ] 3.1 Complete Google Play's content rating questionnaire based on the app's actual functionality (personal finance ledger, no user-generated social content, no ads, no gambling mechanics) and verify the resulting rating is generated without needing to guess an answer
- [ ] 3.2 Go through `pages/open-source/smara-account/privacy-policy.md` line by line and list every data type/purpose it actually describes
- [ ] 3.3 Fill in Google Play's Data Safety form using that list — verify every field traces back to a specific line in the privacy policy, and nothing is declared that the policy doesn't also describe

## 4. App Store Connect App Privacy

- [ ] 4.1 Fill in App Store Connect's App Privacy ("nutrition label") section using the same line-by-line list from task 3.2 — verify every field traces back to the privacy policy the same way
- [ ] 4.2 Cross-compare the two stores' completed privacy declarations against each other and verify they describe the same data practices (a discrepancy between them would mean one is wrong, since they describe the same app and the same policy)

## 5. Handoff

- [ ] 5.1 Update `app-store-launch-readiness`'s section 5 to point at this change instead of carrying its own unchecked copies of these tasks, once this change's tasks are complete
