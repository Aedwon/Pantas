# Brief: Math batch 2d, Majors fixed once after Codex read 2 (E-206)

Read `docs/content/verification/walkthrough-work/batch-2d-r1-fix-brief.md` in full first, and the briefs it names. All of
its rules, rulings, hard limits and checks apply. Lead's policy commit `be4ec2f41`.

Codex read 2 of batch 2d: FAIL with 1 Blocker, in the infinite-series picture only. The lead removed that picture and its
marker (`d6751f22f`); no lesson text has a Blocker. Fix each `Major` row (7) in
`/private/tmp/claude-501/-Users-aedwon--t3-worktrees-Pantas-content-lesson-walkthro-85719f9d9f054ca1/e9af84d4-e298-4015-a487-439b46cd24bf/scratchpad/codex/2d-r2/batch-2d-r2.md`
as it says, in the smallest change that does it. This is the one Major fix; no further Codex read follows and the lead
checks every diff, so change nothing else. Minors: no change. Line numbers are at `927b07280` (infinite-geometric-series
lines after 31 moved up by 4).

Lead ruling on the zero-transition rows (geometric-sequence-terms 21, finding-number-patterns 32): one short clause, for
example "A $0$ must be followed by $0$; if a $0$ is followed by a nonzero term, the list is not geometric." No new example.
For arithmetic-series-sums 160: add one short worked line before the try that subtracts two consecutive partial sums, with
numbers no quiz question uses and not the try's numbers.

One fixer, these files under `content/lessons/mathematics/arithmetic-number-sense/`: `arithmetic-series-sums.md`,
`geometric-sequence-terms.md`, `infinite-geometric-series.md`, `finding-number-patterns.md`,
`signed-integer-operations.md`, `real-number-sets.md`. Do not edit SVGs or the real-number-sets code figure line.

Report (under 250 words): each row, one line on how it was fixed; words after; the three checks' output.
