#!/bin/zsh
# usage: loop.sh lesson|family <list-file>. One job at a time; stops when total room < FLOOR.
D=/Users/aedwon/.t3/worktrees/Pantas/content-math-for-genera-8e64e99cb1029879/docs/content/math-for-generator/astra
FLOOR=${FLOOR:-60}
for id in $(cat $2); do
  [[ -s $D/results/$id.json ]] && { echo "skip $id"; continue; }
  room=$(codex-pick --json 2>/dev/null | python3 -c "import json,sys;d=json.load(sys.stdin);print(sum(a['room'] for a in d['accounts'].values()))")
  if (( room < FLOOR )); then echo "FLOOR reached (room $room) before $id"; exit 0; fi
  echo "run $id (room $room) $(date -u +%H:%M)"
  $D/run1.sh $1 $id
  [[ -s $D/results/$id.json ]] || { echo "no output for $id"; grep -q 'exit 75\|all accounts' $D/logs/$id.log && exit 75; }
done
echo "list done"
