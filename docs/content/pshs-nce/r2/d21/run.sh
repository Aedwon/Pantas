#!/bin/zsh
# D21 lesson loop: write, then separate high-effort reads, fixes, at most 3 rounds. Resumable.
R0=${0:A:h:h:h:h:h:h}; cd $R0; D=docs/content/pshs-nce/r2/d21
# Markers, the parts list, reads and logs live outside the worktree and /tmp, where no Codex sandbox can write.
ST=$HOME/.local/state/pantas/pshs-r2/d21; mkdir -p $ST
gate() { local l m; while :; do l=$(sysctl -n vm.loadavg | awk '{print int($2)}'); m=$(memory_pressure | awk -F': ' '/free percentage/{print int($2)}'); (( l <= 12 && m >= 30 )) && return; echo "waiting: load $l, free $m%"; sleep 120; done; }
cx() { gate; CODEX_PICK_PARALLEL=1 ~/.local/bin/codex-pick exec --skip-git-repo-check "$@" < /dev/null; local e=$?; [[ $e == 75 ]] && { echo "CODEX_FULL d21"; exit 75; }; return $e; }
W=(-m gpt-6.2-sol -c model_reasoning_effort=medium -s workspace-write); H=(-m gpt-6.2-sol -c model_reasoning_effort=high -s read-only)
PROT=($D/*.sh $D/*.md); SUM0=$(shasum -a 256 $PROT | shasum -a 256)
# Runs alone in its own worktree. Before the parts list exists, only new lesson files may appear; after, only the listed parts.
PARTS=""; [[ -f $ST/parts.txt ]] && PARTS=$(cat $ST/parts.txt)
okparts() { [[ -n $PARTS ]] && ! print -r -- $PARTS | grep -vqE '^content/lessons/(language-proficiency|science)/[a-z0-9/-]+[.]md$'; }
guard() { local bad
  [[ $(shasum -a 256 $PROT | shasum -a 256) == $SUM0 ]] || { echo "pipeline files changed; stopping d21"; exit 3; }
  if [[ -z $PARTS ]]; then bad=$(git status --porcelain --untracked-files=all | grep -vE '^[?][?] content/lessons/[a-z0-9/-]+[.]md$')
  else bad=$(git status --porcelain --untracked-files=all | awk '{print $NF}' | grep -vxF -f <(print -r -- $PARTS)); fi
  [[ -z $bad ]] || { echo "unexpected changes; stopping d21:"; echo "$bad"; exit 3; }; }
if [[ ! -f $ST/write.done ]]; then
  cx $W -o $ST/write.out "Read $D/writer-brief.md and follow it exactly." > $ST/write.log 2>&1; guard
  git status --porcelain --untracked-files=all | awk '/^\?\? content\/lessons\//{print $2}' > $ST/parts.txt; PARTS=$(cat $ST/parts.txt); okparts || { echo "bad parts list"; exit 3; }
  [[ $(wc -l < $ST/parts.txt) -ge 7 ]] && touch $ST/write.done || { echo "d21 write failed"; exit 1; }
fi
for r in 1 2 3; do
  R=$ST/read$r.json
  [[ -s $R ]] || cx $H -o $R "Read $D/reader-brief.md and follow it exactly. Round $r. The parts: ${(j:, :)${(f)PARTS}}." > $ST/read$r.log 2>&1
  [[ -s $R ]] || { echo "d21 read $r failed"; exit 1; }
  bad=$(python3 -I -c 'import json,sys;print(sum(f["severity"] in ("Blocker","Major") for f in json.load(open(sys.argv[1]))["findings"]))' $R)
  echo "d21 round $r: $bad blocker/major"
  [[ $bad == 0 ]] && { touch $ST/clean; break; }
  [[ $r == 3 ]] && { touch $ST/open; break; }
  [[ -f $ST/fix$r.done ]] || { cx $W -o $ST/fix$r.out "Read $D/writer-brief.md for the rules. Fix these parts: ${(j:, :)${(f)PARTS}}. Fix them for every Blocker and Major finding in $R, and every Minor finding that is clearly right. Change only what each finding names. Change no other file. Final message: one line per finding, fixed or not and why." > $ST/fix$r.log 2>&1; guard; touch $ST/fix$r.done; }
done
[[ -f $ST/clean ]] && echo "d21 lessons clean" || echo "d21 lessons OPEN"
