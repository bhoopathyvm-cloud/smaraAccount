## Context

`acceptance-suite-github-runner-spike` (archived 2026-09-12) proved the full acceptance suite runs cleanly against Linux in CI: all 43 locales, ~11 minutes each, `ubuntu-latest`, well within the 6h hosted-runner cap. `localized-release-verification` (archived earlier) established the manual macOS 9-locale sweep as the pre-release locale gate, at the time the only known way to get real per-locale assurance. That reasoning is now superseded by real data: Linux CI is ~40-50x faster and covers more than 4x the locales.

This proposal went through two rounds of correction before landing here: initially scoped as "nightly Linux CI supplements the existing macOS process" (both stand), then corrected to "nightly Linux CI fully replaces macOS testing," then corrected again to "replace the multi-locale macOS sweep, but keep a lighter, single-locale macOS check" once the loss of real macOS-platform coverage (window/rendering quirks, Keychain behavior — genuinely different code paths than Linux) was weighed against the cost savings. The final shape: Linux CI absorbs all locale-regression responsibility; macOS keeps exactly the baseline (English-only) check it always had before `acceptance-tests-multi-locale` even started.

## Goals / Non-Goals

**Goals:**
- Make the nightly Linux CI tier the standing, automatic locale-regression gate, replacing a expensive manual process with a free, fast, automatic one.
- Preserve real macOS platform verification — just not multiplied across 9 locales anymore.
- Keep this out of `flutter-ci.yml`'s required PR gate; a nightly cadence, not a per-PR one.

**Non-Goals:**
- Automating the macOS baseline check in CI too. GitHub does have macOS-hosted runners, and this could plausibly work (unverified), but is a separate decision — this proposal only changes the locale-regression gate's mechanism, not whether the macOS check itself becomes automated.
- Deleting `tool/run_localized_acceptance_tests.sh`. It becomes unused as a pre-release step but may still be useful for ad hoc local debugging of a specific locale; removing it is a separate, later cleanup decision if it turns out to have no remaining use.
- Changing anything about which locales are "supported" (`kSupportedLocaleTags`) or how fixtures are translated — this proposal is about where/how the suite runs, not what it covers linguistically.

## Decisions

1. **Rename `acceptance-suite-spike.yml` to `acceptance-suite-nightly.yml` rather than adding a second workflow file.** The spike's workflow is already the exact mechanism needed (Linux target, Xvfb/D-Bus/keyring setup, all-43-locale matrix) — it just needs a `schedule` trigger added and its "spike"/experimental framing dropped from its own comments. No reason to duplicate it.
2. **Nightly cron, not per-PR, not weekly.** The user's explicit choice. Nightly means at most a one-day delay between a regression landing and it surfacing, without adding ~11 minutes × 43 locales of latency to every single PR (which would also cost real Linux-runner queue capacity shared with `localized-smoke.yml` and every other workflow).
3. **Release readiness now means "check the nightly tier's latest result," not "run a new command."** Unlike the old manual sweep (which a release owner actively started and waited on), the nightly tier already runs continuously in the background — release prep just needs to look at its most recent result near the release candidate's commit. If it's stale (last run predates meaningful changes) or red, that's the trigger to investigate or wait for the next run before releasing.
4. **Keep the macOS check at exactly its pre-`acceptance-tests-multi-locale` scope: English, no locale flag.** This isn't a new, invented tier — it's reverting to what `tool/run_acceptance_tests.sh -d macos` already did by default before multi-locale support existed. No new tooling, no new decision about which locale(s) to run on macOS.

## Risks / Trade-offs

- **[Real macOS-specific, locale-dependent bugs become invisible until a user hits them]** → This is the core, accepted trade-off, not a bug to fix. Genuinely locale-dependent macOS bugs (e.g., a script-specific rendering issue that only manifests on macOS's font stack, not Linux's) would previously have been caught by the 9-locale macOS sweep and now won't be caught by either tier. Mitigation: none built into this proposal — accepted cost for the speed/breadth trade, revisit if such a bug is ever found in production.
- **[A nightly-only cadence means up to ~24h of undetected regression]** → Acceptable per the user's explicit cadence choice; still far better than the previous state (locale regressions were only ever caught when someone manually ran the multi-day sweep, which real usage this session shows was never actually completed even once for the full 9-locale set).
- **[GitHub Actions scheduled-workflow reliability]** → GitHub's scheduled workflows are known to occasionally skip a run under high platform load (documented GitHub behavior, not specific to this repo) — a missed night is a minor gap, not a correctness issue, given the next night's run still catches any regression that persists.
- **[Release timing vs. nightly timing]** → If a release is cut hours after the last nightly run but before the next one, very recent commits might not yet be covered by a green nightly result. Mitigation: the updated `localized-release-verification` requirement says to check the *most recent* run "at or near" the candidate's commit, not to assume a run automatically covers today's exact commit — a release owner should use judgment (or trigger `acceptance-suite-nightly.yml` manually via `workflow_dispatch`, which this proposal keeps available) if timing is tight.

## Migration Plan

1. Rename/rewrite `.github/workflows/acceptance-suite-spike.yml` → `.github/workflows/acceptance-suite-nightly.yml`, adding a `schedule` trigger and dropping spike-specific framing from its comments.
2. Update `docs/release/checklist.md`: remove the 9-locale table and ~72-90h estimate, add a line pointing to the nightly Linux CI tier's latest run, and narrow the macOS step to the English-only baseline command.
3. No code changes, no data migration — this is a CI/process change only.

Rollback, if the nightly tier proves unreliable or the coverage trade-off turns out to matter in practice: revert to `localized-release-verification`'s prior manual 9-locale macOS requirement (its exact text is preserved in the archived `2026-09-11-localized-release-verification` change), and either delete or keep `acceptance-suite-nightly.yml` running as a supplementary, non-authoritative signal.
