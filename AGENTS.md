# Project instructions

Before starting work in this repository, read and follow
[CLAUDE.md](CLAUDE.md) in full. It is the shared source of project working
conventions for Codex and Claude, including branching, refactor verification,
and OpenSpec completion and archival rules.

When a task involves issue tracking, triage labels, domain documentation, or
architecture deepening, also read the corresponding document linked from
CLAUDE.md before working in that area.

Keep shared project rules in CLAUDE.md so both assistants receive the same
updates. Reserve AGENTS.md for Codex-specific instructions only when needed.

## Codex: code formatting

Codex has no editor hooks in this repository, so do the formatting step
yourself: before every commit run `dart format .` and `flutter analyze` and
fix what they report, and never commit with `--no-verify` (the pre-commit
hook formats staged Dart files; enable it with
`git config core.hooksPath tool/git-hooks`). The full rule is in CLAUDE.md,
"Code formatting is mandatory".
