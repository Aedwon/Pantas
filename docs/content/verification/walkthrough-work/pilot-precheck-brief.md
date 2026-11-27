# Blind pre-check and recompute, Math pilot (E-204, step 4)

Two read-only workers. You did not write these lessons. Lead's policy commit `890325dee`. Startup: read `AGENTS.md`
("Maths in content" and Voice) and `SUBAGENTS.md` Part 7b from current main (`git show origin/main:<path>`).

Target: worktree `/Users/aedwon/.t3/worktrees/Pantas/content-lesson-walkthro-85719f9d9f054ca1`, commit `53b7485b2` plus one
lead edit (the working tree is the target). The 10 lessons, under `content/lessons/mathematics/`:
`algebra/age-word-problems.md`, `algebra/mixture-word-problems.md`, `algebra/work-rate-problems.md`,
`arithmetic-number-sense/discounted-prices.md`, `arithmetic-number-sense/percentage-base-and-fraction-division.md`,
`arithmetic-number-sense/identities-and-like-terms.md`, `arithmetic-number-sense/decimal-and-percent-conversions.md`,
`arithmetic-number-sense/simple-interest.md`, `data-interpretation/percentage-change.md`,
`data-interpretation/table-values-and-totals.md`.

Format they follow (spec revision of Nov 27): one `:::check` per lesson, one `:::try` (the faded last step of the last
example), no `**Check:**` lines, 2 or 3 always-open `:::pair` blocks (Right, Wrong, note), a `:::checklist`. A Quick Check
may be the same kind of problem as the example with new numbers or context. `:::answer` and `:::why` are hidden until a tap;
everything else is visible. `<!-- FIGURE WANTED -->` comments are not shown; `<!-- ILLUSTRATION -->` markers are drawn
figures (`content/illustrations/mathematics/<topic>/<lesson>/`), so read those SVGs for the two table lessons.

Hard limits: READ-ONLY. No edits to the repository, no git writes, no scripts, no redirection, no subagents. Write only your
findings file, with the Write tool. If you hit a Claude usage limit, stop and report.

## Worker 1: blind pre-check (findings file `docs/content/verification/walkthrough-work/pilot-precheck-findings.md`)

For the `:::check` and the `:::try` in each lesson:
1. Read the lesson top down to the item as a student sees it (visible text only). Do not read the item's `:::answer`.
2. Solve the item. Write your answer.
3. Flag it if a student who did not learn the rule could answer by surface matching: the key appears in a visible line
   above or in its own stem; a visible step already does what the item asks; a heading names the answer; only one choice
   fits a printed list or marker.
4. Flag it if it repeats the frame of the example or pair directly above with only numbers or names swapped, so the student
   repeats printed steps without the rule (Major).
5. Open the `:::answer`. A different key, or a second defensible answer, is a Blocker.
6. Rule scope: run `/Users/aedwon/.t3/worktrees/Pantas/qa-cse-release-r1-485b9ecb7345be22/build/audit/flutter-locked.sh dart run tool/content/broad_rule_list.dart --root /Users/aedwon/.t3/worktrees/Pantas/content-lesson-walkthro-85719f9d9f054ca1/content --lesson <path>` from `/Users/aedwon/.t3/worktrees/Pantas/walkthrough-checks-r1` (plain arguments; read its usage line for the path form). For each printed line, and any other rule sentence you notice, name a counterexample if one exists in what these exam questions use. A false rule is a Blocker; a true rule missing a condition a student needs is a Major.
7. Also read each worked example once: every display chain ends at its value, each example opens with one lead-in naming
   what is found, and nothing reads as added narration. Missing connection or wordiness is a Major.

Severity: Blocker = wrong or ambiguous key, an answer that can be copied, a false rule, an unsolvable item. Major = frame
clone, missing condition, missing connection, wordiness. Minor = style.
Format: `Severity | file:line | item | problem | fix (one line)`. Then one line per lesson (`OK` or counts). End with
`PRECHECK VERDICT: PASS` (0 Blockers) or `PRECHECK VERDICT: FAIL (N Blockers, M Majors)`.

## Worker 2: independent recompute (findings file `docs/content/verification/walkthrough-work/pilot-recompute-findings.md`)

Recompute every number in the 10 lessons yourself: every display line, every step, every pair's Right and Wrong lines
(a Wrong line must be wrong in the way its note says), every `:::check`, `:::try` and Why answer, every Speed Trick and
checklist value, and the table figures against the text. Solve each check and try from its stem before reading its answer.
Check units, rounding, signs, and that each stem has exactly one answer.
Also confirm each pair's Wrong line still shows the cited wrong choice: for each lesson, the citations are the entries for
its `_id` in `content/walkthrough-trap-evidence.json`; the question is in `content/questions/mathematics/` (grep the id).
Format: `Severity | file:line | value | your value | note`, then per lesson `N values checked, K mismatches`, and
`RECOMPUTE VERDICT: PASS` (0 mismatches) or `FAIL (K)`.

Report (both, short): verdict, counts per lesson, findings file path.
