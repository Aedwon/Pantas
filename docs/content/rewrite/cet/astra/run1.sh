#!/bin/zsh
# usage: run1.sh <lesson-id>
cd /Users/aedwon/.t3/worktrees/Pantas/content-cet-finish-r1-0bd3c4d0f0d38603
id=$1; S=/private/tmp/claude-501/-Users-aedwon--t3-worktrees-Pantas-content-cet-finish-r1-0bd3c4d0f0d38603/1525883d-f63c-4da5-8d1e-f680927d2257/scratchpad
info=$(python3 -c "import json,sys;d=json.load(open('docs/content/rewrite/cet/astra/scope.json'))[sys.argv[1]];print(d['lesson']);print(d['questions']);print(', '.join(d['auditIds']) or 'none')" $id)
lesson=$(echo $info | sed -n 1p); qf=$(echo $info | sed -n 2p); qids=$(echo $info | sed -n 3p)
prompt="Read docs/content/rewrite/cet/astra/brief.md and follow it exactly. Lesson id: $id. Lesson file: $lesson. Question file: $qf. Question ids to check: $qids."
codex-pick exec -m gpt-6-astra -s read-only --skip-git-repo-check -c model_reasoning_effort=high -o $S/astra/$id.json "$prompt" < /dev/null > $S/astra/$id.log 2>&1
echo "exit $?"
