#!/bin/zsh
# One Codex job at a time (machine cap, Nov 21): D21 lessons, then the four question lanes in order. Run in its own worktree.
R0=${0:A:h:h:h:h:h}; cd $R0; D=docs/content/pshs-nce/r2; ST=$HOME/.local/state/pantas/pshs-r2; mkdir -p $ST
$D/d21/run.sh >> $ST/d21.log 2>&1; [[ $? == 75 ]] && { echo "STOP codex full (d21)"; exit 75; }
for i in 1 2 3 4; do
  $D/run-lane.sh $D/lane$i.txt >> $ST/lane$i.log 2>&1; [[ $? == 75 ]] && { echo "STOP codex full (lane $i)"; exit 75; }
done
echo "ALL DONE"
