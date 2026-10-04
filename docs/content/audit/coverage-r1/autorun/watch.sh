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
log "resuming session (state: ${STATE:-unknown})"
cd $WT
codex exec resume "${CODEX_FLAGS[@]}" --json "$(cat $SESSION_FILE)" "$(cat ${0:A:h}/resume-prompt.txt)" \
  < /dev/null >> $STATE_DIR/run.jsonl 2>>$LOG &
echo $! > $PID_FILE
