#!/bin/zsh
# usage: run-lane.sh <lane file>. Runs its groups one after another. A group that fails to write or solve (exit 1)
# is logged and the lane goes on; any other stop (3 guard, 4 empty task, 75 Codex full, anything else) ends the lane.
R0=${0:A:h:h:h:h:h}; cd $R0
for g in $(cat $1); do
  git diff --quiet HEAD -- docs/content/pshs-nce || { echo "LANE STOP pipeline folder changed"; exit 3; }
  docs/content/pshs-nce/r2/run-group.sh $g; e=$?
  (( e == 0 )) && continue
  (( e == 1 )) && { echo "GROUP FAILED $g exit 1"; continue; }
  echo "LANE STOP $g exit $e"; exit $e
done
echo "LANE DONE $1"
