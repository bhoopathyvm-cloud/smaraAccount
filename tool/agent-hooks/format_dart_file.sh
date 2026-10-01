#!/bin/sh
# Formats one Dart file right after an AI agent edits it.
#
# Used by the Claude Code PostToolUse hook (.claude/settings.json) and the
# Cursor afterFileEdit hook (.cursor/hooks.json). The edited path comes
# either as the first argument or inside the hook's JSON on stdin
# ("file_path", or "tool_input"/"tool_response" -> "file_path"/"filePath").
# Non-Dart files and generated files are ignored. Never fails the agent:
# formatting problems are reported, and the commit and CI gates catch them.

path="${1:-}"
if [ -z "$path" ]; then
  payload=$(cat)
  path=$(printf '%s' "$payload" \
    | grep -o -E '"(file_path|filePath)"[[:space:]]*:[[:space:]]*"[^"]*"' \
    | head -n 1 \
    | sed -E 's/.*:[[:space:]]*"([^"]*)"/\1/')
fi

case "$path" in
  *.g.dart|*.mocks.dart|*/l10n/generated/*) exit 0 ;;
  *.dart) ;;
  *) exit 0 ;;
esac

[ -f "$path" ] || exit 0
dart format "$path" >/dev/null 2>&1 || echo "dart format could not format $path" >&2
exit 0
