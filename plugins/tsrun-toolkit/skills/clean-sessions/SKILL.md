---
name: clean-sessions
description: Delete Claude Code session transcripts (.jsonl) that are older than 5 days OR unnamed (session id not present in any sessions-index.json). Active sessions are protected. Use when the user wants to clean up old conversations or free disk space.
---

Delete Claude Code session transcripts under `~/.claude/projects/*/<sid>.jsonl` that match either:
- last modified more than 5 days ago, OR
- unnamed: session id not listed in any project's `sessions-index.json`.

A transcript is **always skipped** when any of these is true (active-session protection):
- mtime is within the last 30 minutes
- the session id appears as `--resume <sid>` in a running `claude` process
- the file is currently held open by any process (visible via `/proc/*/fd`)

## Steps

1. Run the preview command below and show the user the per-project breakdown plus total.
2. Ask the user to confirm before deleting.
3. On confirmation, re-run with `--delete`. Report the number of files deleted and KB freed.

The script lives in this skill's directory. Use the absolute path provided to you in the skill base directory.

Preview:
```bash
bash "<SKILL_DIR>/clean-sessions.sh"
```

Delete (only after explicit confirmation):
```bash
bash "<SKILL_DIR>/clean-sessions.sh" --delete
```

Replace `<SKILL_DIR>` with the base directory shown to you when this skill was invoked (e.g. `~/.claude/plugins/cache/tsrun-toolkit/tsrun-toolkit/<version>/skills/clean-sessions`).
