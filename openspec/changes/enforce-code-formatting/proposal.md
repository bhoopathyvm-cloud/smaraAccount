## Why

Several AI coding agents (Claude Code, Cursor cloud agents, Codex) commit to this repository. Unformatted code reached `main` twice in one day: #212 merged while its "Format, analyze, and test" check was failing, and later commits added an analyzer warning. Nothing forced formatting. `main` has no required status checks, the pre-commit hook failed inside git worktrees (so agents bypassed it with `--no-verify`), and only Claude read the project rules.

## What Changes

- **Required CI check on `main`:** a repository ruleset makes "Format, analyze, and test" a required status check, so no pull request from any agent or person can merge while it fails.
- **Claude Code hooks** (`.claude/settings.json`, committed):
  - after every Edit/Write, format the edited Dart file;
  - before finishing, format the whole tree, and send the agent back once to commit anything that changed.
- **Pre-commit hook** (`tool/git-hooks/pre-commit`):
  - formats staged Dart files and re-stages them, refusing only when a file also has unstaged changes;
  - fixed for git worktrees: Flutter misread its own version because git's hook variables (`GIT_DIR` and others) pointed its SDK check at this repository.
- **Other agents:**
  - **Cursor:** `.cursor/hooks.json` with the same two scripts, an always-applied rule (`.cursor/rules/code-formatting.mdc`), and git hooks enabled in the cloud-agent install step (`.cursor/environment.json`).
  - **Codex:** a formatting section in `AGENTS.md`.
  - **GitHub Copilot:** `.github/copilot-instructions.md`.
  - **All:** a shared rule in `CLAUDE.md` and a note in `CONTRIBUTING.md`.
- Shared hook scripts live in `tool/agent-hooks/`.

## Capabilities

### New Capabilities
<!-- none -->

### Modified Capabilities
<!-- none: tooling and contributor process only; no app behavior changes -->

## Impact

Repository tooling, agent configuration and contributor docs only. The app's behavior is unchanged. The ruleset is a GitHub repository setting, outside the code.
