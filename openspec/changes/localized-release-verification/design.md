## Context

This proposal follows directly from a conversation that started as "can we run the localized smoke test faster in CI" and, through several rounds of grounding in real numbers, arrived somewhere different: the *smoke* test (a few Dart assertions, no real device) scales beautifully with CI parallelism — a 9-locale run went from ~10 minutes to 4m28s just by raising `max-parallel` (`localized-smoke-parallelism`, already shipped). The *full acceptance suite* (37 real-device GUI tests, `tool/run_acceptance_tests.sh`) does not share that property, for reasons specific to what it actually is:

- Real measured runtime this session: English 10h03m, Japanese 7h58m, Arabic 7h57m — for one locale, one platform, one continuous `flutter test` process (already architected as a single session per run, no redeploy between the 13 groups within it — this already satisfies "one time load, run continuously, no redeploy in between" for a *single* locale; the "per-language" boundary is inherently a new process because each locale needs its own onboarding-language-screen selection at the very start).
- GitHub-hosted Actions runners cap every job at 6 hours, regardless of OS or `max-parallel`. This is a platform limit, not a resource one — parallelism doesn't touch it, because it bounds each individual job's own duration, not the total across many jobs.
- The existing `acceptance-test-suite` spec already requires this tier stay `workflow_dispatch`-free and CI-free entirely (`tool/run_acceptance_tests.sh`'s own spec: "This tier SHALL NOT be invoked by any GitHub Actions workflow... SHALL NOT be part of the required flutter-ci.yml pull request gate").
- **Correction from an earlier draft of this document**: it previously claimed Windows wasn't a supported build target and that iOS/Android would need the same from-scratch discovery process macOS did. Both were wrong. `windows/`, `ios/`, and `android/` project directories all already exist; only `linux/` is genuinely missing (tracked separately in `add-linux-desktop-support`). iOS and Android are already-supported *device* targets for `tool/run_acceptance_tests.sh -d <device>` (the existing spec explicitly names "a macOS build, a booted iOS Simulator, or a running Android emulator/device"), and the user has separately run tests on them successfully outside this session. `flutter_secure_storage`'s iOS Keychain / Android Keystore backends are, if anything, more mature and commonly-used than macOS's ad-hoc-signing legacy-Keychain fallback (the specific thing that needed a workaround this session) — there's no basis for assuming they need *more* discovery work, possibly less.
- What's actually true: only macOS has been used for a *multi-locale* acceptance run so far (English/Japanese/Arabic, this session). iOS, Android, and Windows are real, working platforms with no known reason to expect problems, but no multi-locale timing data exists for them yet either — that data gap, not a support gap, is what "macOS only for this proposal" is actually based on (see Decision 1, corrected below).

Given all of that, the practical, buildable version of "check localization once before release, the way we check platforms" is: keep it manual, keep it to one already-proven platform, and be honest about the wall-clock cost rather than trying to engineer it away with infrastructure this app doesn't have yet.

## Goals / Non-Goals

**Goals:**
- A defined, repeatable, documented pre-release step: run the full acceptance suite once per locale in the curated set, on macOS, and require it to pass before a release ships.
- Make the real cost of this (multi-day, sequential, on one machine, today) fully visible and explicit, not hidden inside a script nobody reads the runtime of.

**Non-Goals:**
- Automating this in CI, on any OS. Ruled out above for concrete, load-bearing reasons (6h job cap; existing spec; missing platform support), not a stylistic preference.
- Growing the locale set beyond today's curated 9 as part of this change. A real, separate decision (see Decisions below).
- Adding Windows, iOS, or Android to this rotation, and adding Linux at all (tracked separately in `add-linux-desktop-support`, not part of this proposal). Each already-working platform added to the multi-locale rotation adds its own multi-hour-per-locale cost to every pre-release pass — a real, separate decision each time, not a default yes just because the platform itself already works.

## Decisions

1. **macOS only for this proposal, not because other platforms need proving — because no timing/process data exists for them yet.** macOS is the only platform this suite has been run against for more than one locale, this session, so it's the only platform where the real per-locale cost and process are actually known. iOS, Android, and Windows are legitimate, already-working platforms (not second-class the way Linux currently is) — extending this rotation to them is a real, buildable next step, but it's an *additive scope* decision (each platform roughly doubles or triples this step's total wall-clock cost) that deserves its own explicit "yes, let's do this" rather than being bundled into the first version of the process.

2. **Locale set stays at the curated 9, not "all 43."** The team's own earlier design (`acceptance-tests-multi-locale`) chose these 9 to maximize bug-catching leverage per locale added — RTL, CJK/BIP39-wordlist, a long-compound-word stress locale, a lower-review-confidence translation. Running all 43 sequentially on one machine is `43 × ~8.5h ≈ 15 days` — not a "before every release" cadence, it's a "maybe twice a year" cadence. Two paths exist if broader coverage is wanted later, both deliberately deferred rather than decided here:
   - **Grow the set slowly**, locale by locale, only when a specific one seems worth the added ~8-10h per pass (e.g., a bug report from a language outside the curated 9).
   - **Parallelize across multiple real Macs** (several physical/cloud Mac instances running different locales simultaneously) — genuinely effective here, unlike CI parallelism, because each machine runs a full, uncapped session with no 6-hour ceiling. This requires either multiple developer machines volunteered for a pre-release day, or paid cloud Mac infrastructure (MacStadium, AWS EC2 Mac instances, etc.) — a real cost/ops decision, not a config change, and explicitly out of scope for this proposal.

3. **A documented checklist step, not new tooling.** `tool/run_localized_acceptance_tests.sh -d macos` already does exactly what's needed — loop the curated set, run the full suite per locale, report a pass/fail summary. The only real gap is that nothing *requires* running it before a release, or tells a future contributor it exists. This proposal adds a new `docs/release-checklist.md` (or extends an existing release doc if one exists under a different name — check `docs/` before creating) naming this as a required step, not new scripts.

## Risks / Trade-offs

- **[Multi-day pre-release cadence]** → This is the core, accepted trade-off, not a bug to fix: real per-locale GUI assurance costs real wall-clock time on real hardware, the same way the macOS-only acceptance suite already costs ~8-10 hours per *platform* run today. Mitigation: this is a *release* gate, not a *per-PR* gate, so it runs far less often than CI.
- **[The checklist step gets skipped under release pressure]** → Mitigation: make it a named, visible line item in the release checklist doc, not an unwritten expectation; a missing step in a written checklist is a much easier thing to notice and push back on than a missing step nobody documented.
- **[9 locales create false confidence about the other 34]** → Mitigation: state this plainly in the checklist doc itself — this step verifies the curated 9, not "all languages," and the doc should say so rather than imply broader coverage than it has.

## Migration Plan

N/A — this adds a documentation/process artifact and a checklist requirement; no code or CI changes to roll back. If the multi-day cost proves unworkable in practice, the mitigation is dropping locales from the curated set or reducing release frequency of this specific check, not reverting code.

## Open Questions

- Where should the release checklist live — a new `docs/release-checklist.md`, or folded into an existing doc (`CONTEXT.md`, `docs/agents/`)? Check `docs/` structure during `/opsx:apply` before creating a new file.
- Once this has run for a few real releases, and once Linux exists (`add-linux-desktop-support`), which platform(s) should join the rotation next, and in what order — likely a separate proposal per platform added, given each one adds its own multi-hour-per-locale cost to every pre-release pass.

## Implementation findings (2026-09-10)

- Checklist location: `docs/release/checklist.md`, linked from the Android
  keystore guide and `CONTRIBUTING.md`, with links back to both.
- Re-read both acceptance scripts and the curated locale fixture list. The
  documented command passes `-d macos`, supplies no group filter, runs all
  nine locales sequentially, continues after failures, and returns nonzero
  if any locale fails. The multi-day suite was not run for this docs change.
- Task 2.2 remains pending: a second person must follow the checklist
  literally, or its author must perform a fresh read a day later. Same-session
  proofreading does not satisfy that requirement.
