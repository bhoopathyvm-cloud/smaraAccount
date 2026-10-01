## 1. Enforcement

- [x] 1.1 Add `tool/agent-hooks/format_dart_file.sh` and `format_all_dart.sh`; verify by piping sample hook payloads (edited file gets formatted; the finish check blocks once with exit 2, then not again when `stop_hook_active` is true)
- [x] 1.2 Add `.claude/settings.json` PostToolUse (Edit|Write|MultiEdit) and Stop hooks calling those scripts; verify with `jq -e` on both hook commands
- [x] 1.3 Rewrite `tool/git-hooks/pre-commit` to format and re-stage staged Dart files, refuse partially staged unformatted files, and clear git's hook variables before Flutter; verify with a real commit of an unformatted file inside a git worktree (file committed formatted, `flutter analyze` passes)
- [x] 1.4 Cursor: `.cursor/hooks.json`, `.cursor/rules/code-formatting.mdc`, and `git config core.hooksPath tool/git-hooks` in `.cursor/environment.json`'s install step; verify the JSON parses
- [x] 1.5 Codex, Copilot and shared rules: `AGENTS.md`, `.github/copilot-instructions.md`, `CLAUDE.md`, `CONTRIBUTING.md`; verify by review
- [x] 1.6 Create the GitHub ruleset that requires "Format, analyze, and test" on `main`; verify with `gh api repos/{owner}/{repo}/rules/branches/main` listing the required status check
  <!-- 2026-10-01: ruleset 24324557 "Require Format, analyze, and test on main" is active; `rules/branches/main` lists the required check. -->
