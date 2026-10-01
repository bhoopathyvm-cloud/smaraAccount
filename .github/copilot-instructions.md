# Instructions for GitHub Copilot

Follow the project rules in [CLAUDE.md](../CLAUDE.md). In particular:

- **Code formatting is mandatory.** Code you write or suggest must already
  be `dart format`-formatted and pass `flutter analyze`. CI's "Format,
  analyze, and test" is a required check on `main`.
- Never suggest committing with `--no-verify`.
- Never hand-edit generated files (`*.g.dart`, `*.mocks.dart`,
  `lib/l10n/generated/`).
