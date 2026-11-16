#!/bin/zsh
# usage: QC_SCRATCH=<scratch folder> pipeline.sh <name>. Resumable: each stage leaves a marker file.
# Adapted from docs/content/math-for-generator/pshs/pipeline.sh. A lesson with no question file stops after its lesson reads.
R0=${0:A:h:h:h:h}; cd $R0
D=docs/content/pshs-nce; n=$1; M=$R0/$D/logs/$n; mkdir -p $M
S=${QC_SCRATCH:?set QC_SCRATCH}/qc-$n
get() { python3 -I -c 'import json,sys;v=json.load(open(sys.argv[1]))[sys.argv[2]][sys.argv[3]];print(", ".join(v) if isinstance(v,list) else v)' $D/lessons.json $n $1; }
guard() { git diff --quiet HEAD -- tools || { echo "tools/ changed; stopping $n"; exit 3; }; }
L=$(get lesson); ID=$(get id); Q=$(get questions)
TASK="Lesson id: $ID. Lesson path: $L. Title: $(get title). Front matter: $(get frontmatter). Official items: $(get items). Methods to teach: $(get methods)."
cx() { CODEX_PICK_PARALLEL=1 codex-pick exec --skip-git-repo-check "$@" < /dev/null; }
SOL=(-m gpt-6.1-sol -c model_reasoning_effort=medium)
AST=(-m gpt-6-astra -c model_reasoning_effort=high -s read-only)
if [[ ! -f $M/write.done ]]; then
  cx $SOL -s workspace-write -o $M/write.out "Read $D/writer-brief.md and follow it exactly. $TASK" > $M/write.log 2>&1 && [[ -s $L ]] && touch $M/write.done || { echo "write failed $n"; exit 1; }
fi
for r in 1 2 3; do
  R=$D/reads/$n-r$r.json
  [[ -s $R ]] || cx $AST -o $R "Read $D/reader-brief.md and follow it exactly. Round $r. $TASK" > $M/read$r.log 2>&1
  [[ -s $R ]] || { echo "read $r failed $n"; exit 1; }
  bad=$(python3 -I -c 'import json,sys;print(sum(f["severity"] in ("Blocker","Major") for f in json.load(open(sys.argv[1]))["findings"]))' $R)
  echo "$n round $r: $bad blocker/major"
  [[ $bad == 0 ]] && { touch $M/lesson.clean; break; }
  [[ -f $M/fix$r.done ]] && continue
  [[ $r == 3 ]] && { touch $M/lesson.open; break; }
  cx $SOL -s workspace-write -o $M/fix$r.out "Read $D/writer-brief.md for the rules. Fix the lesson $L for every Blocker and Major finding in $R, and every Minor finding that is clearly right. Change only the sentences each finding names, plus anything a fix makes untrue. State conditions; do not add new absolute statements. Final message: one line per finding, fixed or not and why. $TASK" > $M/fix$r.log 2>&1 && touch $M/fix$r.done
done
[[ -f $M/lesson.open ]] && { echo "$n lesson still open after 3 rounds; questions not started"; exit 2; }
[[ -z $Q ]] && { echo "$n lesson clean; no questions by ruling"; exit 0; }
if [[ ! -f $M/questions.done ]]; then
  cx $SOL -s workspace-write -o $M/questions.out "Read $D/questions-brief.md and follow it exactly. Question file: $Q. $TASK" > $M/questions.log 2>&1
  guard; dart run tools/import_questions/import_questions.dart --root $(dirname $Q) >/dev/null 2>&1 && [[ -s $Q ]] && touch $M/questions.done || { echo "questions failed $n"; exit 1; }
fi
if [[ ! -f $M/solve.done ]]; then
  guard; mkdir -p $S/ans $S/solve
  python3 -I tools/content_rewrite/question_check/build_packets.py --out $S --files $Q > $M/packets.log 2>&1
  f=$(ls $S/packets/*.md | head -1); fid=$(basename $f .md); cp $f $S/solve/packet.md
  (cd $S/solve && cx $SOL -s read-only -C $S/solve -o $S/ans/$fid.json "$(cat $R0/$D/solve-brief.md)" > $M/solve.log 2>&1)
  python3 -I tools/content_rewrite/question_check/merge_solves.py --keys $S/keys --answers $S/ans --out $R0/$D/reads/$n-solve > $M/merge.log 2>&1 && touch $M/solve.done
fi
if [[ ! -s $D/reads/$n-fit.json ]]; then
  guard; python3 -I tools/content_rewrite/question_check/build_fit_packets.py --out $S --files $Q > $M/fitpk.log 2>&1
  pk=$(ls $S/fit/*.md | head -1); mkdir -p $D/reads/fit-packets; cp $pk $D/reads/fit-packets/$n.md
  cx $AST -o $D/reads/$n-fit.json "Read $D/fit-brief.md and follow it exactly. Packet: $D/reads/fit-packets/$n.md" > $M/fit.log 2>&1
fi
echo "$n pipeline done"
