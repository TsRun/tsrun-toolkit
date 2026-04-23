#!/bin/bash
[ "$CLAUDE_AUTOCOMMIT" = '1' ] && exit 0
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Stop hook: sound" >> /tmp/claude-hooks.log
powershell.exe -NoProfile -c "(New-Object Media.SoundPlayer 'C:\Windows\Media\chimes.wav').PlaySync()"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Stop hook: sound done" >> /tmp/claude-hooks.log
