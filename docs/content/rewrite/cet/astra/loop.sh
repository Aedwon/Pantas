#!/bin/zsh
# Runs Astra on each lesson id in the list file, one at a time.
# Stops when total weekly room across accounts falls below FLOOR (percent),
# so engineering keeps Codex during the beta.
S=/private/tmp/claude-501/-Users-aedwon--t3-worktrees-Pantas-content-cet-finish-r1-0bd3c4d0f0d38603/1525883d-f63c-4da5-8d1e-f680927d2257/scratchpad
FLOOR=${FLOOR:-20}
for id in $(cat $1); do
  [[ -s $S/astra/$id.json ]] && { echo "skip $id"; continue; }
  room=$(codex-pick --json 2>/dev/null | python3 -c "import json,sys;d=json.load(sys.stdin);print(sum(a['room'] for a in d['accounts'].values()))")
  if (( room < FLOOR )); then echo "FLOOR reached (room $room) before $id"; exit 0; fi
  echo "run $id (room $room) $(date +%H:%M)"
  $S/astra/run1.sh $id
  rc=$?
  [[ -s $S/astra/$id.json ]] || { echo "no output for $id (exit $rc)"; grep -q 'exit 75' $S/astra/$id.log && exit 75; }
done
echo "list done"
