## 1. Fix

- [x] 1.1 Add `<uses-permission android:name="android.permission.INTERNET"/>` to `android/app/src/main/AndroidManifest.xml` and verify the file is still valid XML — done

## 2. Verify

- [x] 2.1 Build a release Android artifact (`flutter build apk --release` or `appbundle --release`) and dump its merged permissions with `aapt dump permissions` - verify `android.permission.INTERNET` is now present (it was confirmed absent before this fix, present only via the debug/profile manifest overlays) — done: since the real upload keystore isn't populated yet (`android-release-signing` tasks 2.2/2.3, still open), built and verified with a throwaway local-only test keystore instead, generated and deleted within this same session (never committed, never used for anything else) — this still exercises the real release signing config path (`apksigner verify` confirms it's genuinely release-signed, not a debug-signing fallback), which is what actually matters for this fix. `aapt dump permissions` on the resulting APK shows `android.permission.INTERNET` present.
- [x] 2.2 Confirm the fix didn't accidentally duplicate the permission or break the debug/profile builds - dump permissions for a debug build too and verify no regression — done: debug build's merged permissions show `INTERNET` exactly once, alongside the pre-existing `USE_BIOMETRIC`/`USE_FINGERPRINT`/dynamic-receiver permissions, no duplication or regression
