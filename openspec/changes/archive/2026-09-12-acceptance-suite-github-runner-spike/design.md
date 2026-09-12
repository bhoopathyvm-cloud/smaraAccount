## Context

`acceptance-test-suite`'s manual-only requirement was written from reasoning, not measurement: GitHub-hosted runners cap every job at 6 hours regardless of OS, and the suite's own measured per-locale runtime (7h57m-10h03m) exceeds that on macOS, so CI seemed ruled out by definition. That reasoning is specific to the macOS target — the same suite has never been run at full scale against the Linux desktop target added by `add-linux-desktop-support`. The only Linux timing data that exists is 2 of 13 groups (`onboarding`, `identity_restore`) completing in well under a minute combined during that change's own manual smoke check, dramatically faster than their macOS equivalents. Whether that holds for all 13 groups, or whether some group behaves very differently under Xvfb on Linux, is unknown until tried.

The user asked to run this on the `ubuntu-slim` runner already used by `localized-smoke.yml`, against the Linux target (`-d linux`), across every supported locale, treating the outcome — whatever it is — as real data rather than an assumption.

## Goals / Non-Goals

**Goals:**
- Get real data: does `tool/run_acceptance_tests.sh -d linux -l <locale>` complete within 6 hours on the `ubuntu-slim` GitHub-hosted runner, for any locale — and if so, how close to the boundary?
- Learn whether the full 37-test suite on Linux behaves like the 2 groups already spot-checked (fast) or surfaces a group that behaves very differently under Xvfb.
- Keep the exception this requires as narrow and reversible as possible, so either outcome is trivial to close out (delete the workflow, revert the spec exception; or keep both and open a follow-up).

**Non-Goals:**
- Making this a permanent CI tier, however the experiment turns out. A positive result here would be its own follow-up decision (which locales, what cadence, whether/how it relates to the existing macOS-only manual pre-release process), not an automatic outcome of this change.
- A self-hosted runner, or the macOS target. Both explicitly set aside in favor of trying the cheaper, already-proven `ubuntu-slim` + Linux path first.
- Fixing anything the spike finds beyond what's needed to get a real result. A locale-specific Linux bug in some group is itself a useful, reportable finding — not a debugging obligation this change takes on, unless it's blocking every locale from producing any signal at all.

## Decisions

1. **All 43 locales in one matrix, `fail-fast: false`, rather than one locale first.** The user explicitly asked to try all languages now rather than a single pilot locale. `fail-fast: false` ensures one locale's timeout or failure doesn't cancel the others mid-flight, so the run produces a complete picture rather than stopping at the first failure.
2. **`timeout-minutes: 360` set explicitly, matching GitHub's own hard ceiling for hosted runners.** This is already the platform maximum and cannot be raised, but setting it explicitly documents the intent in the workflow file rather than relying on an implicit default.
3. **No new group filter — full 37-test suite per locale, matching the developer-invoked script's existing behavior.** Running a smaller subset would answer a different, easier question than the one actually asked, and would leave 11 of 13 groups still completely untested on Linux.
4. **Reuse `linux-desktop.yml`'s exact Xvfb/D-Bus/keyring setup, not a new pattern.** That sequence is already proven working in this repo (`add-linux-desktop-support` tasks 3.1-3.2) — no reason to re-derive it.
5. **Drop `curated_locale_smoke_test.dart`'s `kCuratedAcceptanceLocales` assertion.** `localized-smoke.yml`'s matrix was separately grown to all 43 locales (the user's own edit, same session); that test's stricter curated-only check would otherwise fail 34 of those 43 jobs on an assertion unrelated to what the test actually verifies (ARB/localization structural sanity, which only ever needed `kSupportedLocaleTags` membership).

## Risks / Trade-offs

- **[Some Linux-specific group failure blocks every locale identically]** → If every locale fails at the same group for the same reason, that's a single, cheap-to-diagnose finding (not 43 independent failures to chase) — check the first failing job's log before assuming anything about the rest.
- **[Linux hosted-runner concurrency for this account is unverified]** → The run itself will reveal the real number, the same empirical approach `localized-smoke-parallelism` used for Linux runner concurrency generally.
- **[A timed-out job leaves no artifact/log evidence of partial progress by default]** → Mitigation: the workflow step's own `flutter test` output streams to the job log regardless of whether the job is later killed by the timeout, so however far it got before the 6h cutoff is still visible in the log.
- **[This is a genuine, if narrow, loosening of a previously firm prohibition]** → Mitigation: the spec exception's own scenario names the specific workflow file and ties the exception to that one purpose, so it reads clearly as bounded rather than as a quiet general reversal.

## Findings (first dispatch, 2026-09-12)

The first dispatch used `ubuntu-slim` (matching `localized-smoke.yml`'s runner, per the user's direction). Every one of the 43 jobs' acceptance-suite step was cancelled 8.3-12.4 minutes after it started (average 11.4 min), regardless of each job's own absolute start time — a per-job ceiling intrinsic to `ubuntu-slim` reclaiming/preempting the runner, not this workflow's `timeout-minutes: 360` (which only bounds the job from GitHub Actions' side and cannot override the runner's own infrastructure limit). This is consistent with `localized-smoke.yml`'s own pre-existing `timeout-minutes: 15`, which now reads as already having been tuned to this runner class's real ceiling.

Before being cut off, Punjabi (`pa`) passed 21 of 37 tests (~5 of 13 groups: `currency_transfers`, `group_archive`, `home_and_lock`, `identity_restore`, `investment_holdings`) in ~10.5 minutes, zero failures. Extrapolating, the full suite likely finishes in roughly 20 minutes on Linux — the blocker was entirely the runner class, not the suite's real Linux runtime. Switched `runs-on` to `ubuntu-latest` (no known reclaim behavior, already proven for multi-hour jobs via `linux-desktop.yml`) for the second dispatch.

## Findings (second dispatch, ubuntu-latest, 2026-09-12)

[Run 34681112956](https://github.com/bhoopathyvm-cloud/smaraAccount/actions/runs/34681112956) fully completed — the core question is answered: **yes, the full 37-test acceptance suite fits comfortably within GitHub's 6-hour hosted-runner cap when run against the Linux target.** All 43 jobs finished in 10.4-12.2 minutes each (avg 11.0 min total, including setup) — roughly 40-50x faster than the measured 8-10h macOS runtime, not just under the cap but under it by a huge margin (~30x headroom even against the 6h ceiling).

37 of 43 locales passed clean (37/37 tests each). 6 failed, with failures scattered across different tests rather than one shared cause:
- `as`, `bn`, `mr`, `ne`: all failed the same single test, `investment_holdings employer-match buy with lock-until blocks selling the locked unit`, with the same `Bad state: No element` exception.
- `ks`: failed 2 `ledger_backup` restore tests.
- `mni`: failed 2 `currency_transfers` tests and 1 `ledger_backup` test.

This pattern — different tests failing for different locales, all with a generic "expected widget/element not present yet" exception shape, affecting only 6 of 43 otherwise-identical concurrent runs — initially read as CI-concurrency-induced flakiness. **Confirmed otherwise**: re-running just these 6 locales on a throwaway branch (matrix narrowed to `as, bn, ks, mni, mr, ne`, [run 34682599778](https://github.com/bhoopathyvm-cloud/smaraAccount/actions/runs/34682599778), 6 jobs instead of 43 so concurrency contention is far lower) reproduced the **exact same failures, at the exact same tests, with the exact same pass/fail counts**, for all 6. These are real, deterministic, locale-specific bugs, not flakiness.

Two distinct root causes:
1. **`as`, `bn`, `mr`, `ne`** — identical failure: `investment_holdings employer-match buy with lock-until blocks selling the locked unit`, `WidgetController.tap()`'s internal `_maybeViewOf` throws `Bad state: No element` inside `recordNonCashBuyThroughGui` (`acceptance_test.dart:1632`). This is a Flutter-test-framework view-resolution error, not a text-matching or translation issue — something about the widget tree state at that exact tap makes `tap()` unable to resolve its ancestor `View`.
2. **`ks`, `mni`** — `ledger_backup`'s restore-dialog flow: `setState() called after dispose()` in `SettingsView._showRestoreBackupDialog`, plus a finder assertion failure ("Expected: no matching candidates"); `mni` additionally fails 2 `currency_transfers` tests.

Both look like genuine app or test-harness bugs specific to these locales (script/layout interaction, or a locale-dependent timing difference under Xvfb), not something this spike's own scope covers fixing (per Non-Goals: fixing spike findings is out of scope unless it blocks getting any signal at all — it doesn't, since 37/43 locales already produce a clean result). Worth a dedicated follow-up investigation.

## Findings (all 6 failures resolved, 2026-09-12)

The user asked to fix these rather than leave them as a follow-up. All 6 turned out to be **three distinct root causes**, none of them the flakiness or view-resolution mystery they first appeared to be, and none requiring production-code changes:

1. **`as`, `bn`, `mr`, `ne`**: Flutter's calendar day picker renders day numbers via `MaterialLocalizations.formatDecimal`, which uses `intl.NumberFormat.decimalPattern(locale)` — several locales' default numbering systems aren't Western digits (day "15" renders as "১৫" in Bengali/Assamese, "१५" in Devanagari-based Marathi/Nepali). The test hardcoded `find.text('15')`. Fixed with a `localizedDay()` helper reproducing Flutter's own formatting call. Confirmed on [run 34684351188](https://github.com/bhoopathyvm-cloud/smaraAccount/actions/runs/34684351188): all 4 pass 37/37.
2. **`mni`**: a translation collision — `app_mni.arb`'s `editGroup` was byte-identical to `createGroup`, so a tooltip-based tap ambiguously matched 6 widgets. Fixed by reusing an already-attested "modify" verb from `renameAccount` in the same file. Confirmed on [run 34685855699](https://github.com/bhoopathyvm-cloud/smaraAccount/actions/runs/34685855699): 37/37.
3. **`ks`**: a second, independent translation collision — `app_ks.arb`'s `backupRestored` was byte-identical to `actionRestoreBackup`, causing the acceptance test's success-check to match the wrong (stale, still-visible) button and race ahead of a real async operation still in flight, which later crashed on a disposed dialog. An initial hypothesis (a `tapReliably`/`isBusy` double-invocation race in production code) looked plausible from reading the code in isolation but was wrong — confirmed by finding the actual translation collision and fixing it directly. Confirmed on [run 34687414493](https://github.com/bhoopathyvm-cloud/smaraAccount/actions/runs/34687414493): 37/37.

A general lesson worth carrying forward: three of six failures across this spike were the *same underlying bug class* (an AI-drafted locale pack accidentally giving two different UI concepts an identical translated string), already seen once before this spike in this exact codebase (the Japanese `actionHide`/`hiddenLabel` collision from `acceptance-tests-multi-locale`). A systematic duplicate-value scan across each locale's ARB file, at least for the string pairs an acceptance test actually disambiguates by, would likely catch this class of bug before a full CI run does — worth considering as a cheap addition to a future locale-pack change, though out of scope to build here.

**All 43 locales are now confirmed clean, each individually verified against the real Linux CI runner** — not a full-matrix re-run yet, but every locale that ever failed has since passed on its own, and the 37 that passed on the first full run were never in question.

## Migration Plan

If the spike confirms CI is infeasible even on Linux: delete `.github/workflows/acceptance-suite-spike.yml` and revert the spec exception in a follow-up change, restoring the original absolute prohibition. If some or all locales genuinely complete within 6h: that becomes its own future proposal (whether this replaces, supplements, or has no relation to the existing macOS-only manual pre-release process) — this change does not commit to that outcome.
