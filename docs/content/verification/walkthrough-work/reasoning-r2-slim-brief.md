# Brief: slim batch R2, logic forms and truth values (E-216, step 1)

Follow `docs/content/verification/walkthrough-work/reasoning-r1-slim-brief.md` in this worktree in full (startup, reading
list, hard rules, the five batch rules, checks, report), with the changes below. Lead's policy commit `3bffd9286`.

## Assignment

Under `content/lessons/reasoning/logical-verbal-reasoning/`: `deductive-group-arguments.md`, `valid-conditional-forms.md`,
`invalid-conditional-forms.md`, `truth-tables-and-connectives.md`, `conditional-truth-values.md`, `combined-truth-values.md`.
Plus one new picture (below). No other file.

Measure each lesson's start words with `wc.dart` before your first edit and report them. Each may only go down, except up to
20 words inside a rewritten check or try, and lines the R1 patterns below require. Every lesson ends at or under 900.

Pre-check rows to read in `reasoning-precheck2-findings.md` (on `content/lesson-walkthrough-cse-r1`): the rows for these six
lessons, including the Blockers in `conditional-truth-values` (key printed in a pair above), `invalid-conditional-forms`
(check has the same form and answer as the pair above) and `valid-conditional-forms` (two).

## Rule 3 and 4 for this batch (replace the series wording)

- Chains end at the answer. A truth-table row shows each connective's value on its own step and ends at the final column
  value asked for. A syllogism or conditional example names its form (for example, "if P then Q; P; so Q"), maps each
  sentence to it, and ends at the verdict asked for (valid or invalid; which conclusion follows).
- Rules are scoped. "Valid" means the conclusion must be true whenever the premises are true; never write that a valid
  argument's conclusion is true. A rule about "some" says what it does and does not force. Any sentence with every, always,
  never, only, all, any, none, must or whenever must be true for every case these exam questions show, or be scoped.

## R1 Codex patterns: apply them now, before any read

1. Every Core Concept demo and every example opens by naming what is found ("Decide whether ... is valid", "Find the value
   of ... when ..."), never only "Check" or "Look at".
2. The try fades only the last move. Show every earlier move; the try asks for the final value or verdict.
3. A definition covers every case the topic meets (do not define a term more narrowly than its real use), then says what
   this lesson covers.
4. No example reuses the exact sentences or values of a Core Concept demo or pair in the same lesson.
5. Checklist lines are short: cue, the right move, and its result. Do not replay the whole pair or series.
6. A two-part step (negate, then combine) shows the middle value before the final one.

## Picture (spec point 5)

`deductive-group-arguments.md` line 29 has `<!-- FIGURE WANTED: ... -->` for three side-by-side circle diagrams (All A
are B, No A are B, Some A are B). It is the lesson's key picture, so draw it:
- Read `docs/content/lesson-svg-authoring.md` from `origin/main`, and look at the existing
  `content/illustrations/reasoning/logical-verbal-reasoning/deductive-group-arguments/01-*.svg` for style.
- Change the comment to `<!-- ILLUSTRATION: ... -->` on the same line, with its full meaning as the description, placed
  after the line that names the three statement types, outside any `:::` block.
- Its file is the first marker in the lesson, so it becomes `01-`. Rename the two existing files with `git mv` (git is
  allowed): `01-nested-circles-with-mammals-inside.svg` to `02-...` and `02-a-circle-labeled-birds-inside.svg` to `03-...`.
  Write the new file as `01-three-statement-diagrams.svg` with the Write tool.
- Every label equals the lesson text beside it. Theme colors only (`#010101` ink, `#020202` secondary, `#030303` paper,
  `#040404` rule, `#050505` accent), text 12 or larger, about 360 wide, allowed elements only.
- Check: `cd <the worktree> && python3 /Users/aedwon/.t3/worktrees/Pantas/content-cse-math-finish-55955c9731459ccd/tools/check_lesson_svgs.py . --validate-only`
  (usage: `check_lesson_svgs.py [ROOT] [--validate-only]`). Report the lines for this lesson's folder.
- In the lesson-checks step, grep for your six file names instead of `sequence-`.
- Keep the other ILLUSTRATION markers where they are; each must sit after the line that gives its labels.

## Report

As in the R1 brief, for six lessons, plus the picture: its marker line, file names after the rename, and the SVG check
output.
