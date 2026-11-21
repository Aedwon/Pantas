#!/bin/zsh
# usage: run-lane.sh <lane file>. Runs its groups one after another, in the run worktree (branch work/pshs-run).
# After each group the runner itself commits that group's question file, so the next group's guard starts clean.
# A group that fails to write or solve (exit 1) has its partial file moved to the state folder and the lane goes on;
# any other stop (3 guard, 4 empty task, 75 Codex full, anything else) ends the lane.
R0=${0:A:h:h:h:h:h}; cd $R0; D=docs/content/pshs-nce/r2; ST=$HOME/.local/state/pantas/pshs-r2
for g in $(cat $1); do
  git diff --quiet HEAD -- docs/content/pshs-nce || { echo "LANE STOP pipeline folder changed"; exit 3; }
  Q=$(python3 -I $D/ginfo.py $D/groups.json $g q)
  $D/run-group.sh $g; e=$?
  if (( e == 0 )); then
    [[ -n $(git status --porcelain -- $Q) ]] && { git add -- $Q && git commit -q -m "PSHS-NCE questions: $g (pipeline run; see state folder for reads)" -- $Q || { echo "LANE STOP commit failed $g"; exit 3; }; }
    continue
  fi
  if (( e == 1 )); then
    echo "GROUP FAILED $g exit 1"
    [[ -f $Q ]] && { mkdir -p $ST/failed; mv $Q $ST/failed/${g//\//__}.yaml; git checkout -q -- $Q 2>/dev/null; }
    continue
  fi
  echo "LANE STOP $g exit $e"; exit $e
done
echo "LANE DONE $1"
