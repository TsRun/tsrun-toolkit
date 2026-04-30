#!/bin/bash
# Delete sessions created by the autocommit hook (and other unnamed sessions).
# Skip files modified in last 5 minutes (likely active sessions).
[ "$CLAUDE_AUTOCOMMIT" = '1' ] && exit 0

LOG=/tmp/claude-hooks.log
PROJECTS_DIR="$HOME/.claude/projects"
[ -d "$PROJECTS_DIR" ] || exit 0

# Collect all named session IDs
named_ids=$(for dir in "$PROJECTS_DIR"/*/; do
  idx="$dir/sessions-index.json"
  [ -f "$idx" ] && grep '"sessionId"' "$idx" | sed 's/.*"sessionId": *"//;s/".*//'
done)

deleted=0
for dir in "$PROJECTS_DIR"/*/; do
  for f in "$dir"*.jsonl; do
    [ -f "$f" ] || continue
    sid=$(basename "$f" .jsonl)
    # Skip recently modified (active sessions)
    [ -n "$(find "$f" -mmin -5 2>/dev/null)" ] && continue
    # Delete if it's an autocommit session (created by the git agent prompt)
    if grep -q "Commit all current changes and push" "$f" 2>/dev/null; then
      rm "$f"
      deleted=$((deleted + 1))
      continue
    fi
    # Delete if unnamed
    if ! echo "$named_ids" | grep -q "$sid"; then
      rm "$f"
      deleted=$((deleted + 1))
    fi
  done
done

[ "$deleted" -gt 0 ] && echo "[$(date '+%Y-%m-%d %H:%M:%S')] cleanup-sessions: deleted $deleted sessions" >> "$LOG"
