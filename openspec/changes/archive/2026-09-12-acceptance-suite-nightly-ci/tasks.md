## 1. Workflow

- [x] 1.1 Renamed `.github/workflows/acceptance-suite-spike.yml` to `.github/workflows/acceptance-suite-nightly.yml` (`git mv`), updated the workflow `name:`, job id (`acceptance-spike` → `acceptance-nightly`), and header comment to drop "spike"/"feasibility experiment" framing now that this is permanent.
- [x] 1.2 Added `schedule: cron: "0 3 * * *"` (nightly, 3 AM UTC) alongside `workflow_dispatch`. Confirmed the YAML parses (`python3 -c "import yaml; yaml.safe_load(...)"`). Also fixed a real correctness gap found while doing this: `if: github.actor == github.repository_owner` behaves fragilely on a `schedule` trigger (`github.actor` there is whoever last edited the cron line, not a real "who triggered this"). Changed to `if: github.event_name == 'schedule' || github.actor == github.repository_owner` — scheduled runs are always the repo's own cron and are safe unconditionally; manual `workflow_dispatch` keeps the owner gate.
- [x] 1.3 Confirmed the matrix (43 locales), runner (`ubuntu-latest`), Xvfb/D-Bus/keyring setup, and `tool/run_acceptance_tests.sh -d linux -l ${{ matrix.locale }}` step are otherwise unchanged from the proven spike workflow.

## 2. Docs

- [x] 2.1 Rewrote `docs/release/checklist.md`: removed the 9-locale table and ~72-90h cost estimate; added a "Required: nightly Linux locale-regression check" section directing the release owner to find the most recent `acceptance-suite-nightly.yml` run at or near the release candidate's commit and confirm all 43 locale jobs passed, with the same hold-the-release/document-exceptions language the old gate had.
- [x] 2.2 Narrowed the checklist's macOS step to `tool/run_acceptance_tests.sh -d macos` (no locale flag) under "Required: macOS baseline check" — states plainly it's English only, verifying platform behavior not locale variation, and reduces the reserved-time estimate from 72-90h to the single-run ~8-10h.
- [x] 2.3 Included in the nightly-check section itself (not a separate note): "If the last run predates changes that could plausibly affect localization or the acceptance suite itself, dispatch it manually (`workflow_dispatch`, repository-owner only) against the candidate commit rather than relying on a stale result." Verified no other doc (`CONTRIBUTING.md`, `android-upload-keystore.md`) references the old 9-locale table, cost estimate, or `run_localized_acceptance_tests.sh` — only `checklist.md` needed updating, and `android-upload-keystore.md`'s cross-link to it still resolves (same filename).

## 3. Verify

- [x] 3.1 Dispatched the renamed/scheduled workflow after merge: [run 34693977093](https://github.com/bhoopathyvm-cloud/smaraAccount/actions/runs/34693977093). All 43 locales pass 37/37 clean — the rename didn't break anything.
- [x] 3.2 Confirmed the `schedule` trigger is registered: `gh api repos/.../actions/workflows` shows the workflow (`Acceptance Suite Nightly`, `.github/workflows/acceptance-suite-nightly.yml`) with `state: "active"` on the default branch. The first actual automatic firing (next 3 AM UTC) hasn't happened yet as of this check — registration is confirmed, the schedule itself is not yet independently observed firing on its own.
- [x] 3.3 `flutter analyze`: no issues. `flutter test`: 904/904 passed — confirmed no application code changes affected anything.
