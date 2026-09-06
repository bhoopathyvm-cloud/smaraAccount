## Context

Surfaced during an `/opsx:explore` session (2026-09-05) triggered by "publish
today on both stores." The codebase turned out to be much closer to
store-ready than the account situation: Android signing config, iOS privacy
manifest, export-compliance flag, and generated app icons are all already
done in-repo across `android-release-signing`, `ios-privacy-compliance`, and
`app-icon-branding`. What's missing is almost entirely external to the
codebase — no Apple Developer Program membership, no Google Play Console
account, no upload keystore generated yet, and the privacy-policy site's
`smara-ai.ch` DNS cutover (`project-website-smara-rebrand`) hasn't landed.
Store-listing assets (screenshots, description, keywords, support URL) are
already prepared, per the user.

Two facts fix the realistic timeline regardless of how much effort goes in:
1. Apple Developer Program enrollment approval time is unpredictable (often
   hours, sometimes 24-48h+) and blocks every downstream iOS/macOS step.
2. A brand-new Google Play Console account cannot reach production without
   Google's mandatory 12-tester/14-consecutive-day closed test — a policy
   gate, not a review queue, and not compressible.

## Goals / Non-Goals

**Goals:**
- One place that tracks the full remaining path to submission on both
  stores, in dependency order, distinguishing what's code/config from what's
  external/human/account-gated.
- Close the one iOS-specific gap no existing change owns: configuring a real
  Apple Developer Team in Xcode for the `Runner` target (the macOS analogue
  is tracked in `macos-app-store-sandbox` task 1.1, but nothing currently
  tracks it for iOS).
- Make the account-enrollment critical path explicit so it's started first,
  not last.

**Non-Goals:**
- Re-doing or duplicating tasks already tracked in `android-release-signing`,
  `ios-privacy-compliance`, `app-icon-branding`, or
  `macos-app-store-sandbox` — this change cross-references them.
- Automating account enrollment, keystore generation, or store-console data
  entry — all genuinely human steps (credentials, payment, identity
  verification, content judgment calls on screenshots/descriptions).
- CI/CD release automation (e.g. `fastlane`) — none exists in this repo
  today; worth a future change once manual submission has happened at least
  once.
- Achieving same-day production release on Google Play — not achievable for
  a new developer account regardless of what this change does (see Context).

## Decisions

### 1. Cross-reference existing changes instead of duplicating their tasks

`android-release-signing`, `ios-privacy-compliance`, and `app-icon-branding`
already have their own `tasks.md` with the remaining human/verify steps
tracked. This change's tasks reference those by change name and task number
rather than re-listing them, so there's a single source of truth per task and
no drift between two checklists for the same step.

**Alternative considered:** copy the remaining tasks in wholesale so this
change is self-contained. Rejected — two checklists for the same keystore
generation step would inevitably desync (one gets checked, the other
doesn't), and `tool/check_archived_changes_complete.sh` cares about each
change's own `tasks.md` being accurate.

### 2. Track iOS Team configuration here, not by editing `macos-app-store-sandbox`

`macos-app-store-sandbox` task 1.1 is scoped to macOS. iOS distribution needs
the same "pick a real Team in Signing & Capabilities" step but for the
`Runner` target's iOS build configuration, and belongs to a different
distribution flow (App Store Connect vs. a notarized macOS build). Rather
than widen an existing change's scope after the fact, this change owns the
iOS-specific instance of that step and links to the macOS one for context.

### 3. Sequence tasks so the two account enrollments start first

Both account approvals are the long poles and their timing is outside this
project's control. Every other task in this change is either independent of
them (Android keystore generation, DNS cutover, listing asset assembly) or
blocked on them (Xcode Team configuration, App Store Connect / Play Console
work). Putting enrollment first in `tasks.md` means it starts ticking
immediately rather than being reached only after everything else is done.

### 4. Treat "submitted" differently per store

For iOS, "done" for this change means submitted for App Review — the review
itself is Apple's process, not something this change can complete on a
timeline. For Android, "done" for this change means pushed to a **closed
testing** track with the required testers, explicitly *not* production —
requesting production access is a separate follow-up once the 14-day clock
completes and passes, and shouldn't block this change from ever closing.

## Risks / Trade-offs

- **[Risk]** Someone reads this change's title and expects "published today"
  to be achievable by doing the tasks fast → **Mitigation:** proposal and
  this design state the external timeline constraints explicitly; tasks are
  ordered so the account-enrollment clocks start immediately.
- **[Risk]** Play Console's Data Safety form or App Store Connect's App
  Privacy labels drift from what the privacy policy actually documents →
  **Mitigation:** task explicitly cross-checks both forms against
  `pages/open-source/smara-account/privacy-policy.md` rather than filling
  them from memory.
- **[Risk]** The upload keystore or its passwords get lost after generation,
  which would permanently block future Android updates → **Mitigation:**
  already called out as a risk in `android-release-signing`'s own design;
  this change's task references that guidance rather than re-deriving it.
- **[Trade-off]** This change will likely stay open for ~2+ weeks (bounded by
  Google's closed-testing clock) even though most of its own tasks finish
  much sooner — acceptable, since the alternative (closing it early and
  losing track of the pending production-access follow-up) is worse.

## Migration Plan

1. Start Apple Developer Program enrollment and Google Play Console
   registration (human, external, no dependencies).
2. In parallel: finish `android-release-signing`'s remaining tasks (keystore,
   `key.properties`, signed-build verification); land the `smara-ai.ch` DNS
   cutover from `project-website-smara-rebrand`; assemble store listings from
   already-prepared assets.
3. Once Apple approves: configure the real Team in Xcode for `Runner` (iOS),
   verify archive builds, create the App Store Connect record, submit for
   review.
4. Once Play Console activates: create the app record, upload the signed
   AAB, enroll in Play App Signing, complete listing/content-rating/Data
   Safety forms, push to closed testing with required testers.
5. Re-run `tool/run_acceptance_tests.sh -d macos` and on a real Android
   device before either submission.
6. Rollback: not applicable — this change has no code to revert; if a
   submission is rejected, the relevant task is reopened with the rejection
   reason noted.

## Open Questions

- Should a future change introduce `fastlane` (or similar) for repeatable
  builds/uploads once this first manual submission is done? Left for a
  follow-up change — not needed to get the first release out.
- Once the Play closed-testing clock completes, does requesting production
  access belong to this change (reopened if already closed) or a new
  follow-up change? Default: if this change is still open when the clock
  completes, finish it here; if it's already been archived, open a small
  follow-up change instead of reopening an archived one.
