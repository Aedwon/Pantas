# Brief: slim the R1 pilot, number and letter series (E-216, step 1)

Lead: CSE walk-through lead. Plan: `git show origin/main:docs/superpowers/plans/2026-11-28-walkthrough-reasoning-cse.md`
(read sections 2 to 4 in full). Spec: `git show origin/main:docs/superpowers/specs/2026-11-25-lesson-walkthrough-standard.md`,
Part A "Revision, November 27, 2026" points 1 to 5, and Part B "Authoring rules".

Startup: retrieve `AGENTS.md`, `WORKFLOW.md`, `SUBAGENTS.md` from current GitHub main (`git show origin/main:<file>`) and
follow them. Lead's policy commit `3bffd9286`.

Then read, from branch `content/lesson-walkthrough-cse-r1` (`git show origin/content/lesson-walkthrough-cse-r1:<path>`):
1. `docs/content/verification/walkthrough-work/pilot-slim-brief.md`, section "The revised format (Nov 27)", rules 1 to 9.
   They apply here unchanged. Its worktree, assignment and check commands do not; use the ones below.
2. `docs/content/verification/walkthrough-work/worker-rules.md`: hard limits, block syntax, option lines, emphasis, voice and
   connection rules. Its rule 5 and its "Workers run no checks" section are replaced by this brief.
3. `docs/content/verification/walkthrough-work/reasoning-precheck2-findings.md`, the rows for your four lessons. Most sit on
   checks you will delete. The check you keep and the try must not repeat any of those patterns.

## Hard rules

- Worktree: `/private/tmp/claude-501/-Users-aedwon--t3-worktrees-Pantas-content-cse-math-finish-55955c9731459ccd/7ab66a46-209f-4182-80b0-634771f1bda3/scratchpad/reasoning`
  (branch `content/walkthrough-reasoning-r1`). Edit ONLY your four lesson files. No other file.
- Change files only with the Edit or Write tool. Bash only for plain read-only commands, git show/diff/status/log, and
  the check commands below. No redirection, heredocs, sed -i, python, perl or shell scripts.
- Do not commit; the lead commits. Do not start subagents; do the work yourself.
- If you hit a Claude usage limit, stop at once and report what you changed.

## Assignment

Under `content/lessons/reasoning/logical-verbal-reasoning/`: `sequence-moves.md`, `sequence-positions-and-operations.md`,
`sequence-letter-patterns.md`, `sequence-earlier-terms.md`.

Start words before a tap (measured by the lead): sequence-moves 660, sequence-positions-and-operations 774,
sequence-letter-patterns 778, sequence-earlier-terms 640. Each may only go down, except up to 20 words inside a rewritten
check or try. Every lesson ends at or under 900.

## Rules added for this batch (manager rulings, Nov 28)

1. **Blocker means only:** a wrong or ambiguous key; a false rule; or an answer that can be copied (it is printed in a
   visible line above, or it is the only choice that fits the visible text). Aim for zero.
2. **Same-kind practice with new values is allowed** (spec point 3, extended to series by the manager). But the kept
   Quick Check and the try must each differ from the example or pair directly above in something that makes the student
   work: a different rule (for example, x4 where the example is x3), a different unknown (an earlier term, a position, or
   a missing middle term), or one more step. Its answer must not have the same form as the answer directly above it.
3. **Chains end at the answer.** Every series example shows each difference, ratio or letter move on its own line or in
   one display chain, and ends at the term asked for. Letter moves name the letter positions used (A = 1, ..., Z = 26) the
   first time they appear in the lesson.
4. **Rules are scoped.** "The pattern is ..." claims hold only for the terms shown. Never write that a series "must" follow
   a rule; write that the shown terms fit it and the next term follows from it. Any sentence with every, always, never,
   only, all, any, none or whenever must be true for every case these exam questions show, or be scoped.
5. A fixer or writer who touches a flagged item rewrites it whole.

## Pictures (spec point 5)

Number and letter series are carried by their display lines, so no picture is planned. If you judge that one lesson needs
a picture for a relation words carry poorly (for example, a letter wheel for wrap-around from Z to A), name the spot and
what it would show in your report. Do not draw anything and do not add a marker.

## Checks (run each, plain arguments, one at a time)

Lock: `L=/Users/aedwon/.t3/worktrees/Pantas/qa-cse-release-r1-485b9ecb7345be22/build/audit/flutter-locked.sh`.
Tools: `T=/Users/aedwon/.t3/worktrees/Pantas/content-cse-math-finish-55955c9731459ccd` (main's tools; read only).
Root: `R=<the worktree above>/content`.

1. Lesson checks: `cd $T && $L dart run tool/content/lesson_checks.dart --root $R 2>&1 | grep sequence-`
   Expected: no line.
2. Too-broad rule list: `cd $T && $L dart run tool/content/broad_rule_list.dart --root $R --lesson reasoning/logical-verbal-reasoning/<file>.md`
   for each of your four files. Judge each line by rule 4 and fix the false ones.
3. Parser and words: `cd /private/tmp/claude-501/-Users-aedwon--t3-worktrees-Pantas-content-lesson-walkthro-85719f9d9f054ca1/a0b12a19-1dc0-47c5-b136-c30710a95094/scratchpad/parser && dart run run.dart <4 absolute paths>`
   (expect "failing: 0") and `dart run wc.dart <4 absolute paths>` (each at or under its start count, within the rule above).

Stop when all three are clean for your four lessons.

## Report (under 350 words)

Per lesson: which check you kept and why; the kept check's and the try's stem and key, with your own re-solve from the
stem alone; what makes each differ from the example above it; any pair or rule line changed; words before and after.
Paste the output lines of the three checks. List anything unresolved and any rule you broke.
