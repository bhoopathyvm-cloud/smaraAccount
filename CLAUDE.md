# Working Conventions

- Never commit directly to `main`. Every change gets its own git branch —
  name it after the OpenSpec change it implements (e.g.
  `core-ledger-single-account`, `ledger-integrity-signing`) — and commits
  go there.

## Agent skills

### Issue tracker

Issues live in GitHub Issues (bhoopathyvm-cloud/smaraAccount), via the `gh` CLI. See `docs/agents/issue-tracker.md`.

### Triage labels

Default five canonical labels (needs-triage, needs-info, ready-for-agent, ready-for-human, wontfix). See `docs/agents/triage-labels.md`.

### Domain docs

Single-context (root `CONTEXT.md` + `docs/adr/`). See `docs/agents/domain.md`.
