#!/usr/bin/env bash
# Delete Claude Code session transcripts that are older than 5 days OR
# whose session id is not present in any project's sessions-index.json.
#
# Active-session protection (any of these makes a transcript untouchable):
#   - mtime within the last 30 minutes
#   - session id appears as `--resume <sid>` in a running claude process
#   - transcript file is currently held open by any running process
#
# Usage:  clean-sessions.sh             # preview only
#         clean-sessions.sh --delete    # actually delete

set -u
mode="preview"
[ "${1:-}" = "--delete" ] && mode="delete"

projects_dir="$HOME/.claude/projects"
[ -d "$projects_dir" ] || { echo "no projects dir"; exit 0; }

named_ids=$(
  find "$projects_dir" -mindepth 2 -maxdepth 2 -name sessions-index.json -type f 2>/dev/null \
    | xargs -r grep -h '"sessionId"' 2>/dev/null \
    | sed 's/.*"sessionId": *"//;s/".*//'
)

active_sids=$(
  pgrep -af claude 2>/dev/null \
    | grep -oE -- '--resume[ =][a-f0-9-]{36}' \
    | sed 's/--resume[ =]//'
)

open_jsonls=$(
  find /proc/*/fd -lname '*.jsonl' 2>/dev/null \
    | xargs -r readlink 2>/dev/null \
    | sort -u
)

count=0
freed=0
declare -A per_project

while IFS= read -r f; do
  [ -f "$f" ] || continue
  d=$(dirname "$f")
  proj=$(basename "$d")
  sid=$(basename "$f" .jsonl)

  # Active-session guards
  [ -n "$(find "$f" -mmin -30 2>/dev/null)" ] && continue
  if [ -n "$active_sids" ] && printf '%s\n' "$active_sids" | grep -qx "$sid"; then
    continue
  fi
  if [ -n "$open_jsonls" ] && printf '%s\n' "$open_jsonls" | grep -qxF "$f"; then
    continue
  fi

  old=$(find "$f" -mtime +5 2>/dev/null)
  unnamed=true
  if [ -n "$named_ids" ] && printf '%s\n' "$named_ids" | grep -qx "$sid"; then
    unnamed=false
  fi

  if [ -n "$old" ] || [ "$unnamed" = true ]; then
    sz=$(stat -c %s "$f" 2>/dev/null || echo 0)
    reason=""
    [ -n "$old" ] && reason="old"
    [ "$unnamed" = true ] && reason="${reason:+$reason,}unnamed"
    if [ "$mode" = "delete" ]; then
      rm "$f"
    else
      printf '  %s/%s.jsonl  (%d KB, %s)\n' "$proj" "$sid" "$((sz / 1024))" "$reason"
    fi
    count=$((count + 1))
    freed=$((freed + sz))
    per_project[$proj]=$((${per_project[$proj]:-0} + 1))
  fi
done < <(find "$projects_dir" -mindepth 2 -maxdepth 2 -name '*.jsonl' -type f 2>/dev/null)

if [ "$mode" = "delete" ]; then
  printf 'Deleted %d session(s), freed %d KB\n' "$count" "$((freed / 1024))"
else
  echo
  for p in "${!per_project[@]}"; do
    printf '→ %s: %d file(s)\n' "$p" "${per_project[$p]}"
  done
  echo
  printf 'Total: %d file(s), %d KB\n' "$count" "$((freed / 1024))"
fi
