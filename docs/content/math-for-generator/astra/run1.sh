#!/bin/zsh
# usage: run1.sh lesson <lesson-id>   |   run1.sh family <parent-id>
cd /Users/aedwon/.t3/worktrees/Pantas/content-math-for-genera-8e64e99cb1029879
D=docs/content/math-for-generator/astra; kind=$1; id=$2
if [[ $kind == lesson ]]; then
  info=$(python3 -c "import json,sys;d=json.load(open('docs/content/rewrite/cet/astra/scope.json'))[sys.argv[1]];print(d['lesson']);print(d['questions']);print(', '.join(d['auditIds']) or 'none')" $id)
  lesson=$(echo $info | sed -n 1p); qf=$(echo $info | sed -n 2p); qids=$(echo $info | sed -n 3p)
  prompt="Read $D/brief.md and follow it exactly. Lesson id: $id. Lesson file: $lesson. Question file: $qf. Question ids to check: $qids."
else
  info=$(python3 - $id <<'PY'
import json,sys,subprocess
f=json.load(open('docs/content/math-for-generator/astra/algebra-families.json'))[sys.argv[1]]
paths=[subprocess.run(['grep','-rl',f'_id: "{p}"','content/lessons/mathematics/algebra'],capture_output=True,text=True).stdout.split()[0] for p in f['parts']]
print(f['parent']); print(' '.join(paths)); print('yes' if f['cetRewrite'] else 'no')
PY
)
  parent=$(echo $info | sed -n 1p); parts=$(echo $info | sed -n 2p); cet=$(echo $info | sed -n 3p)
  prompt="Read $D/brief-algebra.md and follow it exactly. Family: $id. Parent file: $parent. Parent has a CET rewrite: $cet. Part files: $parts."
fi
CODEX_PICK_PARALLEL=1 codex-pick exec -m gpt-6-astra -s read-only --skip-git-repo-check -c model_reasoning_effort=high -o $D/results/$id.json "$prompt" < /dev/null > $D/logs/$id.log 2>&1
echo "exit $? $id"
