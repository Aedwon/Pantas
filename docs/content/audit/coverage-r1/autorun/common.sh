#!/bin/zsh
# Shared settings for the coverage audit orchestrator and its watcher.
WT=/Users/aedwon/Documents/Projects/Pantas-wt-content-coverage-audit-r1
GITDIR=/Users/aedwon/Documents/Projects/Pantas/.git
STATUS=$WT/docs/content/audit/coverage-r1/status.md
STATE_DIR=$HOME/.pantas-audit
SESSION_FILE=$STATE_DIR/session-id
PID_FILE=$STATE_DIR/codex.pid
NOTIFIED_FILE=$STATE_DIR/notified-state
LOG=$STATE_DIR/watch.log
mkdir -p $STATE_DIR
export PATH=/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:$PATH

# Same model, sandbox, and disabled features for every run. Computer use and
# browser control stay off; web search and network for git push stay on.
CODEX_FLAGS=(
  -m gpt-6.1-sol
  -c model_reasoning_effort=high
  -c 'notify=[]'
  -c 'web_search="live"'
  -c 'approval_policy="never"'
  -c 'sandbox_mode="workspace-write"'
  -c 'sandbox_workspace_write.network_access=true'
  --disable computer_use --disable browser_use
  --disable browser_use_external --disable in_app_browser
)

log() { print -r -- "$(date '+%Y-%m-%d %H:%M:%S') $*" >> $LOG; }

# First line of status.md: "STATE: RUNNING", "STATE: AWAITING_APPROVAL ...",
# "STATE: COMPLETE", or "STATE: BLOCKED ...".
audit_state() { head -1 $STATUS 2>/dev/null | sed -n 's/^STATE: //p'; }

codex_running() {
  [[ -f $PID_FILE ]] && kill -0 $(cat $PID_FILE) 2>/dev/null && return 0
  [[ -f $SESSION_FILE ]] && pgrep -f "$(cat $SESSION_FILE)" >/dev/null && return 0
  pgrep -f "codex.*Pantas-wt-content-coverage-audit-r1" >/dev/null && return 0
  return 1
}

notify() {
  osascript -e "display notification \"$1\" with title \"Pantas audit\" sound name \"Glass\"" 2>/dev/null
}

# Codex's sandbox keeps git metadata read-only, so the orchestrator cannot
# commit. This saves its work from outside the sandbox while Codex is idle.
save_progress() {
  cd $WT || return
  git fetch -q origin 2>>$LOG
  git add docs/content/audit/coverage-r1 docs/superpowers/decisions docs/superpowers/plans docs/superpowers/specs 2>>$LOG
  git diff --cached --quiet && return
  git commit -q -m "docs: save coverage audit progress from the orchestrator

Codex cannot commit inside its sandbox, so the watcher saves completed work
to the branch while the orchestrator is idle." 2>>$LOG \
    && git push -q origin HEAD 2>>$LOG \
    && log "saved $(git rev-parse --short HEAD)"
}
