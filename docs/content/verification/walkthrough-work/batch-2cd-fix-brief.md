# Brief: batch 2c Majors fixed once (after its last read), and batch 2d pre-check fixes (E-206)

Read `docs/content/verification/walkthrough-work/batch-2c-r1-fix-brief.md` in full first, and the briefs it names. All of
its rules, rulings, hard limits and checks apply. Lead's policy commit `be4ec2f41`.

## Fixer A: batch 2c, the one Major fix

Codex read 2 of batch 2c: FAIL with 1 Blocker, in `real-number-sets.md` only; that lesson drops to batch 2d and is not
yours. The other 10 lessons pass. Fix each `Major` row for those 10 in
`/private/tmp/claude-501/-Users-aedwon--t3-worktrees-Pantas-content-lesson-walkthro-85719f9d9f054ca1/e9af84d4-e298-4015-a487-439b46cd24bf/scratchpad/codex/2c-r2/batch-2c-r2.md`
as it says, in the smallest change that does it (9 rows: coprime 28 and 72, digit-sums 45, seven-and-eleven 89,
last-digit 19, LCM 72, same-remainder 85, complex 163, imaginary 30 and 93). No further Codex read follows and the lead
checks every diff, so change nothing else. Minors: no change. Line numbers are at `a0df70bbd`. Files under
`content/lessons/mathematics/arithmetic-number-sense/`.

## Fixer B: batch 2d before its Codex read, plus Real Number Sets

1. Every Major in `docs/content/verification/walkthrough-work/batch-2d-precheck-findings.md` and
   `docs/content/verification/walkthrough-work/batch-2d-recompute-findings.md` (they overlap), by pattern. Lead ruling on
   the tries that hand over only arithmetic: the try stays the faded last step of the last example, but that step must be
   the one that applies the lesson's rule. Write the stem so the student does the rule move ("Use $a_n=a_1+(n-1)d$ with
   $a_1=5$ and $d=4$ to find $a_{10}$"), not the final sum alone ("$5+36$"). If the example's last step is pure arithmetic,
   fade the last two steps instead. Fresh numbers are not needed; the key must not be printed above or in its stem.
2. `real-number-sets.md` joins batch 2d. Fix its read 2 Blocker (line 112: make the exact value of
   $\sqrt{12}\times\sqrt{3}$ the answer of the faded step, and use the classification only to explain it in the answer) and
   its read 2 Major (line 25: classify the first numbers with the sets defined so far, or define rational and real first).
   Keep the code figure line unchanged.
Files: the batch 2d lessons the rows name and `real-number-sets.md`, under `content/lessons/mathematics/arithmetic-number-sense/`.
Move a marker line unchanged if a row says so (odd-and-even picture after the steps that find both rules). Do not edit SVGs.

## Report (each, under 300 words)

Each row fixed how (one line); any changed check or try with your re-solve; words after; the three checks' output.
