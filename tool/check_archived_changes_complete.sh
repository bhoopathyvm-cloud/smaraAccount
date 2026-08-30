#!/bin/sh
# Mechanical gate for the "only archive fully-complete changes" rule
# (see CLAUDE.md and the openspec-archive-change skill).
#
# Fails if a change that is NEWLY moved into openspec/changes/archive/ in this
# diff still has incomplete tasks in its tasks.md — an unchecked `- [ ]` or a
# partial `- [~]`. It is scoped to changes archived relative to <base>, so
# pre-existing historical archives (which may legitimately contain unchecked
# boxes) are never re-checked.
#
# Usage:
#   tool/check_archived_changes_complete.sh [base-ref]
#     base-ref defaults to origin/main.

set -eu

base="${1:-origin/main}"
archive_dir="openspec/changes/archive"

# Immediate child dirs of the archive now (HEAD) and at the base ref.
current=$(git ls-tree --name-only HEAD "$archive_dir/" 2>/dev/null || true)
if git rev-parse --verify --quiet "$base" >/dev/null 2>&1; then
  baseline=$(git ls-tree --name-only "$base" "$archive_dir/" 2>/dev/null || true)
else
  echo "warning: base ref '$base' not found; treating all archived changes as new." >&2
  baseline=""
fi

status=0
for dir in $current; do
  # Skip anything that already existed at the base ref (not newly archived).
  if [ -n "$baseline" ] && printf '%s\n' "$baseline" | grep -qxF "$dir"; then
    continue
  fi
  tasks="$dir/tasks.md"
  [ -f "$tasks" ] || continue
  incomplete=$(grep -nE '^[[:space:]]*- \[( |~)\]' "$tasks" || true)
  if [ -n "$incomplete" ]; then
    echo "ERROR: newly-archived change has incomplete tasks: $tasks" >&2
    printf '%s\n' "$incomplete" | sed 's/^/    /' >&2
    status=1
  fi
done

if [ "$status" -ne 0 ]; then
  echo >&2
  echo "A change may only be archived once every task in its tasks.md is '- [x]'." >&2
  echo "Move the offending change back to openspec/changes/<name>/ (out of archive/)" >&2
  echo "until its tasks are complete, or finish and check off the tasks listed above." >&2
fi

exit "$status"
