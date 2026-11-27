# Brief: batch 2b, pre-check Majors and recompute notes (E-206)

Read `docs/content/verification/walkthrough-work/batch-2a-r1-fix-brief.md` in full first, and the briefs it names. All of
its rules, hard limits and checks apply (use main's tools at the maintools path in `batch-2b-precheck-brief.md`). Lead's
policy commit `be4ec2f41`.

Fix, by the smallest change that does it:
1. Every `Major` row in `docs/content/verification/walkthrough-work/batch-2b-precheck-findings.md` (6 rows).
2. The 5 "Minor notes" in `docs/content/verification/walkthrough-work/batch-2b-recompute-findings.md` (missing conditions,
   an unnamed $t$, the motion picture one line early). Codex flagged these same kinds as Majors in batch 2a.

Lead rulings:
- The fractions-and-mixed-forms "convert everything to decimals" rule: scope it to fractions whose decimals stop (terminating
  decimals), and say that for a repeating decimal, convert to fractions instead.
- The inverse-proportion check that repeats the machine example's frame: ask for a different unknown (for example the
  time, if the example finds the crew), fresh numbers, key not printed above or in its stem, one answer, re-solved by you.
- The motion late-start sentence: split it into two short sentences. Add no new example.

Lessons (only these, under `content/lessons/mathematics/`): `arithmetic-number-sense/fractions-and-mixed-forms.md`,
`data-interpretation/chart-scales-and-differences.md`, `data-interpretation/inverse-proportion-and-ratio-parts.md`,
`data-interpretation/averages-and-pie-chart-shares.md`, `algebra/motion-meeting-and-separation.md`. Move a marker line
unchanged if needed; do not edit SVG files.

Report (under 250 words): each row fixed how (one line); any new check with your re-solve; words before and after; the
three checks' output lines.
