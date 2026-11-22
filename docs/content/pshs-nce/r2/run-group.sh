#!/bin/zsh
# usage: QC_SCRATCH=<dir> run-group.sh <group key, e.g. science/biology/ecology>. Resumable through marker files.
R0=${0:A:h:h:h:h:h}; cd $R0
# All state (markers, logs, packets, keys, answers, reads) lives outside the worktree and /tmp, where no Codex sandbox can write.
ST=$HOME/.local/state/pantas/pshs-r2
# --round4: one lead-ruled fix (skipped when FIXARG=nofix, for files the lead fixed by hand), then a fresh solve and fit read.
R4=0; [[ $1 == --round4 ]] && { R4=1; shift; }
D=docs/content/pshs-nce/r2; g=$1; n=${g//\//__}; M=$ST/runs/$n; mkdir -p $M
S=$M/scratch; mkdir -p $S
info() { python3 -I $D/ginfo.py $D/groups.json $g $1; }
Q=$(info q); C=$(info c)
[[ $C == 0 ]] && { echo "$g nothing to write"; touch $M/clean; exit 0; }
P=$(info p); [[ -n $P && -n $Q ]] || { echo "empty task $g"; exit 4; }
TASK="Question file: $Q. Parts: $P."
PROT=($D/*.sh $D/*.py $D/*.md $D/groups.json $D/lane*.txt $D/qc/*.py docs/content/pshs-nce/solve-brief.md docs/content/pshs-nce/fit-brief.md)
SUM0=$(shasum -a 256 $PROT | shasum -a 256)
# After each Codex step: pipeline files unchanged, and changes only in question files, new lesson parts, run outputs and lane logs.
# Runs alone in its own worktree (one pipeline per worktree), so the guard can allow only this group's own files:
# its question file. Anything else stops the run.
guard() { local bad
  [[ $(shasum -a 256 $PROT | shasum -a 256) == $SUM0 ]] || { echo "pipeline files changed; stopping $g"; exit 3; }
  bad=$(git status --porcelain --untracked-files=all | awk '{print $NF}' | grep -vxF -e "$Q")
  [[ -z $bad ]] || { echo "unexpected changes; stopping $g:"; echo "$bad"; exit 3; }; }
val() { dart run tools/import_questions/import_questions.dart --root $(dirname $Q) >/dev/null 2>&1; }
gate() { local l m; while :; do l=$(sysctl -n vm.loadavg | awk '{print int($2)}'); m=$(memory_pressure | awk -F': ' '/free percentage/{print int($2)}'); (( l <= 12 && m >= 30 )) && return; echo "waiting: load $l, free $m%"; sleep 120; done; }
cx() { gate; CODEX_PICK_PARALLEL=1 ~/.local/bin/codex-pick exec --skip-git-repo-check "$@" < /dev/null; local e=$?; [[ $e == 75 ]] && { echo "CODEX_FULL $g"; exit 75; }; return $e; }
# Stop the whole queue (exit 77) when an account cannot run the model, instead of failing file after file (account a, Nov 22).
# guard runs first, so a write step is always checked. A model that writes this text itself can only stop the queue (fail-safe).
chk() { guard; grep -qs "not supported when using Codex with a ChatGPT account" "$@" && { echo "STOP account cannot run the model (likely account a): $*"; exit 77; }; return 0; }
W=(-m gpt-6.2-sol -c model_reasoning_effort=medium -s workspace-write)
H=(-m gpt-6.2-sol -c model_reasoning_effort=high -s read-only)
if [[ ! -f $M/write.done ]]; then
  cx $W -o $M/write.out "Read $D/questions-brief.md and follow it exactly. $TASK" > $M/write.log 2>&1; chk $M/write.log
  guard; [[ -s $Q ]] && val && touch $M/write.done || { echo "write failed $g"; exit 1; }
fi
ROUNDS=(1 2 3)
if (( R4 )); then
  [[ -f $M/open && ! -f $M/r4.done ]] || { echo "$g not open"; exit 0; }
  if [[ $FIXARG == fix && ! -f $M/leadfix.done ]]; then
    cx $W -o $M/leadfix.out "Read $D/fix-brief.md and follow it exactly. Also read $D/lead-rulings.md; where a ruling there differs from a finding, follow the ruling. Question file: $Q. Findings file: $M/fit3.json. Mismatch file: $M/solve3/mismatches.json." > $M/leadfix.log 2>&1; chk $M/leadfix.log
    guard; val && touch $M/leadfix.done || { echo "lead fix failed $g"; exit 1; }
  fi
  ROUNDS=(4)
fi
for r in $ROUNDS; do
  [[ -f $M/clean ]] && break
  if [[ ! -f $M/solve$r.done ]]; then
    rm -rf $S/r$r $M/solve$r; mkdir -p $S/r$r/solve $S/r$r/ans
    python3 -I $D/qc/build_packets.py --out $S/r$r --files $Q > $M/packets$r.log 2>&1
    f=$(ls $S/r$r/packets/*.md | head -1); fid=$(basename $f .md); cp $f $S/r$r/solve/packet.md
    (cd $S/r$r/solve && cx $H -C $S/r$r/solve -o $S/r$r/ans/$fid.json "$(cat $R0/docs/content/pshs-nce/solve-brief.md)" > $M/solve$r.log 2>&1); chk $M/solve$r.log
    python3 -I $D/qc/merge_solves.py --keys $S/r$r/keys --answers $S/r$r/ans --out $M/solve$r > $M/merge$r.log 2>&1 && touch $M/solve$r.done || { echo "solve failed $g r$r"; exit 1; }
  fi
  if [[ ! -s $M/fit$r.json ]]; then
    rm -rf $S/f$r; python3 -I $D/qc/build_fit_packets.py --out $S/f$r --files $Q > $M/fitpk$r.log 2>&1
    pk=$(ls $S/f$r/fit/*.md | head -1); cp $pk $M/fit-packet$r.md
    cx $H -o $M/fit$r.json "Read docs/content/pshs-nce/fit-brief.md and follow it exactly. Packet: $M/fit-packet$r.md" > $M/fit$r.log 2>&1; chk $M/fit$r.log
    [[ -s $M/fit$r.json ]] || { echo "fit failed $g r$r"; exit 1; }
  fi
  bad=$(python3 -I -c 'import json,sys;f=json.load(open(sys.argv[1]));m=json.load(open(sys.argv[2]))["totals"];print(sum(x["severity"] in ("Blocker","Major") for x in f["findings"])+m["mismatch"]+m["problem"])' $M/fit$r.json $M/solve$r/mismatches.json)
  echo "$g round $r: $bad blocker/major or mismatch"
  [[ $bad == 0 ]] && { touch $M/clean; rm -f $M/open; break; }
  [[ $r == 3 ]] && { touch $M/open; break; }
  [[ $r == 4 ]] && break
  if [[ ! -f $M/fix$r.done ]]; then
    cx $W -o $M/fix$r.out "Read $D/fix-brief.md and follow it exactly. Question file: $Q. Findings file: $M/fit$r.json. Mismatch file: $M/solve$r/mismatches.json." > $M/fix$r.log 2>&1; chk $M/fix$r.log
    guard; val && touch $M/fix$r.done || { echo "fix failed $g r$r"; exit 1; }
  fi
done
(( R4 )) && touch $M/r4.done
[[ -f $M/open ]] && echo "$g OPEN after $r rounds" || echo "$g clean"
