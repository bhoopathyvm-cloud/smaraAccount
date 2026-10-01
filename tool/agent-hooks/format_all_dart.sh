#!/bin/sh
# Final formatting pass when an AI agent finishes its turn.
#
# Used by the Claude Code Stop hook (.claude/settings.json) and the Cursor
# stop hook (.cursor/hooks.json). Formats every Dart file in the repository.
# If that changed anything, it exits 2 with a message so a Claude Code agent
# is sent back to review and commit the formatted files instead of stopping.
# When Claude Code says the stop hook already ran once this turn
# ("stop_hook_active": true), it only formats and never blocks again, so it
# cannot loop.

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
cd "$repo_root" || exit 0

payload=$(cat 2>/dev/null || true)
case "$payload" in
  *'"stop_hook_active"'*true*) already_blocked=1 ;;
  *) already_blocked=0 ;;
esac

if dart format --output=none --set-exit-if-changed . >/dev/null 2>&1; then
  exit 0
fi

changed=$(dart format . 2>/dev/null | grep '^Formatted ' | grep -v ' 0 changed' || true)
if [ "$already_blocked" -eq 1 ]; then
  exit 0
fi
echo "dart format reformatted files before you finished (${changed:-see git status}). Review them with 'git status' and include them in your commit; CI rejects unformatted code." >&2
exit 2
