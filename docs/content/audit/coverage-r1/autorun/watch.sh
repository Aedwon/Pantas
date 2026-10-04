#!/bin/zsh
# Run by launchd every 30 minutes. Resumes the orchestrator after a usage-limit
# stop. Never passes an approval gate: at a gate it only notifies Aedwon.
source ${0:A:h}/common.sh
[[ -f $SESSION_FILE ]] || exit 0
codex_running && exit 0
save_progress
STATE=$(audit_state)
case $STATE in
  AWAITING_APPROVAL*|COMPLETE*|BLOCKED*)
    if [[ "$(cat $NOTIFIED_FILE 2>/dev/null)" != "$STATE" ]]; then
      notify "$STATE. Run approve.sh to review."
      print -r -- "$STATE" > $NOTIFIED_FILE
      log "notified: $STATE"
    fi
    exit 0 ;;
esac
# Probe with a tiny request before resuming, so a still-active usage limit
# costs almost nothing instead of reloading the whole session. A probe also
# notices an early reset (for example a reset Aedwon applied manually).
PROBE=$(cd $STATE_DIR && codex exec -m gpt-6.1-sol -c model_reasoning_effort=low -c 'notify=[]' \
  --disable computer_use --disable browser_use --disable browser_use_external --disable in_app_browser \
  -s read-only --skip-git-repo-check --ephemeral "Reply OK." < /dev/null 2>&1)
if print -r -- "$PROBE" | grep -qi "usage limit"; then
  log "still limited: $(print -r -- "$PROBE" | grep -oi 'try again at [^.]*' | tail -1)"
  exit 0
fi
log "resuming session (state: ${STATE:-unknown})"
cd $WT
codex exec resume "${CODEX_FLAGS[@]}" --json "$(cat $SESSION_FILE)" "$(cat ${0:A:h}/resume-prompt.txt)" \
  < /dev/null >> $STATE_DIR/run.jsonl 2>>$LOG &
echo $! > $PID_FILE
