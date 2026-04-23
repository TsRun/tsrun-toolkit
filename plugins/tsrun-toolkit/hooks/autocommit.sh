#!/bin/bash
[ "$CLAUDE_AUTOCOMMIT" = '1' ] && exit 0

LOG=/tmp/claude-hooks.log

commit_and_push() {
  local dir="$1"
  cd "$dir" || return
  git rev-parse --git-dir >/dev/null 2>&1 || return
  [ -z "$(git status --porcelain)" ] && { echo "[$(date '+%Y-%m-%d %H:%M:%S')] autocommit: clean ($dir)" >> "$LOG"; return; }
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] autocommit: dirty, launching git agent ($dir)" >> "$LOG"
  CLAUDE_AUTOCOMMIT=1 claude -p 'Commit all current changes and push. Analyze the diff to write a proper commit message.' --agent git >>"$LOG" 2>&1
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] autocommit: done ($dir)" >> "$LOG"
}

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Stop hook: autocommit start (dir=$CLAUDE_PROJECT_DIR)" >> "$LOG"

# Main project dir
commit_and_push "$CLAUDE_PROJECT_DIR"

# All worktrees
cd "$CLAUDE_PROJECT_DIR" 2>/dev/null && git rev-parse --git-dir >/dev/null 2>&1 && {
  git worktree list --porcelain | grep '^worktree ' | sed 's/^worktree //' | while read -r wt; do
    [ "$wt" = "$CLAUDE_PROJECT_DIR" ] && continue
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] autocommit: checking worktree $wt" >> "$LOG"
    commit_and_push "$wt"
  done
}

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Stop hook: autocommit finished" >> "$LOG"
