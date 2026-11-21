#!/bin/zsh
# usage: QC_SCRATCH=<dir> run-lane.sh <lane file>. Runs its groups one after another; stops on Codex full.
R0=${0:A:h:h:h:h:h}; cd $R0
for g in $(cat $1); do
  docs/content/pshs-nce/r2/run-group.sh $g; e=$?
  [[ $e == 75 ]] && { echo "LANE STOP codex full"; exit 75; }
  [[ $e != 0 ]] && echo "GROUP FAILED $g exit $e"
done
echo "LANE DONE $1"
