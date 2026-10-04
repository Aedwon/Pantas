#!/bin/zsh
# Opens the orchestrator session interactively so Aedwon can read its report
# and approve the next level. Close the window when done; the watcher continues.
source ${0:A:h}/common.sh
[[ -f $SESSION_FILE ]] || { echo "No session yet. Run start.sh first."; exit 1; }
if [[ -f $PID_FILE ]] && kill -0 $(cat $PID_FILE) 2>/dev/null; then
  echo "The orchestrator is working right now. Try again when it reaches a gate."; exit 1
fi
rm -f $NOTIFIED_FILE
save_progress
codex resume -m gpt-6.1-sol -c model_reasoning_effort=high -c 'notify=[]' -c 'web_search="live"' \
  -c 'sandbox_workspace_write.network_access=true' \
  --disable computer_use --disable browser_use --disable browser_use_external --disable in_app_browser \
  -a never -s workspace-write -C $WT "$(cat $SESSION_FILE)"
