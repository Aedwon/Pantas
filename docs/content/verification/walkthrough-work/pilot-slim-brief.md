# Brief: slim the Math pilot lessons (E-204, step 3)

Lead: walk-through Math pilot lead. Plan: `docs/superpowers/plans/2026-11-27-walkthrough-math-pilot.md` (read "Step 3").
Read `docs/content/verification/walkthrough-work/worker-rules.md` in full: its hard limits, block syntax, option-line,
emphasis, voice and connection rules all apply, with the changes below. Its rule 5 ("the try's **Check:** sits inside
its :::answer") and its "Workers run no checks" section are replaced by this brief.

Startup: retrieve `AGENTS.md`, `WORKFLOW.md`, `SUBAGENTS.md` from current GitHub main and follow them. Spec:
`git show origin/main:docs/superpowers/specs/2026-11-25-lesson-walkthrough-standard.md`, especially Part A "Revision,
November 27, 2026" and Part B "Authoring rules". Lead's policy commit `890325dee`.

Worktree: `/Users/aedwon/.t3/worktrees/Pantas/content-lesson-walkthro-85719f9d9f054ca1` (shared with the lead and one other
writer). Edit ONLY your five assigned lesson files. No other file. Do not commit; the lead commits.

If you hit a Claude usage limit, stop at once and report what you changed.

## The revised format (Nov 27), applied to the whole lesson, not row by row

1. Delete every `**Check:**` line and its sentence(s): in examples, in `:::check` answers, in `:::try` answers.
2. Keep exactly one `:::check` in the lesson. Delete the others with their answers. Keep the one that best tests the
   lesson's main skill (its first key point unless that check was flagged). Say which you kept and why in one line.
3. The kept `:::check` and the `:::try` must each be a fresh instance:
   - Same kind of problem as the worked example with new numbers or a new context is allowed (spec revision rule 3).
   - It must not reuse the frame of the example or pair directly above with only numbers or names swapped. Change one
     thing that makes the student think: ask for a different unknown, reverse the roles, or add one step.
   - Its answer must not appear anywhere above it in visible text (core lines, pairs, display math, steps, headings).
   - Its key must not be any number printed in its own stem.
   - Only one correct answer. Re-solve it yourself from the stem alone.
   - The `:::try` stays the faded last step of the last example. If the visible lines above already give its answer,
     change what the try asks (for example, ask for the step's result in the form the question wants) or change the
     example's last numbers, keeping every earlier step correct.
   - The answer starts "The answer is ..." with the result, then one short line of reason. No Check line.
4. Pairs: keep 2 or 3, at their steps, with their quiz citations unchanged (the Wrong line must still show the cited wrong
   choice; the citations are in `content/walkthrough-trap-evidence.json`, which you do not edit). A pair's Right line must
   not print the answer of the kept check or the try.
5. Every rule sentence with every, always, never, only, all, any, none, whenever, or a bare "X means Y" must be true for
   every case a student meets in these exam questions. If it has a real exception, scope it to the cases the lesson
   shows ("For a positive rate, ..."). The lead runs a list of these lines for you; see Checks.
6. Every worked example opens with one short lead-in naming what is found and from what, and every display chain ends at its
   value. Connection, not more words.
7. No new narration. Pre-tap words may only go down, except up to 20 words inside a rewritten check or try.
8. Keep the checklist: 2 or 3 lines, each `Cue: right move {#slug}` pointing at a pair id or a `###` slug that still exists.
   If you delete a check whose heading a checklist line pointed at, fix the slug.
9. Front matter stays as is.

## Known findings to fix by pattern (Nov 27 pre-check at `a2b132670`; Blockers were rewritten in `de02e682d` but never re-checked)

Read `docs/content/verification/walkthrough-work/math-precheck-findings.md` rows for your lessons. Many of those rows sit
on checks you will delete; the kept check and the try must not repeat any of those patterns. Current giveaway-check hits on
the branch: `decimal-and-percent-conversions` try (key 0.45 printed above as $45\div100=0.45$) and
`percentage-base-and-fraction-division` try (key 40% also printed in a pair's Right line, a false alarm in kind, but the
lesson must pass: change the try's ask or numbers so its key appears nowhere above).

## Assignments

- Writer A: `algebra/age-word-problems.md`, `algebra/mixture-word-problems.md`, `algebra/work-rate-problems.md`,
  `arithmetic-number-sense/discounted-prices.md`, `arithmetic-number-sense/percentage-base-and-fraction-division.md`.
- Writer B: `arithmetic-number-sense/identities-and-like-terms.md`, `arithmetic-number-sense/decimal-and-percent-conversions.md`,
  `arithmetic-number-sense/simple-interest.md`, `data-interpretation/percentage-change.md`,
  `data-interpretation/table-values-and-totals.md` (its two tables are drawn figures; keep every number the figures show,
  and keep the `<!-- ILLUSTRATION -->` markers exactly where they are).
All paths are under `content/lessons/mathematics/`.

## Checks (you run these, plain arguments, through the machine lock, one at a time)

Lock: `L=/Users/aedwon/.t3/worktrees/Pantas/qa-cse-release-r1-485b9ecb7345be22/build/audit/flutter-locked.sh`.

1. Lesson checks, from the checks worktree, filtered to your lesson ids:
   `cd /Users/aedwon/.t3/worktrees/Pantas/walkthrough-checks-r1 && $L dart run tool/content/lesson_checks.dart --root /Users/aedwon/.t3/worktrees/Pantas/content-lesson-walkthro-85719f9d9f054ca1/content 2>&1 | grep -E "<your lesson file names, joined with |>"`
   Expected: no line for your lessons (other lessons will fail; ignore them).
2. Over-broad list for your lessons:
   `cd /Users/aedwon/.t3/worktrees/Pantas/walkthrough-checks-r1 && $L dart run tool/content/broad_rule_list.dart --root /Users/aedwon/.t3/worktrees/Pantas/content-lesson-walkthro-85719f9d9f054ca1/content --lesson lessons/mathematics/<path> ...`
   Judge each line by rule 5 and fix the false ones. (If `--lesson` wants another path form, read the tool's usage line.)
3. Parser and words: `cd /private/tmp/claude-501/-Users-aedwon--t3-worktrees-Pantas-content-lesson-walkthro-85719f9d9f054ca1/a0b12a19-1dc0-47c5-b136-c30710a95094/scratchpad/parser && dart run run.dart <your 5 absolute paths>` (expect failing: 0) and `dart run wc.dart <your 5 absolute paths>` (each at or under its start count: age 775, mixture 716, work-rate 715, discounted 613, percentage-base 678, identities 509, decimal 552, simple-interest 621, percentage-change 569, table-values 671; up to +20 allowed only inside a rewritten check or try).

Stop when all three are clean for your five lessons.

## Report (short, under 350 words)

Per lesson: which check kept and why; the kept check's and the try's stem and key, with your own re-solve; any pair or rule
line changed; words before and after. The pasted output lines of the three checks for your lessons. Anything unresolved.
