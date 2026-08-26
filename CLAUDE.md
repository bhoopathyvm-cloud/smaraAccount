# Working Conventions

- Never commit directly to `main`. Every change gets its own git branch —
  name it after the OpenSpec change it implements (e.g.
  `core-ledger-single-account`, `ledger-integrity-signing`) — and commits
  go there.
- After each big refactor (e.g. splitting/moving a repository, changing DI
  wiring, reshaping a widely-used module), run the full acceptance/
  integration suite — `tool/run_acceptance_tests.sh -d macos` — not just
  `flutter analyze`/`flutter test`. Unit and widget tests mock repositories
  and DI wiring, so a wiring mistake (e.g. a provider still passing the old
  dependency, a mocked method that silently diverged from the real one) can
  pass `flutter test` while actually breaking the app end-to-end. Do this
  before marking the refactor's tasks complete, not only at the very end of
  the whole change.

## Agent skills

### Issue tracker

Issues live in GitHub Issues (bhoopathyvm-cloud/smaraAccount), via the `gh` CLI. See `docs/agents/issue-tracker.md`.

### Triage labels

Default five canonical labels (needs-triage, needs-info, ready-for-agent, ready-for-human, wontfix). See `docs/agents/triage-labels.md`.

### Domain docs

Single-context (root `CONTEXT.md` + `docs/adr/`). See `docs/agents/domain.md`.

### Architecture deepening

Conventions for `extract-`/`deepen-`/`unify-`/`finish-` OpenSpec changes (seam placement, naming, DI wiring, sequencing, testing). See `docs/agents/architecture-deepening.md` and ADR 0002.
