#!/bin/zsh
cd /Users/aedwon/.t3/worktrees/Pantas/content-pshs-nce-r1-15add0003f0bf1f9
D=docs/content/pshs-nce
imgs=(); for i in {08..21}; do imgs+=(-i ${PAGES:?set PAGES to the rendered reviewer page folder}/page-$i.png); done
if [[ ! -s $D/reviewer-transcript.md ]] || ! grep -q "IV-20" $D/reviewer-transcript.md; then
  CODEX_PICK_PARALLEL=1 codex-pick exec --skip-git-repo-check -m gpt-6.1-sol -c model_reasoning_effort=medium -s workspace-write $imgs -o $D/logs/transcribe.out "Read $D/transcribe-brief.md and follow it exactly. The 14 attached images are image pages 8 to 21 in order." < /dev/null > $D/logs/transcribe.log 2>&1 || { echo "transcribe failed"; exit 1; }
fi
CODEX_PICK_PARALLEL=1 codex-pick exec --skip-git-repo-check -m gpt-6.1-sol -c model_reasoning_effort=medium -s workspace-write -o $D/logs/map.out "Read $D/map-brief.md and follow it exactly." < /dev/null > $D/logs/map.log 2>&1 || { echo "map failed"; exit 1; }
echo done
