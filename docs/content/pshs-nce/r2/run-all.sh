#!/bin/zsh
# One Codex job at a time (machine cap, Nov 21): D21 lessons, then the four question lanes in order. Run in its own worktree.
# Fail closed: before every script runs, the pipeline folder must match the commit, and any stop other than a
# recoverable group failure ends the whole queue.
R0=${0:A:h:h:h:h:h}; cd $R0; D=docs/content/pshs-nce/r2; ST=$HOME/.local/state/pantas/pshs-r2; mkdir -p $ST
pinned() { git diff --quiet HEAD -- docs/content/pshs-nce && [[ -z $(git ls-files --others --exclude-standard docs/content/pshs-nce) ]] || { echo "STOP pipeline folder differs from HEAD"; git status --short docs/content/pshs-nce; exit 3; }; }
pinned; $D/d21/run.sh >> $ST/d21.log 2>&1; e=$?; (( e == 0 )) || { echo "STOP d21 exit $e"; exit $e; }
for i in 5 1 2 3 4; do
  pinned; $D/run-lane.sh $D/lane$i.txt >> $ST/lane$i.log 2>&1; e=$?; (( e == 0 )) || { echo "STOP lane $i exit $e"; exit $e; }
done
echo "ALL DONE"
