---
name: clean-sessions
description: Delete Claude Code session transcripts (.jsonl) that are older than 5 days OR unnamed (session id not present in any sessions-index.json). Use when the user wants to clean up old conversations or free disk space.
---

Delete Claude Code session transcripts under `~/.claude/projects/*/<sid>.jsonl` that match either:
- last modified more than 5 days ago, OR
- unnamed: session id not listed in any project's `sessions-index.json`.

Files modified within the last 5 minutes are skipped (active session).

## Steps

1. Run the bash block below to **preview** the candidates (no deletion). Show the user the count and the per-project breakdown.
2. Ask the user to confirm before deleting.
3. On confirmation, re-run the same block with `MODE=delete` to perform deletion. Report the number of files deleted and KB freed.

```bash
MODE="${MODE:-preview}"
PROJECTS_DIR="$HOME/.claude/projects"
[ -d "$PROJECTS_DIR" ] || { echo "no projects dir"; exit 0; }

named_ids=$(for d in "$PROJECTS_DIR"/*/; do
  idx="$d/sessions-index.json"
  [ -f "$idx" ] && grep '"sessionId"' "$idx" | sed 's/.*"sessionId": *"//;s/".*//'
done)

count=0; freed=0
for d in "$PROJECTS_DIR"/*/; do
  proj=$(basename "$d")
  proj_count=0
  for f in "$d"*.jsonl; do
    [ -f "$f" ] || continue
    sid=$(basename "$f" .jsonl)
    [ -n "$(find "$f" -mmin -5 2>/dev/null)" ] && continue
    old=$(find "$f" -mtime +5 2>/dev/null)
    unnamed=true
    echo "$named_ids" | grep -q "$sid" && unnamed=false
    if [ -n "$old" ] || [ "$unnamed" = true ]; then
      sz=$(stat -c %s "$f" 2>/dev/null || echo 0)
      reason=""; [ -n "$old" ] && reason="old"; [ "$unnamed" = true ] && reason="${reason:+$reason,}unnamed"
      if [ "$MODE" = "delete" ]; then
        rm "$f"
      else
        echo "  $proj/$sid.jsonl  ($((sz / 1024)) KB, $reason)"
      fi
      count=$((count + 1)); freed=$((freed + sz)); proj_count=$((proj_count + 1))
    fi
  done
  [ "$MODE" = "preview" ] && [ "$proj_count" -gt 0 ] && echo "→ $proj: $proj_count file(s)"
done

if [ "$MODE" = "delete" ]; then
  echo "Deleted $count session(s), freed $((freed / 1024)) KB"
else
  echo ""
  echo "Total: $count file(s), $((freed / 1024)) KB"
fi
```
