## Why

Discovered while cross-checking permissions for `store-listing-assembly`'s
Google Play Data Safety form: `android.permission.INTERNET` is only
declared in `android/app/src/debug/AndroidManifest.xml` and
`.../profile/AndroidManifest.xml` (Flutter's default templates, added for
hot-reload/DevTools), not in `android/app/src/main/AndroidManifest.xml` —
the manifest that actually ships in a release build. Confirmed against a
real built APK's merged permissions, not just by reading source: a debug
build shows `INTERNET`; the main manifest alone doesn't declare it.

Practical effect: in the actual Play Store release, the two optional
network features (reference exchange rate lookup, investment market
quote lookup) would silently fail — Android blocks the socket call
outright without the permission, and the app's own "if a lookup fails,
keep working with what it already has" resilience swallows the failure
quietly. This has never been caught because every dev/test run (`flutter
run`, `flutter test`, the acceptance suite) uses the debug manifest,
which has the permission — nobody has run this on a genuinely
release-signed build before.

## What Changes

- Add `<uses-permission android:name="android.permission.INTERNET"/>` to
  `android/app/src/main/AndroidManifest.xml`, so it's present in Debug,
  Profile, *and* Release builds instead of only the first two.

## Capabilities

### New Capabilities
(none)

### Modified Capabilities
(none — this restores behavior the existing `reference-exchange-rate-
lookup` and `investment-research-enablement` specs already describe as
working; it doesn't change what either spec promises, it fixes an
implementation gap that silently violated both on Android release
builds. `skip_specs: true` set in `.openspec.yaml` accordingly.)

## Impact

- `android/app/src/main/AndroidManifest.xml` (one line added).
- No behavior change on iOS/macOS - `INTERNET` is an Android-only
  permission concept, unaffected there.
- Directly relevant to `store-listing-assembly`'s Data Safety form: the
  form should describe these two lookups as actually functioning
  features (matching intent and the privacy policy), not describe a
  broken state.
