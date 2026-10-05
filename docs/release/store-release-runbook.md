# Store release runbook

Step-by-step procedure for shipping a release to **Google Play**, **iOS**
(TestFlight → App Store), and the **Mac App Store**. Every release ships
all three with the same version and build number.

- 🤖 = a command you (or an agent) run from the repository root.
- 👤 = a step that only works in a store console (Play Console, App Store
  Connect) or needs your Apple/Google sign-in.

Related documents: [release checklist](checklist.md) (the release gates),
[Android upload keystore](android-upload-keystore.md) (first-time Android
signing), [store listing sources](store-listing/README.md).

| Identifier | Value |
|---|---|
| Apple bundle id (iOS + macOS, one App Store Connect record) | `com.smaraaccounting.smaraAccounting` |
| Apple team | `PLUT6R5W2W` |
| Android application id | `com.smaraaccounting.smara_accounting` |
| Release tags | `v<version>+<build>`, e.g. `v2026.10.0+4` |

---

## 1. Pick the version and build number

Versions are **calendar versions `YYYY.MM.N`**: four-digit year,
**zero-padded** two-digit month, and a counter for releases in that month
starting at 0 (`2026.10.0`, `2026.10.1`, `2026.11.0`). The build number
after `+` is **shared by all three stores** and only ever goes up.

1. 🤖 Find the last release and the next build number:

   ```sh
   git fetch --tags origin
   PREV=$(git tag --list 'v*' --sort=-v:refname | head -1); echo "$PREV"
   echo "next build: $(( ${PREV##*+} + 1 ))"
   ```

2. 🤖 Choose the version: this year and month, and `N` = number of
   existing `vYYYY.MM.*` tags for this month (0 if none).

> **Never reuse a build number** — not even one that a store never
> received. Apple can report `Upload succeeded` for a reused or rejected
> build number while no build ever appears in App Store Connect (this
> happened with iOS build 2).
>
> **First zero-padded month (e.g. `2026.01.0`):** App Store Connect's
> handling of a leading zero has not been confirmed yet. Months 10–12
> have no leading zero, so the first such release will be a single-digit
> month; after its upload, confirm the version shows as expected in App
> Store Connect and note the result here.

3. 🤖 Open a PR against `main` that changes only `pubspec.yaml`'s
   `version:` (for example `version: 2026.10.0+4`), titled
   `Release <version>+<build>`. Merge it once CI is green.
   **Releases are only built from `main`**; the merge commit is the
   release candidate.

   ```sh
   git switch main && git pull --ff-only
   CANDIDATE=$(git rev-parse HEAD); echo "$CANDIDATE"
   ```

## 2. Pass the release gates

Follow the [release checklist](checklist.md) for the candidate commit:

- 🤖 Dispatch the acceptance workflow on `main` while `main` is still the
  candidate, and require every locale job to pass:

  ```sh
  gh workflow run acceptance-suite-nightly.yml --ref main
  gh run list --workflow acceptance-suite-nightly.yml --limit 1 \
    --json databaseId,headSha,status,conclusion,url
  ```

  The run's `headSha` must equal `$CANDIDATE`. If `main` moved, re-dispatch.
- 🤖 Run the macOS English baseline (`tool/run_acceptance_tests.sh -d macos`)
  on the candidate, as the checklist describes.

If either gate fails, stop: fix through `main` and start again from step 1
with the next build number.

## 3. Check whether the store listing needs updating

🤖 Compare against the previous release:

```sh
git diff --stat "$PREV"..HEAD -- \
  lib/ui/features/home lib/ui/features/register \
  lib/ui/features/account_management lib/ui/features/settings \
  lib/ui/core pages/open-source/smara-account/privacy-policy.md
```

- **Any screen shown in the screenshots or previews changed visually, or
  a feature named in the [listing description](store-listing/listing.md)
  changed?** Recapture **every** size class, re-record the previews, and
  update the text. Use Simulators/emulators only — the tools reset the
  app's data and signing keys.
  - 🤖 Screenshots (19 per class, file names in store-priority order):
    `tool/capture_store_screenshots.sh -d <device-id> -c <size-class>`
    for each of `iphone-6.9in`, `iphone-6.5in`, `ipad-13in`,
    `android-phone`, `android-tablet-10in` (device per
    [the size table](store-listing/README.md#screenshot-size-classes)).
    Upload the **first 10** to each App Store size and the **first 8** to
    each Play device type.
  - 🤖 Previews: `tool/record_store_previews.sh -d <device-id> -c <size-class>`
    for each iOS class (three App Store previews each) and once on the
    Android phone emulator (the captioned tour). Output goes to
    `build/store_media/<size-class>/` (not committed).
  - 👤 Mac: screenshot the signed macOS build's window at 2880×1800 into
    `docs/release/store-listing/screenshots/mac/`.
  - 🤖 Edit [`store-listing/listing.md`](store-listing/listing.md) and
    merge the listing changes through their own PR to `main`. They are
    docs only, so they don't change the candidate's binary; the release
    tag still goes on `$CANDIDATE`.
- **Privacy policy changed?** 👤 Re-check App Store Connect → App Privacy
  and Play Console → Data safety against
  [the privacy policy](../../pages/open-source/smara-account/privacy-policy.md)
  (drafts: [`app-privacy.md`](store-listing/app-privacy.md),
  [`content-rating-and-data-safety.md`](store-listing/content-rating-and-data-safety.md))
  before submitting.
- Otherwise, skip — the listing stays as it is.

Listings and release notes are **English only**.

## 4. Tag and draft the GitHub Release

🤖 Tag the candidate and create a **draft** release. The tag is the
release record; upload only binaries built from it.

```sh
TAG="v$(sed -n 's/^version: //p' pubspec.yaml)"; echo "$TAG"
git tag -a "$TAG" "$CANDIDATE" -m "Release $TAG"
git push origin "$TAG"

cat > /tmp/release-gates.md <<EOF_NOTES
## Release gates
- Commit: $CANDIDATE
- Locale gate (all locales green): <acceptance workflow run URL>
- macOS baseline: 37/37 passed on <date>, <macOS / Xcode versions>
EOF_NOTES
gh release create "$TAG" --draft --verify-tag --title "$TAG" \
  --notes-file /tmp/release-gates.md --generate-notes --notes-start-tag "$PREV"
```

Fill in the placeholders (`gh release edit "$TAG" --notes-file …`, or in
the browser). The generated "What's Changed" list is the source for every
store's **What's new** text: write a short, user-facing English summary
of it.

## 5. Google Play

1. 🤖 Build and check the release-signed bundle (first time on this
   machine: set up signing per
   [android-upload-keystore.md](android-upload-keystore.md)):

   ```sh
   git switch --detach "$TAG"
   flutter build appbundle --release
   keytool -printcert -jarfile build/app/outputs/bundle/release/app-release.aab
   ```

   The certificate must be the upload key, not `CN=Android Debug`.
   If the listing check re-recorded the tour: 👤 upload
   `build/store_media/android-phone/tour_1920x1080.mp4` to YouTube
   (public or unlisted, ads off, not a Short), paste its URL in Play
   Console → **Grow users → Store presence → Main store listing →
   Video**, and embed the same video on the website's Smara Account page
   (the App Store description points there).
2. 👤 Play Console → **Test and release → Testing → Closed testing** →
   the existing track → **Create new release** → upload
   `build/app/outputs/bundle/release/app-release.aab` → release notes
   (`en-US`) = the What's new summary → **Next → Save and publish** /
   **Start rollout**.
3. 👤 When closed testers are happy: **Promote release → Production**
   with a **staged rollout of 20%**. (Production access must have been
   granted; if it hasn't, the build stays in closed testing.)
4. 👤 **3 days later**: Production → **Update rollout** to **100%**.
   If something is wrong before then, **Halt rollout** instead and fix
   through `main` with a new build number.

## 6. iOS (TestFlight → App Store)

**Command line** (🤖, uploads directly using
[`ios/ExportOptions.plist`](../../ios/ExportOptions.plist)):

```sh
git switch --detach "$TAG"
flutter build ipa --release --export-options-plist=ios/ExportOptions.plist
/usr/libexec/PlistBuddy -c 'Print CFBundleShortVersionString' \
  -c 'Print CFBundleVersion' \
  build/ios/archive/Runner.xcarchive/Products/Applications/Runner.app/Info.plist
```

The output must end with `Upload succeeded` and print the release's
version and build. If signing needs refreshing, the equivalent explicit
path used before is (the first line makes Xcode pick up the version and
build from `pubspec.yaml`):

```sh
flutter build ios --release --config-only
xcodebuild archive -workspace ios/Runner.xcworkspace -scheme Runner \
  -configuration Release -sdk iphoneos -destination "generic/platform=iOS" \
  -archivePath build/ios/archive/Runner.xcarchive
xcodebuild -exportArchive -archivePath build/ios/archive/Runner.xcarchive \
  -exportOptionsPlist ios/ExportOptions.plist \
  -exportPath build/ios/export -allowProvisioningUpdates
```

**Xcode Organizer** (👤): `open ios/Runner.xcworkspace` → scheme
**Runner**, destination **Any iOS Device** → **Product → Archive** →
Organizer → **Distribute App → App Store Connect → Upload**.

Then in App Store Connect (👤):

1. Wait until the build finishes processing (email, or **TestFlight** tab
   shows it). Don't assign testers before that.
2. **TestFlight**: add the build to the internal group; for external
   testers, add it to the external group (may need Beta App Review).
3. **App Store → iOS App → +** new version `<version>` → **What's New**
   = the summary → **Build**: select this build. If previews were
   re-recorded, upload `build/store_media/<size-class>/app_preview_*.mp4`
   (three per size) under **App Previews and Screenshots**, and the first
   10 screenshots per size. Never mention YouTube, Android, or Google Play
   in any App Store text (App Review guideline 2.3.10).
4. **Version Release**: **Automatically release this version**. Leave
   **Phased Release for Automatic Updates** off.
5. **Add for Review → Submit**. The version goes live on approval.

## 7. macOS (TestFlight → Mac App Store)

Same App Store Connect record as iOS, separate **macOS App** version.

**Command line** (🤖, using
[`macos/ExportOptions.plist`](../../macos/ExportOptions.plist)):

```sh
git switch --detach "$TAG"
flutter build macos --release
xcodebuild archive -workspace macos/Runner.xcworkspace -scheme Runner \
  -configuration Release -archivePath build/macos/Runner.xcarchive
xcodebuild -exportArchive -archivePath build/macos/Runner.xcarchive \
  -exportOptionsPlist macos/ExportOptions.plist \
  -exportPath build/macos/export -allowProvisioningUpdates
```

**Xcode Organizer** (👤): `open macos/Runner.xcworkspace` → scheme
**Runner**, destination **Any Mac** → **Product → Archive** →
**Distribute App → App Store Connect → Upload**.

Known App Store Connect rejections, all already fixed — if one comes
back, something reverted:

| Error | Cause | Fix in the repo |
|---|---|---|
| 90285 `Invalid Code Signing Entitlements … keychain-access-groups` | Keychain access-group entitlement on macOS | Keep it out of `macos/Runner/Release.entitlements` |
| 90242 `Info.plist must contain a LSApplicationCategoryType key` | Missing category | `LSApplicationCategoryType = public.app-category.finance` in `macos/Runner/Info.plist` |
| App Encryption Documentation prompt | Missing export-compliance flag | `ITSAppUsesNonExemptEncryption = false` in `macos/Runner/Info.plist`; basis: Apple builds use only the operating system's encryption (ADR 0005, OpenSpec `os-provided-encryption`; `test/platform/export_compliance_test.dart`) |

Then in App Store Connect (👤): same steps as iOS 1–5 under **macOS App**
(processing, TestFlight, new version `<version>`, **Automatically release**,
submit for review).

## 8. Finish

- 🤖 When all three stores have accepted the build, publish the release:
  `gh release edit "$TAG" --draft=false`.
- 🤖 `git switch main`.
- **A store rejects the build?** Fix it through a PR to `main`, then run
  this runbook again from step 1 with the **next** build number (the same
  version is fine if it never went live). A metadata-only rejection
  (screenshots, text, review answers) is fixed in the console without a
  new build.
