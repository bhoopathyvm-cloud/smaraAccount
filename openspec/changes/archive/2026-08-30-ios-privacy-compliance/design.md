## Context

Found during App Store distribution planning (2026-08-27). Neither declaration exists yet since the app has never been submitted to the App Store before. Both are Apple-specific (macOS App Store submissions ask a similar export-compliance question through the same App Store Connect flow, so this change benefits both iOS and Mac App Store submissions even though it's scoped and named for iOS).

## Goals / Non-Goals

**Goals:**
- Accurate, not maximally-permissive-by-guessing, export-compliance and privacy-manifest declarations.
- One consistent story across the privacy manifest, the App Store Connect questionnaire, and the public privacy policy page — not three independently-drifting documents.

**Non-Goals:**
- Actually filling in App Store Connect's own App Privacy questionnaire UI — that happens per submission, outside this repo, informed by (not replaced by) this change.
- Google Play's equivalent Data Safety form — a separate, non-Apple mechanism; not addressed here (Android has no manifest-file equivalent to prepare in-repo).
- Re-litigating whether the app's crypto usage is genuinely exempt from export licensing in every jurisdiction — the standard Apple exemption category (authentication/integrity only, no proprietary algorithms, not a cryptography product) is well-established for apps like this one, but this isn't legal advice and the user should sanity-check the final answer against Apple's own current guidance before submitting.

## Decisions

### 1. `ITSAppUsesNonExemptEncryption = false`, with the reasoning stated in a comment

This app's cryptography (`cryptography` package for signing/verification, PBKDF2 for the PIN hash) is used exclusively for local authentication and data-integrity verification — never for confidentiality of communications, never a proprietary algorithm, and the app itself is not "primarily a cryptography product." This is the standard case Apple's export-compliance exemption (per the U.S. EAR's mass-market/authentication carve-out) covers. Setting the key explicitly means App Store Connect skips the interactive questionnaire on every future build upload — a real ongoing-friction reduction, not just a one-time checkbox.

### 2. Privacy manifest covers the app target's own API usage; plugin manifests are audited, not duplicated

Apple's model is that each bundled SDK/plugin ships its *own* `PrivacyInfo.xcprivacy` if it touches a required-reason API; the app target's own manifest only needs to declare APIs the app's *own* code touches directly. Rather than guess, audit the plugins most likely to touch these APIs (`shared_preferences` → `NSUserDefaults`; `path_provider`/`sqlite3` → file timestamp APIs) for whether their installed pub.dev versions already bundle a manifest, and only add app-target declarations for genuine gaps found.

## Risks / Trade-offs

- **[Risk]** Getting the export-compliance answer wrong (claiming exemption when not actually eligible) has real legal weight, not just an App Store rejection → **Mitigation:** state the exemption reasoning explicitly in this document and a code comment, so it's reviewable, and treat App Store Connect's own current guidance as the tie-breaker at actual submission time, not this document alone.
- **[Risk]** A plugin's bundled privacy manifest goes missing or stale after a future dependency bump → **Mitigation:** the audit task in `tasks.md` is a repeatable checklist, worth re-running whenever `pubspec.lock` changes for one of the audited packages.
- **[Trade-off]** None beyond the audit effort itself.

## Migration Plan

1. Add `ITSAppUsesNonExemptEncryption` to `Info.plist` per Decision 1.
2. Audit each listed plugin's installed version for a bundled `PrivacyInfo.xcprivacy` (check the package's source under `~/.pub-cache` or its CHANGELOG for "privacy manifest" mentions).
3. Add `ios/Runner/PrivacyInfo.xcprivacy` for the app target, covering only genuine gaps found in step 2 plus anything the app's own Swift/Dart code touches directly.
4. Cross-check against `privacy-policy-page`'s documented data flows for consistency.
5. Rollback = revert the `Info.plist`/manifest changes; no data migration.

## Open Questions

- None outstanding — the audit itself will surface any remaining gaps as concrete findings, not open design questions.

## Plugin privacy-manifest audit (apply)

Checked the versions resolved by this repo's `pubspec.lock` for a bundled
`PrivacyInfo.xcprivacy`. Findings:

- `shared_preferences_foundation`, `file_picker_darwin`,
  `flutter_secure_storage_darwin`, `local_auth_darwin`, and
  `url_launcher_ios` ship privacy manifests.
- `path_provider_foundation` and `sqlite3` / Drift's native layer do **not**.
  The app target's `ios/Runner/PrivacyInfo.xcprivacy` therefore declares
  file-timestamp access (`C617.1`) for the local ledger database (and
  `path_provider`'s app-container paths), plus UserDefaults (`CA92.1`)
  for Flutter/`shared_preferences` settings. No tracking; no collected
  data types. That matches `privacy-policy-page`.
