# Brief: slim batch R4, verbal logic tests (E-216, step 1)

Follow `docs/content/verification/walkthrough-work/reasoning-r1-slim-brief.md` in this worktree in full (startup, reading
list, hard rules, batch rules 1, 2 and 5, checks, report), and the "R1 Codex patterns" section of
`reasoning-r2-slim-brief.md` (all six patterns), with the changes below. Lead's policy commit `3bffd9286`.

## Assignment

Under `content/lessons/reasoning/verbal-logic/`: `needed-assumptions.md` (start 842), `negating-assumptions.md` (850),
`must-be-true-conclusions.md` (796), `none-and-may.md` (744). No other file. Start words only go down, except up to 20 words
inside a rewritten check or try and lines the patterns require; every lesson ends at or under 900. In the lesson-checks
step, grep for your own file names.

Pre-check rows to read in `reasoning-precheck2-findings.md` (on `content/lesson-walkthrough-cse-r1`), section
"verbal-logic": the rows for your four lessons. Their Blockers (needed-assumptions, negating-assumptions,
must-be-true-conclusions, none-and-may twice) copied the pair directly above or printed the rule that answers the check.

## Rules 3 and 4 for this batch

- Chains end at the answer. Each example states the argument's conclusion and premise, applies the lesson's test (the
  negation test, "must it be true?", or the some/none/may rules) to each choice in turn, and ends at the choice asked for.
- Rules are scoped. "Some A are B" does not force "some A are not B". "None" and "may" claims are stated for exactly the
  cases they cover. An assumption is "needed" only when its negation makes the conclusion fail. Any sentence with every,
  always, never, only, all, any, none, must or whenever must be true for every case these exam questions show, or be
  scoped.
- These lessons also learned from R3 Codex: a Core Concept demo must not use the values, sentences or answer of a linked
  quiz question (`content/questions/reasoning/verbal-logic/assumptions-and-conclusions.yaml`); a pair may keep a quiz's
  wrong choice, because its citation needs it.
- The kept Quick Check and the try must differ from the pair or demo above in the deciding feature (another quantifier,
  another kind of gap, or a choice that only fails the negation test), so the answer cannot be copied from the frame above.

## Pictures

None planned. Do not draw anything.

## Report

As in the R1 brief, for four lessons.
