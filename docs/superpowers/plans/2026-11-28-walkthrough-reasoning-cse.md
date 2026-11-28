# CSE step-based reasoning in the walk-through format: plan (E-216)

Date: November 28, 2026. Lead: CSE walk-through lead (Claude Opus 5.5). Manager: `mcp:61bb1f57-51d4-46fa-a3a3-b4e0e667778b`.
Policy read: `Aedwon/Pantas` main 80d17f600. Status: **plan sent to the manager; no lesson written yet.**

Controlling spec: `docs/superpowers/specs/2026-11-25-lesson-walkthrough-standard.md`, revision of Nov 27 (scope point 1,
slim format point 2, practice point 3, caps point 4, pictures point 5).

His words: Nov 28, about 3:40 PM Manila, on step-based reasoning: "after 2, do this"; "let's put efforts into CSE please".
Standing: Nov 27 "i do not want to waste any more usage than necessary"; Nov 28 "obviously i want you to slow down"; on
audits "be careful not to end up in an endless audit loop lest we waste too much usage"; on fixes "please only fix those
things absolutely necessary. we don't need to cover everything, pareto principle."

## 1. Scope

Counted from the live content root `content/cse-math-qfix-2b-r2` 34f3c7e24. A lesson is CSE when a CSE-tagged question file
links it. Retired parents are not touched.

**In scope: lessons solved in steps (23).** A student applies a fixed procedure and reaches one checkable answer.

| Batch | Lessons | Exams (question files) | Questions |
|---|---|---|---|
| R1 pilot: number and letter series (4) | sequence-moves, sequence-positions-and-operations, sequence-letter-patterns, sequence-earlier-terms | CSE Pro and Sub, ACET, USTET, DOST-SEI, UPCAT, DLSUCET | 20 |
| R2 logic forms and truth values (6) | deductive-group-arguments, valid-conditional-forms, invalid-conditional-forms, truth-tables-and-connectives, conditional-truth-values, combined-truth-values | CSE Pro and five CETs | 41 |
| R3 clerical filing (9) | personal-name-filing-units, filing-patterns-and-surname-particles, suffixes-titles-and-filing-ties, character-string-filing, integer-subcode-filing, terminal-digit-filing-order, whole-number-and-decimal-filing, oldest-and-newest-date-order, year-first-and-stated-date-formats | CSE Sub only | 44 |
| R4 verbal logic tests (4) | needed-assumptions, negating-assumptions, must-be-true-conclusions, none-and-may | CSE Pro, UPCAT, ACET | 30 |

Order is Pareto, highest student value first: R1 is the most step-like, serves both CSE levels and five college tests, and
is closest to the Math lessons that passed. R2 serves CSE Pro and the college tests. R3 serves CSE Sub only. R4 is last
because it sits nearest to judgment questions and held 5 of the 20 Blockers in the Nov 27 pre-check. The manager may
cut R4.

**Stay as they are (live lessons unchanged; walk-through drafts unused):**
- Spatial and abstract, figure-based (14): figure grouping (3), figure matrices (4), figure series (3), paper folding and
  cutting (4). The manager excluded them; they are solved by seeing, and their tries need new hand-drawn figures.
- Word analogies (3): analogy-functions-users-and-work, analogy-meanings-and-double-pairs, analogy-parts-types-and-products.
  The spec's point 1 lists analogies, so this is a departure for the manager to rule on (decision 1). They are solved by
  word meaning, the same failure class as Grammar and Vocabulary: each practice item becomes a vocabulary item, which
  is where copyable answers and too-broad rules came from.
- Verbal logic judgment (4): best-supported-conclusions, compound-assumptions, recognizing-bias,
  unsupported-causes-and-motives. There is no fixed procedure with one checkable answer.
- Mechanical reasoning: no CSE question file links it.

"Word problems in reasoning": CSE has none in the reasoning files; the word problems are in Math, which is done.

## 2. Why the Nov 27 Reasoning pre-check rose from 13 to 20 Blockers, and how this plan avoids it

Source: `docs/content/verification/walkthrough-work/reasoning-precheck2-findings.md` on `content/lesson-walkthrough-cse-r1`
and the Nov 27 3:50 PM launch log entry (pattern list).

Causes:
1. **Too many practice items.** Each draft carries 2 to 4 Quick Checks plus a try (about 4 per lesson, 47 lessons at
   once). Every item is a new place for the main pattern: a check that repeats the step above it with words swapped.
2. **A fresh reader with a wider Blocker rule.** Round 2's verifier counted "the visible frame reused so the answer
   pattern transplants" as a Blocker. Of the 20 Blockers, 17 are a check that repeats the demo, pair or Why block
   directly above it; 2 print the key or rule nearby; 1 is a wrong key (paper folding, out of scope). 15 of the 20 sit
   in lessons this plan covers.
3. **Row-only fixes.** The round 1 fixer rewrote the flagged rows, and the new checks copied the nearest demo again.
4. **Too-broad rules** in verbal logic and conditionals ("whenever", "only"), found one exception at a time.
5. **Short chains**: series steps that skip a difference, and truth tables that stop before the final column.

Plan answers, one for each cause:
1. **Slim format** (spec point 2): one Quick Check and one try per lesson. That is about 2 practice items instead of 4.
   The 2 to 4 checks in each draft are cut, not fixed.
2. **One Blocker definition in every brief**, the spec's own: a wrong or ambiguous key, a false rule, or an answer that
   can be copied (printed above it, or the only choice that fits). Same-kind practice with new values is allowed, as
   in Math (decision 2). A frame copy whose answer has the same form as the example's answer is a **Major**, fixed once.
3. **Writers apply the shape rule while writing, not after review.** The Quick Check uses the lesson's move on new
   values, and its answer has a different form from the example's (another position, order, or truth value). A fixer
   who touches a flagged item rewrites it whole (Nov 27 Grammar rule).
4. **Rule scan before Codex.** The verifier lists every rule with all, every, always, never, only, or a bare "X means Y"
   and tries one counterexample. A rule with a known exception is scoped before the Codex read (Nov 27 required step).
5. **Chains end at the answer.** Each series example shows every difference or move on its own line and ends at the
   asked term. Each truth table ends at the final column. Main's connection check enforces the lead-in and the chain end.
6. **Automatic checks first.** Main's walk-through checks (giveaway, fresh instance, slim format, connection, trap pair,
   hard break, block spacing) and `lesson_checks.dart` run on every batch before any reader sees it.
7. **Pilot before scale.** R1 (4 lessons) must pass before R2 starts. If R1 fails both reads, the whole job stops and
   comes to the manager with options.

## 3. Steps per batch

Start each batch from the walk-through draft on `content/lesson-walkthrough-cse-r1` (9cad788a2), copied whole onto the
work branch. The drafts already carry the Nov 26 connection rule and the trap evidence; the Math batches passed the
same way.

1. **Slim** (1 Sonnet writer): one Quick Check, one try, no per-example Check lines, at most 900 words before a tap,
   every pair tied to a real wrong choice (`content/walkthrough-trap-evidence.json`). Pictures: keep the drawn Venn
   diagrams (deductive-group-arguments 2, valid-conditional-forms 2, invalid-conditional-forms 1), each placed after the
   line that gives its labels. Draw a picture only where the spec's point 5 asks for one; the one hidden "figure wanted"
   note in deductive-group-arguments is drawn in R2 or its sentence is reworded. No other new pictures are planned.
2. **Automatic checks**: main's lesson checks and walk-through checks, exit 0.
3. **Blind pre-check** (1 Sonnet verifier, one pass): solve the Quick Check and try with answers hidden; recompute every
   number, letter and truth value shown; list too-broad rules with counterexamples. Gate: 0 Blockers. The lead fixes
   what it finds, rewriting whole items.
4. **Codex read 1** (`codex-pick`, account b, one run at a time across lanes, findings written as found).
5. Fix Blockers and Majors by pattern (1 Sonnet fixer); the lead checks every diff.
6. **Codex read 2**, only if read 1 had a Blocker. If read 1 has 0 Blockers, its Majors are fixed once and the batch
   passes with one read.
7. After the last read: 0 Blockers passes. Majors are fixed once and lead-checked, with no further read.
8. **Hand-off**: a branch stacked on the live content root, main's export and content gate exit 0, front matter
   compared with the root. The release lead uploads it; this lane makes no hosted run.

## 4. Caps and stop rules

- At most 2 Codex full reads per batch. Blockers gate each read. Majors are fixed once.
- **A lesson that fails its batch's second read waits for the manager. It never moves into another batch** (manager,
  Nov 28, adopting the Job 1 finding: the motion-meeting lesson had 4 reads by moving batches).
- If a batch fails after two reads, it stops. Lessons with 0 Blockers in it still pass; the failing lessons come to
  the manager with options. If R1 fails, the job stops.
- One Claude worker at a time: Sonnet for writing and checking, Haiku for bulk reads. No Gemini. No UI changes.
- Files change only with Edit or Write; Bash for read-only commands and git.

## 5. Estimate and cost

- Lead time: about 3 h 30 min active, about 6 h wall (Codex waits on b), for all four batches. R1 alone: about 1 h
  active, 1 h 45 min wall. Calibration: the Math pilot (10 lessons) took 3 h 46 min wall against 9 h estimated (E-204),
  and Math batch 2 (46 lessons) took 4 h 41 min against 20 h (E-206). Reasoning failed harder on Nov 27, so this estimate
  stays above those actuals.
- Codex: at most 8 full reads; expected 5 to 6. Account b at 07:35 UTC: 5-hour 28%, weekly 52%. For scale, the
  Grammar full read of 52 lessons used 25% of b's 5-hour window (Nov 27 state notes); batches here are 4 to 9 lessons.
- Claude workers: about 4 per batch, one at a time (writer, verifier, fixer, Major fixer).
- Hosted reads (rule 7): none by this lane. Each upload is the release lead's run and its count.

## 6. Decisions for the manager

1. **Analogies stay as they are** (recommended), although spec point 1 lists them. Cost of including them: one more
   batch of 3 lessons, about 45 min and 1 to 2 Codex reads, with the highest risk of a second-read failure.
2. **Same-kind practice with new values is allowed in step-based reasoning**, as spec point 3 allows in Math
   (recommended). Without it, the Quick Check must test a case the lesson never worked, which tests something untaught
   (the Grammar "5a" problem).
3. **R4 verbal logic tests**: include last (recommended), or cut it to save about 45 min and 2 Codex reads.

## 7. Manager rulings (Nov 28, rule 4)

1. Analogies stay as they are. 2. Same-kind practice with new values is allowed, as in Math. 3. R4 runs last, only if R1
to R3 finish inside the estimate with nothing waiting on the manager. Added: a lesson that fails its batch's second read
waits for the manager and never moves into another batch.

## 8. Results (branch `content/walkthrough-reasoning-r1`, records in `docs/content/verification/walkthrough-work/reasoning-*` there)

| Batch | Passed | Held at live version | Codex reads | Handed off |
|---|---|---|---|---|
| R1 series | 4 of 4 | none | 2 (2 Blockers, then 0) | 9d212c643, live |
| R2 logic | 5 of 6 | combined-truth-values (2 Blockers on read 2; manager ruling A: keep live, no edits, no third read) | 2 (5, then 2) | 5f7d79c39, live |
| R3 filing | 9 of 9 | none | 2 (1, then 0) | b47d313ea, live |
| R4 verbal logic | 2 of 4 | needed-assumptions (3 Blockers), negating-assumptions (1 Blocker) on read 2; with the manager | 2 (5, then 5) | dbc5e7244 |

Also: four held Math lessons returned with their pictures re-laid (no shifted tspans), live with R3; the LCM picture's
dashed line breaks at its labels; the imaginary-unit powers are written inline (no `\qquad` read aloud). A live question
defect found by R4 read 2 (assumptions-and-conclusions 0040) went to the release lead. Time: 2 h 20 min wall (E-216).
