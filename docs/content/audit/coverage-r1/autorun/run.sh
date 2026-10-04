#!/bin/zsh
# Run this in a Terminal window and leave it open. It starts the orchestrator
# if needed, keeps the Mac awake, and checks every 30 minutes: it resumes Codex
# after usage-limit stops and notifies Aedwon at approval gates.
# (A launchd job cannot read ~/Documents without Full Disk Access, so the
# watcher runs from Terminal instead.)
source ${0:A:h}/common.sh
caffeinate -dims -w $$ &
if [[ ! -f $SESSION_FILE ]]; then
  ${0:A:h}/start.sh
fi
echo "Watching. Leave this window open. Log: $LOG"
while true; do
  ${0:A:h}/watch.sh
  echo "$(date '+%H:%M') state: $(audit_state)  codex running: $(codex_running && echo yes || echo no)"
  sleep 1800
done
