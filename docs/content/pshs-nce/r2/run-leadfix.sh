#!/bin/zsh
# After the main queue: for each open group, one Codex fix under the lead rulings (none for lead-fixed files), then a
# fresh blind solve and fit read as round 4. Run in the run worktree, one Codex job at a time. Same guards as run-group.
R0=${0:A:h:h:h:h:h}; cd $R0; D=docs/content/pshs-nce/r2; ST=$HOME/.local/state/pantas/pshs-r2
for M in $ST/runs/*/(N); do
  M=${M%/}; [[ -f $M/open && ! -f $M/r4.done ]] || continue
  n=${M:t}; g=${${n//__/\/}}; Q=$(python3 -I $D/ginfo.py $D/groups.json $g q 2>/dev/null) || { echo "no group for $n"; continue; }
  LEADFIXED=0; grep -q "${Q}" $D/lead-fixed.txt && LEADFIXED=1
  FIXARG=$([[ $LEADFIXED == 1 ]] && echo nofix || echo fix) $D/run-group.sh --round4 $g; e=$?
  (( e == 0 )) || { echo "LEADFIX STOP $g exit $e"; exit $e; }
  [[ -n $(git status --porcelain -- $Q) ]] && git add -- $Q && git commit -q -m "PSHS-NCE questions: $g lead-ruling fix and round 4" -- $Q
done
echo "LEADFIX DONE"
