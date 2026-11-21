#!/bin/zsh
# D21 lesson loop: write, then separate high-effort reads, fixes, at most 3 rounds. Resumable.
R0=${0:A:h:h:h:h:h:h}; cd $R0; D=docs/content/pshs-nce/r2/d21
cx() { CODEX_PICK_PARALLEL=1 ~/.local/bin/codex-pick exec --skip-git-repo-check "$@" < /dev/null; local e=$?; [[ $e == 75 ]] && { echo "CODEX_FULL d21"; exit 75; }; return $e; }
W=(-m gpt-6.2-sol -c model_reasoning_effort=medium -s workspace-write); H=(-m gpt-6.2-sol -c model_reasoning_effort=high -s read-only)
PROT=($D/*.sh $D/*.md); SUM0=$(shasum -a 256 $PROT | shasum -a 256)
# Runs alone in its own worktree. Allowed: new lesson files before parts.txt exists; after it, only the parts it named
# (saved in PARTS when the script wrote it, so a later step cannot widen the list) and this loop's own read and log files.
PARTS=""; [[ -f $D/parts.txt ]] && PARTS=$(cat $D/parts.txt)
guard() { local bad
  [[ $(shasum -a 256 $PROT | shasum -a 256) == $SUM0 ]] || { echo "pipeline files changed; stopping d21"; exit 3; }
  [[ -z $PARTS || $(cat $D/parts.txt) == $PARTS ]] || { echo "parts list changed; stopping d21"; exit 3; }
  bad=$(git status --porcelain --untracked-files=all | { [[ -z $PARTS ]] && grep -vE '^[?][?] content/lessons/.*[.]md$' || cat; } | awk '{print $NF}' \
    | grep -vE "^$D/(write|fix[0-9]|read[0-9])[.](log|out|json|done)$|^$D/(parts[.]txt|clean|open|run[.]log)$" | { [[ -n $PARTS ]] && grep -vxF -f <(print -r -- $PARTS) || cat; })
  [[ -z $bad ]] || { echo "unexpected changes; stopping d21:"; echo "$bad"; exit 3; }; }
if [[ ! -f $D/write.done ]]; then
  cx $W -o $D/write.out "Read $D/writer-brief.md and follow it exactly." > $D/write.log 2>&1; guard
  git status --porcelain --untracked-files=all | awk '/^\?\? content\/lessons\//{print $2}' > $D/parts.txt; PARTS=$(cat $D/parts.txt)
  [[ $(wc -l < $D/parts.txt) -ge 7 ]] && touch $D/write.done || { echo "d21 write failed"; exit 1; }
fi
for r in 1 2 3; do
  R=$D/read$r.json
  [[ -s $R ]] || cx $H -o $R "Read $D/reader-brief.md and follow it exactly. Round $r." > $D/read$r.log 2>&1
  [[ -s $R ]] || { echo "d21 read $r failed"; exit 1; }
  bad=$(python3 -I -c 'import json,sys;print(sum(f["severity"] in ("Blocker","Major") for f in json.load(open(sys.argv[1]))["findings"]))' $R)
  echo "d21 round $r: $bad blocker/major"
  [[ $bad == 0 ]] && { touch $D/clean; break; }
  [[ $r == 3 ]] && { touch $D/open; break; }
  [[ -f $D/fix$r.done ]] || { cx $W -o $D/fix$r.out "Read $D/writer-brief.md for the rules. Fix the parts listed in $D/parts.txt for every Blocker and Major finding in $R, and every Minor finding that is clearly right. Change only what each finding names. Change no other file. Final message: one line per finding, fixed or not and why." > $D/fix$r.log 2>&1; guard; touch $D/fix$r.done; }
done
[[ -f $D/clean ]] && echo "d21 lessons clean" || echo "d21 lessons OPEN"
