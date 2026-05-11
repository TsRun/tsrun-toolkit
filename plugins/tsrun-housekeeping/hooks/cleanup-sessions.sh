#!/bin/bash
# Delete sessions created by the autocommit hook.
# Detected by content match (the autocommit prompt). Skip files modified in
# last 5 minutes (likely active sessions). Leaves all other transcripts alone —
# Claude Code's own retention (cleanupPeriodDays) handles age-based cleanup.
[ "$CLAUDE_AUTOCOMMIT" = '1' ] && exit 0

LOG=/tmp/claude-hooks.log
PROJECTS_DIR="$HOME/.claude/projects"
[ -d "$PROJECTS_DIR" ] || exit 0

deleted=0
for dir in "$PROJECTS_DIR"/*/; do
  for f in "$dir"*.jsonl; do
    [ -f "$f" ] || continue
    [ -n "$(find "$f" -mmin -5 2>/dev/null)" ] && continue
    if grep -q "Commit all current changes and push" "$f" 2>/dev/null; then
      rm "$f"
      deleted=$((deleted + 1))
    fi
  done
done

[ "$deleted" -gt 0 ] && echo "[$(date '+%Y-%m-%d %H:%M:%S')] cleanup-sessions: deleted $deleted autocommit sessions" >> "$LOG"
