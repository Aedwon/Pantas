# Blind pre-check and recompute, Math batch 2a (E-206, step 3)

Read `docs/content/verification/walkthrough-work/pilot-precheck-brief.md` in full. Its format notes, hard limits,
Worker 1 steps 1 to 7, Worker 2 rules, severities and output formats apply here, with these changes. Lead's policy commit
`be4ec2f41`.

Target: the working tree of `/Users/aedwon/.t3/worktrees/Pantas/content-lesson-walkthro-85719f9d9f054ca1` at the lead's
latest commit (run `git log --oneline -1` and name it in your findings file).

Lessons (12), under `content/lessons/mathematics/`:
`arithmetic-number-sense/simple-interest.md`, `arithmetic-number-sense/compound-interest.md`,
`arithmetic-number-sense/commission-and-sales-tax.md`, `arithmetic-number-sense/markup-on-cost.md`,
`arithmetic-number-sense/successive-percentages-and-increases.md`, `arithmetic-number-sense/direct-proportion-and-travel.md`,
`arithmetic-number-sense/inverse-proportion-and-remaining-work.md`,
`arithmetic-number-sense/partitive-proportion-and-differences.md`, `data-interpretation/unit-rates-and-direct-proportion.md`,
`algebra/coin-and-digit-problems.md`, `algebra/motion-chase-problems.md`, `algebra/motion-meeting-and-separation.md`.

Pictures (new, spec revision point 5). Every `<!-- ILLUSTRATION -->` marker in these 12 lessons, and in these pilot
lessons, is a drawn SVG under `content/illustrations/mathematics/<topic>/<lesson>/` (`NN-` is the marker's order):
`arithmetic-number-sense/percentage-base-and-fraction-division.md` (2), `arithmetic-number-sense/discounted-prices.md`,
`algebra/mixture-word-problems.md`, `data-interpretation/percentage-change.md`, `algebra/age-word-problems.md`,
`algebra/work-rate-problems.md`, `arithmetic-number-sense/decimal-and-percent-conversions.md`.
Read each SVG's text as part of the lesson at the marker's spot. For the pilot lessons, check only the pictures and the
lines beside them; their text passed two Codex reads.

Added checks for pictures:
- Worker 1: a picture is visible text. Flag a check or try whose key a picture shows or makes copyable (Blocker). Flag a
  picture that shows a relation wrongly or contradicts the text beside it (Blocker), or that only repeats the text with no
  relation added (Major).
- Worker 2: recompute every number and label in every picture, and confirm each one equals the lesson text beside the
  marker (the paragraph, display lines or example directly above or below it). A number that is not in that text, or
  differs from it, is a mismatch. Check that bars said to be to scale are to scale (compare rect widths).

Findings files: Worker 1 `docs/content/verification/walkthrough-work/batch-2a-precheck-findings.md`, Worker 2
`docs/content/verification/walkthrough-work/batch-2a-recompute-findings.md`.

Report (both, under 200 words): verdict, counts per lesson and per picture, findings file path.
