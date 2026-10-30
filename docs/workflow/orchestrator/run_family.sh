#!/bin/bash
# Build -> review -> fix pipeline for one family of work, run through Codex.
# usage: ORCH_DIR=<dir with common.md and <name>.brief.md> ORCH_WORKTREE=<worktree> run_family.sh <name>
# Exit 75 means every Codex account is full; ORCH_DIR/CODEX_FULL holds the reset line.
# A stage whose output already ends with STAGE-DONE is skipped, so a rerun resumes.
n=$1; D=${ORCH_DIR:?}; W=${ORCH_WORKTREE:?}
COMMON=(-m gpt-6.1-sol -c 'model_reasoning_effort="low"' -s workspace-write
  -c 'sandbox_workspace_write.network_access=true' -C "$W"
  --add-dir /opt/homebrew --add-dir ~/.pub-cache --add-dir ~/.dart-tool --add-dir ~/.flutter
  --add-dir ~/development --add-dir /private/tmp --add-dir ~/.cache --add-dir ~/.npm
  ${ORCH_EXTRA_DIRS:+--add-dir "$ORCH_EXTRA_DIRS"} --skip-git-repo-check)
# Build and fix write to the worktree and need the Flutter, pub and npm caches and network for
# dependency fetches. Review only reads, so it runs read-only with no network.
REVIEW=(-m gpt-6.1-sol -c 'model_reasoning_effort="low"' -s read-only -C "$W" ${ORCH_EXTRA_DIRS:+--add-dir "$ORCH_EXTRA_DIRS"} --skip-git-repo-check)
step() { # $1 stage, $2 prompt
  [ -s "$D/$n.$1.out" ] && grep -q "^STAGE-DONE" "$D/$n.$1.out" && return 0
  if [ "$1" = review ]; then ARGS=("${REVIEW[@]}"); else ARGS=("${COMMON[@]}"); fi
  codex-pick exec "${ARGS[@]}" -o "$D/$n.$1.out" "$2" </dev/null > "$D/$n.$1.log" 2>&1; rc=$?
  if [ $rc -eq 75 ]; then grep -i "reset" "$D/$n.$1.log" | tail -1 > "$D/CODEX_FULL"; echo "codex full at $1"; exit 75; fi
  echo "$1 exit $rc"
}
step build "$(cat "$D/common.md" "$D/$n.brief.md")
End your final message with a line STAGE-DONE."
step review "$(cat "$D/common.md")
REVIEW ONLY, do not edit files. Review the uncommitted changes for '$n' against its brief below, the
design source it names and the project's hard rules. List concrete findings with file:line, most
severe first. Say 'NO FINDINGS' if none.
--- brief ---
$(cat "$D/$n.brief.md")
End your final message with a line STAGE-DONE."
step fix "$(cat "$D/common.md")
Fix every finding below in the uncommitted work for '$n', unless it contradicts the brief; list any
you reject with the reason. Then run the verification commands to completion and report pass/fail
with summary lines, files touched, and anything left undone.
--- findings ---
$(cat "$D/$n.review.out")
--- brief ---
$(cat "$D/$n.brief.md")
End your final message with a line STAGE-DONE."
echo "family $n complete"
