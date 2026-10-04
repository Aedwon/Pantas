#!/bin/zsh
# Starts the orchestrator once, in the background, and records its session id.
source ${0:A:h}/common.sh
if codex_running; then echo "Orchestrator already running."; exit 1; fi
if [[ -f $SESSION_FILE ]]; then echo "A session already exists ($(cat $SESSION_FILE)). Use approve.sh to talk to it."; exit 1; fi
PROMPT=$(cat ${0:A:h}/start-prompt.txt)
cd $WT
( codex exec --json "${CODEX_FLAGS[@]}" "$PROMPT" < /dev/null 2>>$LOG \
  | while IFS= read -r line; do
      if [[ ! -f $SESSION_FILE && $line == *thread.started* ]]; then
        print -r -- "$line" | sed -E 's/.*"thread_id":"([^"]+)".*/\1/' > $SESSION_FILE
        log "started session $(cat $SESSION_FILE)"
      fi
      print -r -- "$line" >> $STATE_DIR/run.jsonl
    done ) &
echo $! > $PID_FILE
sleep 20
echo "Started. Session: $(cat $SESSION_FILE 2>/dev/null || echo pending)"
