#!/bin/zsh
cd /Users/aedwon/.t3/worktrees/Pantas/content-math-for-genera-8e64e99cb1029879
D=docs/content/math-for-generator/qcheck
for f in $(cat $D/list.txt); do
  id=$(basename $(dirname $f))__$(basename $f .yaml); out=$D/results/$id.json
  [[ -s $out ]] && continue
  echo "run $id $(date -u +%H:%M)"
  CODEX_PICK_PARALLEL=1 codex-pick exec --skip-git-repo-check -m gpt-6.1-sol -c model_reasoning_effort=medium -s read-only -o $out "Read $D/fit-brief.md and follow it exactly. Question file: $f." < /dev/null > $D/logs/$id.log 2>&1
  [[ -s $out ]] || { echo "no output $id"; grep -q "exit 75\|all accounts" $D/logs/$id.log && exit 75; }
done
echo "list done"
